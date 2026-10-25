import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  const PendingOp(this.type, this.args);

  Map<String, dynamic> toJson() => {'type': type, 'args': args};

  factory PendingOp.fromJson(Map<String, dynamic> json) => PendingOp(
    json['type'] as String,
    Map<String, dynamic>.from(json['args'] as Map),
  );
}

/// SharedPreferences-backed cache, keyed by user so accounts never see each other's data.
class OfflineStore {
  static const _snapshotKey = 'inventory_offline_snapshot';
  static const _pendingKey = 'inventory_offline_pending';

  final String userId;
  OfflineStore(this.userId);

  String get _snapKey => '${_snapshotKey}_$userId';
  String get _pendKey => '${_pendingKey}_$userId';

  Future<void> saveSnapshot(InventorySnapshot s) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _snapKey,
        jsonEncode({
          'boxes': s.boxes.map((e) => e.toJson()).toList(),
          'items': s.items.map((e) => e.toJson()).toList(),
          'loans': s.loans.map((e) => e.toJson()).toList(),
          'categories': s.categories,
        }),
      );
    } catch (e) {
      debugPrint('saveSnapshot error: $e');
    }
  }

  Future<InventorySnapshot?> loadSnapshot() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_snapKey);
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
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
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_pendKey);
      if (raw == null) return [];
      return (jsonDecode(raw) as List)
          .map((e) => PendingOp.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> savePending(List<PendingOp> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (list.isEmpty) {
        await prefs.remove(_pendKey);
      } else {
        await prefs.setString(
          _pendKey,
          jsonEncode(list.map((e) => e.toJson()).toList()),
        );
      }
    } catch (e) {
      debugPrint('savePending error: $e');
    }
  }
}
