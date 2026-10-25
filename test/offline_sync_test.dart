import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:inventory/models/inventory_models.dart';
import 'package:inventory/services/api_service.dart';
import 'package:inventory/services/offline_store.dart';
import 'package:inventory/services/sync_policy.dart';
import 'package:shared_preferences/shared_preferences.dart';

ApiException api(int status, [String code = 'X']) =>
    ApiException(statusCode: status, code: code, message: 'm');

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('classifySyncError', () {
    test('unreachable server and transient failures are retried', () {
      expect(classifySyncError(const SocketException('x')), SyncFailure.retry);
      expect(classifySyncError(TimeoutException('x')), SyncFailure.retry);
      expect(classifySyncError(http.ClientException('x')), SyncFailure.retry);
      expect(classifySyncError(api(500)), SyncFailure.retry);
      expect(classifySyncError(api(503)), SyncFailure.retry);
      expect(classifySyncError(api(429)), SyncFailure.retry);
      expect(classifySyncError(api(408)), SyncFailure.retry);
      expect(
        classifySyncError(api(502, 'INVALID_JSON_RESPONSE')),
        SyncFailure.retry,
      );
    });

    test('business errors are rejected, 401 stops the flush', () {
      for (final s in [400, 404, 409, 422]) {
        expect(classifySyncError(api(s)), SyncFailure.reject);
      }
      expect(classifySyncError(api(401, 'TOKEN_REVOKED')), SyncFailure.auth);
    });

    test('a parse/cast error is a poison op, not a network error', () {
      expect(classifySyncError(TypeError()), SyncFailure.poison);
      expect(classifySyncError(const FormatException('x')), SyncFailure.poison);
      expect(isNetworkError(const FormatException('x')), isFalse);
    });
  });

  group('offline queue', () {
    test('ops get stable ids and are removed by id', () async {
      final store = OfflineStore('u1');
      await store.enqueue(const PendingOp('deleteItem', {'id': 'a'}));
      await store.enqueue(const PendingOp('deleteItem', {'id': 'b'}));
      final q = await store.loadPending();
      expect(q.map((o) => o.id).toSet().length, 2);
      expect(q.every((o) => o.id.isNotEmpty), isTrue);

      // An op queued while another one is being applied must survive its removal.
      await store.enqueue(const PendingOp('deleteItem', {'id': 'c'}));
      await store.removePending(q.first.id);
      final left = await store.loadPending();
      expect(left.map((o) => o.args['id']), ['b', 'c']);
    });

    test('concurrent enqueues do not lose operations', () async {
      final store = OfflineStore('u1');
      await Future.wait([
        for (var i = 0; i < 20; i++)
          store.enqueue(PendingOp('deleteItem', {'id': '$i'})),
      ]);
      expect((await store.loadPending()).length, 20);
    });

    test('a parked op leaves the queue and is listed as failed', () async {
      final store = OfflineStore('u1');
      await store.enqueue(const PendingOp('updateItem', {'id': 'a'}));
      await store.enqueue(const PendingOp('deleteItem', {'id': 'b'}));
      final first = (await store.loadPending()).first;
      await store.parkFailed(first, 'boom');
      expect((await store.loadPending()).single.type, 'deleteItem');
      final failed = await store.loadFailed();
      expect(failed.single.type, 'updateItem');
      expect(failed.single.error, 'boom');
    });

    test('queue saved by an older build gets ids', () async {
      await OfflineStore('u1').savePending([
        const PendingOp('deleteItem', {'id': 'a'}),
      ]);
      final q = await OfflineStore('u1').loadPending();
      expect(q.single.id, isNotEmpty);
      expect((await OfflineStore('u1').loadPending()).single.id, q.single.id);
    });

    test('clear wipes snapshot, queue and failed list', () async {
      final store = OfflineStore('u1');
      await store.enqueue(const PendingOp('deleteItem', {'id': 'a'}));
      await store.saveFailed([
        const PendingOp('updateItem', {'id': 'b'}),
      ]);
      await store.clear();
      expect(await store.loadPending(), isEmpty);
      expect(await store.loadFailed(), isEmpty);
    });
  });

  group('calendar-day rules', () {
    final now = DateTime(2026, 10, 25, 15, 30);

    test('daysBetweenToday ignores the time of day', () {
      expect(daysBetweenToday(DateTime(2026, 10, 25), now: now), 0);
      expect(daysBetweenToday(DateTime(2026, 10, 24, 23, 59), now: now), -1);
      expect(daysBetweenToday(DateTime(2026, 10, 26), now: now), 1);
    });

    test('item expiring today is not expired, yesterday is', () {
      final today = DateTime.now();
      final d = DateTime(today.year, today.month, today.day);
      Item at(DateTime e) => Item(name: 'x', boxId: 'b', expiryDate: e);
      expect(at(d).isExpired, isFalse);
      expect(at(d).daysUntilExpiry, 0);
      expect(at(d.subtract(const Duration(days: 1))).isExpired, isTrue);
      expect(at(DateTime(d.year, d.month, d.day + 1)).isExpired, isFalse);
    });

    test('a loan due today is not overdue, due yesterday is', () {
      final today = DateTime.now();
      final d = DateTime(today.year, today.month, today.day);
      LendingRecord due(DateTime e) =>
          LendingRecord(itemId: 'i', borrowerName: 'An', expectedReturnDate: e);
      expect(due(d).isOverdue, isFalse);
      expect(due(DateTime(d.year, d.month, d.day - 1)).isOverdue, isTrue);
      expect(due(DateTime(d.year, d.month, d.day + 1)).isOverdue, isFalse);
    });

    test('warranty uses the same convention', () {
      final today = DateTime.now();
      final d = DateTime(today.year, today.month, today.day);
      final item = Item(name: 'x', boxId: 'b', warrantyExpiryDate: d);
      expect(item.isWarrantyExpired, isFalse);
      expect(item.daysUntilWarrantyExpiry, 0);
    });
  });

  group('partial loans and low stock', () {
    test('lent quantity still counts as stock', () {
      final item = Item.fromJson({
        'id': 'i',
        'name': 'Cable',
        'boxId': 'b',
        'quantity': 1,
        'minQuantity': 3,
        'lentQuantity': 4,
      });
      expect(item.lentQuantity, 4);
      expect(item.isLowStock, isFalse);
      expect(item.copyWith(quantity: 0).lentQuantity, 4);
      expect(Item.fromJson(item.toJson()).lentQuantity, 4);
    });

    test('copyWith keeps the server updatedAt used for conflict checks', () {
      final at = DateTime.utc(2026, 1, 2, 3, 4, 5);
      final item = Item(name: 'x', boxId: 'b', updatedAt: at);
      expect(item.copyWith(name: 'y').updatedAt, at);
    });
  });
}
