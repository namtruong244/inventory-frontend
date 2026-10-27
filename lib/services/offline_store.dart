import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:uuid/uuid.dart';

import '../models/inventory_models.dart';

/// Last known inventory, kept on the device for offline browsing and scanning.
class InventorySnapshot {
  final List<Box> boxes;
  final List<Item> items;
  final List<LendingRecord> loans;
  final List<String> categories;

  const InventorySnapshot({
    required this.boxes,
    required this.items,
    required this.loans,
    required this.categories,
  });
}

/// A change made while the server was unreachable, replayed in order on the next sync.
class PendingOp {
  final String type;
  final Map<String, dynamic> args;

  /// Stable identity so a finished op can be removed without touching newer ones.
  /// Empty until the op is stored.
  final String id;

  /// Replays that failed for a reason that is not the server's answer (bad data).
  final int attempts;

  /// Why a parked op gave up, shown to the user. Only set on failed ops.
  final String? error;

  const PendingOp(
    this.type,
    this.args, {
    this.id = '',
    this.attempts = 0,
    this.error,
  });

  PendingOp copyWith({
    Map<String, dynamic>? args,
    String? id,
    int? attempts,
    String? error,
  }) => PendingOp(
    type,
    args ?? this.args,
    id: id ?? this.id,
    attempts: attempts ?? this.attempts,
    error: error ?? this.error,
  );

  Map<String, dynamic> toJson() => {
    'type': type,
    'args': args,
    'id': id,
    'attempts': attempts,
    'error': ?error,
  };

  factory PendingOp.fromJson(Map<String, dynamic> json) => PendingOp(
    json['type'] as String,
    Map<String, dynamic>.from(json['args'] as Map),
    id: json['id'] as String? ?? '',
    attempts: (json['attempts'] as num?)?.toInt() ?? 0,
    error: json['error'] as String?,
  );
}

/// Above this many records JSON work moves off the UI isolate.
const _isolateThreshold = 500;

String _encodeSnapshot(Map<String, dynamic> json) => jsonEncode(json);

Map<String, dynamic> _decodeSnapshot(String raw) =>
    jsonDecode(raw) as Map<String, dynamic>;

/// Device cache, keyed by user so accounts never see each other's data.
///
/// The queue of pending changes is small and lives in SharedPreferences. The
/// snapshot (thousands of items) is a JSON file in the app support directory:
/// SharedPreferences keeps its whole map in memory and rewrites it on each change,
/// and Android caps value sizes. Writes are coalesced (only the newest snapshot is
/// written while one is in flight), atomic (temp file + rename) and encoded off the
/// UI isolate. Where no directory is available the snapshot falls back to
/// SharedPreferences.
class OfflineStore {
  /// Where snapshot files go; null means "no filesystem, use SharedPreferences".
  @visibleForTesting
  static Future<Directory?> Function() directoryProvider = () async {
    try {
      return await getApplicationSupportDirectory();
    } catch (_) {
      return null;
    }
  };

  static final Map<String, InventorySnapshot> _queuedSnapshots = {};
  static final Map<String, Future<void>> _snapshotWriters = {};

  static const _snapshotKey = 'inventory_offline_snapshot';
  static const _pendingKey = 'inventory_offline_pending';
  static const _failedKey = 'inventory_offline_failed';

  // Read-modify-write on the queue must not interleave (enqueue vs. flush).
  static Future<void> _lock = Future.value();

  final String userId;
  OfflineStore(this.userId);

  String get _snapKey => '${_snapshotKey}_$userId';
  String get _pendKey => '${_pendingKey}_$userId';
  String get _failKey => '${_failedKey}_$userId';
  String get _settingsKey => 'inventory_offline_settings_$userId';

  /// Runs [fn] against the latest queue and saves what it returns, one caller at a time.
  Future<T> mutatePending<T>(T Function(List<PendingOp> queue) fn) {
    final run = _lock.then((_) async {
      final queue = await loadPending();
      final result = fn(queue);
      await savePending(queue);
      return result;
    });
    _lock = run.then((_) {}, onError: (_) {});
    return run;
  }

  /// Queues [op] behind the existing ones and returns the new queue length.
  Future<int> enqueue(PendingOp op) => mutatePending((q) {
    q.add(op.id.isEmpty ? op.copyWith(id: const Uuid().v4()) : op);
    return q.length;
  });

  /// Removes one finished op by id, leaving anything queued meanwhile intact.
  Future<int> removePending(String opId) => mutatePending((q) {
    q.removeWhere((o) => o.id == opId);
    return q.length;
  });

  /// Moves [op] from the queue to the failed list, with the reason.
  Future<int> parkFailed(PendingOp op, String reason) async {
    final left = await removePending(op.id);
    final failed = await loadFailed()
      ..add(op.copyWith(error: reason));
    await saveFailed(failed);
    return left;
  }

  Future<List<PendingOp>> loadFailed() => _loadList(_failKey);

  Future<void> saveFailed(List<PendingOp> list) => _saveList(_failKey, list);

  /// Drops this user's cached snapshot and queued operations.
  Future<void> clear() async {
    _queuedSnapshots.remove(userId);
    await _snapshotWriters[userId];
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_snapKey);
      await prefs.remove(_pendKey);
      await prefs.remove(_failKey);
      await prefs.remove(_settingsKey);
      final file = await _snapshotFile();
      if (file != null && await file.exists()) await file.delete();
    } catch (e) {
      debugPrint('clear offline store error: $e');
    }
  }

  /// Last known server-side settings (currency, units, warning days...).
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_settingsKey, jsonEncode(settings));
    } catch (e) {
      debugPrint('save settings error: $e');
    }
  }

  Future<Map<String, dynamic>?> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_settingsKey);
      if (raw == null) return null;
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }

  Future<File?> _snapshotFile() async {
    final dir = await directoryProvider();
    if (dir == null) return null;
    final safe = userId.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    return File(
      '${dir.path}${Platform.pathSeparator}offline_snapshot_$safe.json',
    );
  }

  /// Saves [s]. Calls made while a write is running are merged: only the latest
  /// snapshot is written next, and every caller's future completes after a write
  /// that includes its data.
  Future<void> saveSnapshot(InventorySnapshot s) {
    _queuedSnapshots[userId] = s;
    return _snapshotWriters[userId] ??= _drainSnapshots();
  }

  Future<void> _drainSnapshots() async {
    try {
      while (true) {
        final snap = _queuedSnapshots.remove(userId);
        if (snap == null) break;
        try {
          await _writeSnapshot(snap);
        } catch (e) {
          debugPrint('saveSnapshot error: $e');
        }
      }
    } finally {
      // Synchronous after the last emptiness check, so no save can slip in unseen.
      _snapshotWriters.remove(userId);
    }
  }

  Future<void> _writeSnapshot(InventorySnapshot s) async {
    // Maps are built synchronously: the provider's lists may change at the next await.
    final json = <String, dynamic>{
      'boxes': s.boxes.map((e) => e.toJson()).toList(),
      'items': s.items.map((e) => e.toJson()).toList(),
      'loans': s.loans.map((e) => e.toJson()).toList(),
      'categories': List<String>.of(s.categories),
    };
    // Small caches are cheaper to encode inline than to ship to another isolate.
    final big = s.items.length + s.boxes.length > _isolateThreshold;
    final raw = big
        ? await compute(_encodeSnapshot, json)
        : _encodeSnapshot(json);
    final file = await _snapshotFile();
    if (file == null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_snapKey, raw);
      return;
    }
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(raw, flush: true);
    await tmp.rename(file.path);
    // A snapshot from an older build lived in SharedPreferences.
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_snapKey)) await prefs.remove(_snapKey);
  }

  Future<InventorySnapshot?> loadSnapshot() async {
    try {
      await _snapshotWriters[userId];
      String? raw;
      final file = await _snapshotFile();
      if (file != null && await file.exists()) raw = await file.readAsString();
      if (raw == null) {
        final prefs = await SharedPreferences.getInstance();
        raw = prefs.getString(_snapKey);
      }
      if (raw == null) return null;
      final json = raw.length > _isolateThreshold * 500
          ? await compute(_decodeSnapshot, raw)
          : _decodeSnapshot(raw);
      List<T> parse<T>(String key, T Function(Map<String, dynamic>) f) =>
          ((json[key] as List?) ?? [])
              .map((e) => f(e as Map<String, dynamic>))
              .toList();
      return InventorySnapshot(
        boxes: parse('boxes', Box.fromJson),
        items: parse('items', Item.fromJson),
        loans: parse('loans', LendingRecord.fromJson),
        categories: ((json['categories'] as List?) ?? []).cast<String>(),
      );
    } catch (e) {
      debugPrint('loadSnapshot error: $e');
      return null;
    }
  }

  Future<List<PendingOp>> loadPending() async {
    final list = await _loadList(_pendKey);
    if (list.any((o) => o.id.isEmpty)) {
      // Queue written by an older build: give every op an id once.
      final withIds = [
        for (final o in list)
          o.id.isEmpty ? o.copyWith(id: const Uuid().v4()) : o,
      ];
      await _saveList(_pendKey, withIds);
      return withIds;
    }
    return list;
  }

  Future<void> savePending(List<PendingOp> list) => _saveList(_pendKey, list);

  Future<List<PendingOp>> _loadList(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      if (raw == null) return [];
      return (jsonDecode(raw) as List)
          .map((e) => PendingOp.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveList(String key, List<PendingOp> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (list.isEmpty) {
        await prefs.remove(key);
      } else {
        await prefs.setString(
          key,
          jsonEncode(list.map((e) => e.toJson()).toList()),
        );
      }
    } catch (e) {
      debugPrint('save ${key.split('_').last} error: $e');
    }
  }
}
