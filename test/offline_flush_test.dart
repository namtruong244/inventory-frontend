import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:inventory/models/inventory_models.dart';
import 'package:inventory/providers/inventory_provider.dart';
import 'package:inventory/services/api_service.dart';
import 'package:inventory/services/offline_store.dart';
import 'package:inventory/services/sync_policy.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Server stand-in. [reachable] decides whether reads work; [onCreateCategory]
/// scripts how replayed `createCategory` ops are answered.
class FakeApi extends ApiService {
  bool reachable = true;
  Future<void> Function(String name) onCreateCategory = (_) async {};
  final created = <String>[];

  @override
  Future<void> init() async {}

  @override
  bool get isAuthenticated => true;

  @override
  User? get currentUser => User(id: 'u1', name: 'T', email: 't@x.com');

  void _guard() {
    if (!reachable) throw const SocketException('offline');
  }

  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParams}) async {
    _guard();
    return <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> getSettings() async {
    _guard();
    return {};
  }

  @override
  Future<List<Map<String, dynamic>>> getCategories() async {
    _guard();
    return [];
  }

  @override
  Future<List<Box>> getBoxes({String? parentId, bool? tree}) async {
    _guard();
    // Non-empty so the provider does not auto-seed demo data.
    return [Box(name: 'Room', type: StorageType.room, label: 'R-1')];
  }

  @override
  Future<List<Item>> getAllItems({int pageSize = 200}) async {
    _guard();
    return [];
  }

  @override
  Future<List<LendingRecord>> getActiveLoans() async {
    _guard();
    return [];
  }

  @override
  Future<List<LendingRecord>> getOverdueLoans() async {
    _guard();
    return [];
  }

  @override
  Future<Map<String, dynamic>> createCategory(String name) async {
    _guard();
    await onCreateCategory(name);
    created.add(name);
    return {'name': name};
  }
}

ApiException status(int code) =>
    ApiException(statusCode: code, code: 'X', message: 'm');

void main() {
  late FakeApi api;
  late InventoryProvider provider;
  final store = OfflineStore('u1');

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    OfflineStore.directoryProvider = () async => null;
    api = FakeApi();
    provider = InventoryProvider(api: api);
    await provider.initializationFuture;
  });

  tearDown(() => provider.dispose());

  Future<int> pending() async => (await store.loadPending()).length;

  Future<void> queue(String name) =>
      store.enqueue(PendingOp('createCategory', {'name': name}));

  test('network error keeps the op and its order', () async {
    api.reachable = false;
    await queue('a');
    await queue('b');
    await provider.fetchAllData();
    expect(await pending(), 2);
    expect(api.created, isEmpty);
  });

  test('business 4xx drops the op and continues with the next', () async {
    api.onCreateCategory = (n) async {
      if (n == 'bad') throw status(400);
    };
    await queue('bad');
    await queue('good');
    await provider.fetchAllData();
    expect(await pending(), 0);
    expect(api.created, ['good']);
    expect(provider.failedOps, isEmpty);
  });

  test('5xx keeps the op and stops the flush', () async {
    api.onCreateCategory = (n) async => throw status(503);
    await queue('a');
    await queue('b');
    await provider.fetchAllData();
    expect(await pending(), 2);
  });

  test('401 keeps the whole queue', () async {
    api.onCreateCategory = (n) async => throw status(401);
    await queue('a');
    await provider.fetchAllData();
    expect(await pending(), 1);
  });

  test('an op queued while flushing survives and is replayed', () async {
    final gate = Completer<void>();
    final started = Completer<void>();
    api.onCreateCategory = (n) async {
      if (n == 'first') {
        started.complete();
        await gate.future;
      }
    };
    await queue('first');
    final flush = provider.fetchAllData();
    await started.future;
    await queue('second'); // arrives mid-flush
    gate.complete();
    await flush;
    expect(api.created, ['first', 'second']);
    expect(await pending(), 0);
  });

  test(
    'poison op is retried then parked, without blocking later ops',
    () async {
      // Missing "name": the replay throws a cast error, not a server answer.
      await store.enqueue(const PendingOp('createCategory', {}));
      await queue('after');
      for (var i = 0; i < maxPoisonAttempts; i++) {
        await provider.fetchAllData();
      }
      expect(provider.failedOps.single.type, 'createCategory');
      expect(provider.failedOps.single.error, isNotNull);
      expect(await pending(), 0);
      expect(api.created, ['after']);
    },
  );
}
