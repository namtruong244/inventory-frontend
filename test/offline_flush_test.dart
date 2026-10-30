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

  /// Requests never answer (weak signal): only the caller's timeout ends them.
  bool hang = false;

  /// Thrown by [getAllItems] when set.
  Object? itemsError;

  /// [getBoxes] answers with an empty list (a genuinely empty account).
  bool noBoxes = false;
  int boxesFetched = 0;
  int boxesCreated = 0;

  /// What the "server" holds; [getAllItems] and [getItemById] answer from it.
  List<Item> serverItems = [];

  /// Thrown by item create/update/move when set.
  Object? mutationError;

  /// Thrown by [createBox] when set (a non-ApiException counts as a rejected request).
  Object? boxError;
  Future<void> Function(String name) onCreateCategory = (_) async {};
  final created = <String>[];

  @override
  Future<void> init() async {}

  @override
  bool get isAuthenticated => true;

  @override
  User? get currentUser => User(id: 'u1', name: 'T', email: 't@x.com');

  Future<void> _guard() async {
    if (hang) await Completer<void>().future;
    if (!reachable) throw const SocketException('offline');
  }

  @override
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParams}) async {
    await _guard();
    return <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> getSettings() async {
    await _guard();
    return {};
  }

  @override
  Future<List<Map<String, dynamic>>> getCategories() async {
    await _guard();
    return [];
  }

  @override
  Future<List<Box>> getBoxes({String? parentId, bool? tree}) async {
    await _guard();
    boxesFetched++;
    if (noBoxes) return [];
    // Non-empty so the provider does not auto-seed demo data.
    return [Box(name: 'Room', type: StorageType.room, label: 'R-1')];
  }

  @override
  Future<List<Item>> getAllItems({int pageSize = 200}) async {
    await _guard();
    if (itemsError != null) throw itemsError!;
    return List.of(serverItems);
  }

  @override
  Future<List<LendingRecord>> getActiveLoans() async {
    await _guard();
    return [];
  }

  @override
  Future<List<LendingRecord>> getOverdueLoans() async {
    await _guard();
    return [];
  }

  @override
  Future<Item> createItem(Item item) async {
    await _guard();
    if (mutationError != null) throw mutationError!;
    return item;
  }

  @override
  Future<Item> updateItem(Item item, {bool checkVersion = false}) async {
    await _guard();
    if (mutationError != null) throw mutationError!;
    return item;
  }

  @override
  Future<void> moveItem(String itemId, String targetBoxId) async {
    await _guard();
    if (mutationError != null) throw mutationError!;
  }

  @override
  Future<Item> getItemById(String itemId) async =>
      serverItems.firstWhere((i) => i.id == itemId);

  @override
  Future<Box> createBox(Box box) async {
    if (boxError != null) throw boxError!;
    boxesCreated++;
    return box;
  }

  final settingsSent = <Map<String, dynamic>>[];

  @override
  Future<Map<String, dynamic>> updateSettings(
    Map<String, dynamic> delta,
  ) async {
    await _guard();
    settingsSent.add(delta);
    return delta;
  }

  @override
  Future<Map<String, dynamic>> createCategory(String name) async {
    await _guard();
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

  group('weak connection', () {
    final cachedBox = Box(
      id: 'b1',
      name: 'Garage',
      type: StorageType.room,
      label: 'G-1',
    );
    final cachedItem = Item(id: 'i1', name: 'Drill', boxId: 'b1');

    Future<void> cache() => store.saveSnapshot(
      InventorySnapshot(
        boxes: [cachedBox],
        items: [cachedItem],
        loans: const [],
        categories: const ['Tools'],
      ),
    );

    test('cached data shows before the server answers', () async {
      await cache();
      final slow = FakeApi()..hang = true;
      final p = InventoryProvider(api: slow);
      addTearDown(p.dispose);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(p.items.map((i) => i.name), ['Drill']);
      expect(p.boxes.map((b) => b.name), ['Garage']);
      // Let the probe time out before the provider is disposed.
      await p.initializationFuture;
    });

    test(
      'a server that never answers ends up offline with the cache',
      () async {
        await cache();
        final slow = FakeApi()..hang = true;
        final p = InventoryProvider(api: slow);
        addTearDown(p.dispose);
        await p.initializationFuture;
        expect(p.isOffline, isTrue);
        expect(p.isConnected, isFalse);
        expect(p.items.map((i) => i.name), ['Drill']);
      },
    );

    test('a failed item fetch keeps the last good snapshot', () async {
      await cache();
      api.itemsError = const SocketException('dropped');
      await provider.fetchAllData();
      expect(provider.isOffline, isTrue);
      final snap = await store.loadSnapshot();
      expect(snap!.items.map((i) => i.name), ['Drill']);
      expect(provider.items.map((i) => i.name), ['Drill']);
    });

    test(
      'a rejected item fetch neither overwrites the cache nor seeds',
      () async {
        await cache();
        api.noBoxes = true;
        api.itemsError = status(400);
        await provider.fetchAllData();
        expect(api.boxesCreated, 0);
        final snap = await store.loadSnapshot();
        expect(snap!.items.map((i) => i.name), ['Drill']);
      },
    );

    test('an empty account stays empty: nothing is seeded', () async {
      api.noBoxes = true;
      await provider.fetchAllData();
      expect(provider.boxes, isEmpty);
      expect(provider.items, isEmpty);
      expect(api.boxesCreated, 0);
      expect(provider.isOffline, isFalse);
    });

    test('a complete fetch replaces the cache', () async {
      await cache();
      await provider.fetchAllData();
      expect(provider.isOffline, isFalse);
      final snap = await store.loadSnapshot();
      expect(snap!.boxes.map((b) => b.name), ['Room']);
      expect(snap.items, isEmpty);
    });
  });

  group('rejected mutations are undone', () {
    Future<void> seed(Item item) async {
      expect(await provider.addItem(item), isTrue);
    }

    test('a rejected create leaves no item behind', () async {
      api.mutationError = status(400);
      final ok = await provider.addItem(Item(id: 'i1', name: 'x', boxId: 'b1'));
      expect(ok, isFalse);
      expect(provider.items, isEmpty);
    });

    test('a rejected edit restores the previous item', () async {
      final item = Item(id: 'i1', name: 'old', boxId: 'b1');
      await seed(item);
      api.mutationError = status(400);
      final ok = await provider.updateItem(item.copyWith(name: 'new'));
      expect(ok, isFalse);
      expect(provider.items.single.name, 'old');
    });

    test('a rejected move puts the item back in its box', () async {
      await seed(Item(id: 'i1', name: 'x', boxId: 'b1'));
      api.mutationError = status(404);
      final ok = await provider.moveItem('i1', 'b2');
      expect(ok, isFalse);
      expect(provider.items.single.boxId, 'b1');
    });

    test('a 409 shows the server version instead of the stale edit', () async {
      final item = Item(id: 'i1', name: 'old', boxId: 'b1');
      await seed(item);
      api.serverItems = [Item(id: 'i1', name: 'from-server', boxId: 'b1')];
      api.mutationError = ApiException(
        statusCode: 409,
        code: 'CONFLICT',
        message: 'm',
      );
      final ok = await provider.updateItem(item.copyWith(name: 'mine'));
      expect(ok, isFalse);
      expect(provider.items.single.name, 'from-server');
    });

    test('a network error queues the edit and keeps it on screen', () async {
      final item = Item(id: 'i1', name: 'old', boxId: 'b1');
      await seed(item);
      api.mutationError = const SocketException('offline');
      final ok = await provider.updateItem(item.copyWith(name: 'new'));
      expect(ok, isTrue);
      expect(provider.items.single.name, 'new');
      expect(await pending(), 1);
    });
  });

  group('auto sync and settings', () {
    test(
      'a setting changed offline is queued, kept, and sent on resume',
      () async {
        api.reachable = false;
        await provider.setCurrency('€');
        expect(provider.currency, '€');
        expect(await pending(), 1);
        expect(api.settingsSent, isEmpty);
        expect((await store.loadSettings())?['currencySymbol'], '€');

        api.reachable = true;
        await provider.onAppResumed();
        expect(await pending(), 0);
        expect(api.settingsSent, [
          {'currencySymbol': '€'},
        ]);
        expect(provider.isOffline, isFalse);
      },
    );

    test('resume does nothing when online with an empty queue', () async {
      final before = api.boxesFetched;
      await provider.onAppResumed();
      expect(api.boxesFetched, before);
    });
  });
}
