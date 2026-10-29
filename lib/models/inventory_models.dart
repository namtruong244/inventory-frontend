import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../l10n/l10n_ext.dart';
import '../theme/app_theme.dart';

/// Storage hierarchy type (Room -> Cabinet -> Shelf -> Box -> Drawer -> Other)
enum StorageType {
  room,
  cabinet,
  shelf,
  box,
  drawer,
  other;

  String get displayName {
    switch (this) {
      case StorageType.room:
        return AppL10n.current.storageTypeRoom;
      case StorageType.cabinet:
        return AppL10n.current.storageTypeCabinet;
      case StorageType.shelf:
        return AppL10n.current.storageTypeShelf;
      case StorageType.box:
        return AppL10n.current.storageTypeBox;
      case StorageType.drawer:
        return AppL10n.current.storageTypeDrawer;
      case StorageType.other:
        return AppL10n.current.storageTypeOther;
    }
  }

  IconData get icon {
    switch (this) {
      case StorageType.room:
        return Icons.meeting_room_outlined;
      case StorageType.cabinet:
        return Icons.kitchen_outlined;
      case StorageType.shelf:
        return Icons.shelves;
      case StorageType.box:
        return Icons.inventory_2_outlined;
      case StorageType.drawer:
        return Icons.inbox_outlined;
      case StorageType.other:
        return Icons.folder_outlined;
    }
  }
}

/// Item lifecycle & asset status
enum ItemStatus {
  stored,
  inUse,
  lent,
  broken,
  disposed,
  lost;

  String get displayName {
    switch (this) {
      case ItemStatus.stored:
        return AppL10n.current.statusStored;
      case ItemStatus.inUse:
        return AppL10n.current.statusInUse;
      case ItemStatus.lent:
        return AppL10n.current.statusLent;
      case ItemStatus.broken:
        return AppL10n.current.statusBroken;
      case ItemStatus.disposed:
        return AppL10n.current.statusDisposed;
      case ItemStatus.lost:
        return AppL10n.current.statusLost;
    }
  }

  Color get color {
    switch (this) {
      case ItemStatus.stored:
        return AppTones.matcha; // Emerald Green
      case ItemStatus.inUse:
        return AppTones.sky; // Blue
      case ItemStatus.lent:
        return AppTones.amber; // Amber Orange
      case ItemStatus.broken:
        return AppTones.coral; // Red
      case ItemStatus.disposed:
        return AppTones.slate; // Gray
      case ItemStatus.lost:
        return AppTones.lilac; // Violet
    }
  }

  IconData get icon {
    switch (this) {
      case ItemStatus.stored:
        return Icons.inventory_2_outlined;
      case ItemStatus.inUse:
        return Icons.play_circle_outline;
      case ItemStatus.lent:
        return Icons.assignment_ind_outlined;
      case ItemStatus.broken:
        return Icons.build_circle_outlined;
      case ItemStatus.disposed:
        return Icons.delete_sweep_outlined;
      case ItemStatus.lost:
        return Icons.help_outline;
    }
  }
}

/// Storage Location / Container Node in hierarchical tree
/// Whole calendar days from today (local) to [date]; negative when in the past.
int daysBetweenToday(DateTime date, {DateTime? now}) {
  final n = now ?? DateTime.now();
  final today = DateTime.utc(n.year, n.month, n.day);
  final target = DateTime.utc(date.year, date.month, date.day);
  return target.difference(today).inDays;
}

/// Parses a due date as a calendar day: the server stores it as UTC midnight, so
/// read the UTC fields instead of shifting into the device time zone.
DateTime? _calendarDay(dynamic raw) {
  if (raw is! String) return null;
  final d = DateTime.tryParse(raw);
  if (d == null) return null;
  return DateTime(d.year, d.month, d.day);
}

class Box {
  final String id;
  final String name;
  final StorageType type;
  final String description;
  final String label; // QR code identifier
  final String? parentId; // null for root location
  final String? icon;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Box({
    String? id,
    required this.name,
    this.type = StorageType.box,
    this.description = '',
    required this.label,
    this.parentId,
    this.icon,
    DateTime? createdAt,
    this.updatedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Box copyWith({
    String? id,
    String? name,
    StorageType? type,
    String? description,
    String? label,
    String? parentId,
    bool clearParent = false,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Box(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      label: label ?? this.label,
      parentId: clearParent ? null : (parentId ?? this.parentId),
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'description': description,
    'label': label,
    'parentId': parentId,
    'icon': icon,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory Box.fromJson(Map<String, dynamic> json) => Box(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    type: StorageType.values.firstWhere(
      (t) => t.name.toLowerCase() == (json['type']?.toString().toLowerCase()),
      orElse: () => StorageType.box,
    ),
    description: json['description'] ?? '',
    label: json['label'] ?? '',
    parentId: json['parentId'],
    icon: json['icon'],
    createdAt: json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
        : DateTime.now(),
    updatedAt: json['updatedAt'] != null
        ? DateTime.tryParse(json['updatedAt'])
        : null,
  );
}

/// Item Catalog & Asset Tracking Model
class Item {
  final String id;
  final String name;
  final String description;
  final String boxId; // Location ID where item is stored
  final String categoryId;
  final double quantity;
  final String unit; // pcs, set, box, kg, pack, etc.
  final List<String> photos;

  // Asset & Warranty
  final DateTime? purchaseDate;
  final double? purchasePrice;
  final String? serialNumber;
  final String? barcode; // UPC / EAN code
  final DateTime? warrantyExpiryDate;
  final List<String> receiptPhotos;

  // Status & Lifecycle
  final ItemStatus status;
  final bool isConsumable; // Consumable/perishable items consumed over time
  final DateTime?
  expiryDate; // Perishable expiration date (food, medicine, batteries)
  final double?
  minQuantity; // Minimum stock threshold before triggering low stock alert
  final Map<String, dynamic>
  customAttributes; // Flexible metadata (color, specs, size)

  /// Quantity currently out on partial loans (still owned, so it counts for stock).
  final double lentQuantity;

  final DateTime createdAt;
  final DateTime? updatedAt;

  Item({
    String? id,
    required this.name,
    this.description = '',
    required this.boxId,
    this.categoryId = 'General',
    this.quantity = 1.0,
    this.unit = 'pcs',
    List<String>? photos,
    this.purchaseDate,
    this.purchasePrice,
    this.serialNumber,
    this.barcode,
    this.warrantyExpiryDate,
    List<String>? receiptPhotos,
    this.status = ItemStatus.stored,
    this.isConsumable = false,
    this.expiryDate,
    double? minQuantity,
    double? lowStockThreshold,
    Map<String, dynamic>? customAttributes,
    this.lentQuantity = 0,
    DateTime? createdAt,
    this.updatedAt,
    String? imageUrl,
  }) : id = id ?? const Uuid().v4(),
       photos = photos ?? (imageUrl != null ? [imageUrl] : []),
       receiptPhotos = receiptPhotos ?? [],
       customAttributes = customAttributes ?? {},
       minQuantity = minQuantity ?? lowStockThreshold,
       createdAt = createdAt ?? DateTime.now();

  /// Backwards compatibility getter
  String? get imageUrl => photos.isNotEmpty ? photos.first : null;
  String get locationId => boxId;
  double? get lowStockThreshold => minQuantity;

  /// Low stock calculation per item
  /// Mirrors the backend: stock lent out on partial loans still counts.
  bool get isLowStock =>
      minQuantity != null && quantity + lentQuantity <= minQuantity!;

  /// Expiry calculations work on calendar days: an item expiring today is
  /// not expired yet and has 0 days left.
  bool get isExpired => expiryDate != null && daysBetweenToday(expiryDate!) < 0;

  int? get daysUntilExpiry =>
      expiryDate == null ? null : daysBetweenToday(expiryDate!);

  bool get isWarrantyExpired =>
      warrantyExpiryDate != null && daysBetweenToday(warrantyExpiryDate!) < 0;

  int? get daysUntilWarrantyExpiry =>
      warrantyExpiryDate == null ? null : daysBetweenToday(warrantyExpiryDate!);

  Item copyWith({
    String? id,
    String? name,
    String? description,
    String? boxId,
    String? categoryId,
    double? quantity,
    String? unit,
    List<String>? photos,
    DateTime? purchaseDate,
    double? purchasePrice,
    String? serialNumber,
    String? barcode,
    DateTime? warrantyExpiryDate,
    List<String>? receiptPhotos,
    ItemStatus? status,
    bool? isConsumable,
    DateTime? expiryDate,
    double? minQuantity,
    double? lowStockThreshold,
    bool clearMinQuantity = false,
    Map<String, dynamic>? customAttributes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      boxId: boxId ?? this.boxId,
      categoryId: categoryId ?? this.categoryId,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      photos: photos ?? this.photos,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      serialNumber: serialNumber ?? this.serialNumber,
      barcode: barcode ?? this.barcode,
      warrantyExpiryDate: warrantyExpiryDate ?? this.warrantyExpiryDate,
      receiptPhotos: receiptPhotos ?? this.receiptPhotos,
      status: status ?? this.status,
      isConsumable: isConsumable ?? this.isConsumable,
      expiryDate: expiryDate ?? this.expiryDate,
      minQuantity: clearMinQuantity
          ? null
          : (minQuantity ?? lowStockThreshold ?? this.minQuantity),
      customAttributes: customAttributes ?? this.customAttributes,
      lentQuantity: lentQuantity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'boxId': boxId,
    'categoryId': categoryId,
    'quantity': quantity,
    'unit': unit,
    'photos': photos,
    'purchaseDate': purchaseDate?.toIso8601String(),
    'purchasePrice': purchasePrice,
    'serialNumber': serialNumber,
    'barcode': barcode,
    'warrantyExpiryDate': warrantyExpiryDate?.toIso8601String(),
    'receiptPhotos': receiptPhotos,
    'status': status.name,
    'isConsumable': isConsumable,
    'expiryDate': expiryDate?.toIso8601String(),
    'minQuantity': minQuantity,
    'customAttributes': customAttributes,
    'lentQuantity': lentQuantity,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'imageUrl': imageUrl,
  };

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    boxId: json['boxId'] ?? json['locationId'] ?? '',
    categoryId: json['categoryId'] ?? 'General',
    quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
    unit: json['unit'] ?? 'pcs',
    photos:
        (json['photos'] as List?)?.map((e) => e.toString()).toList() ??
        (json['imageUrl'] != null ? [json['imageUrl'].toString()] : []),
    purchaseDate: json['purchaseDate'] != null
        ? DateTime.tryParse(json['purchaseDate'])
        : null,
    purchasePrice: (json['purchasePrice'] as num?)?.toDouble(),
    serialNumber: json['serialNumber'],
    barcode: json['barcode'],
    warrantyExpiryDate: json['warrantyExpiryDate'] != null
        ? DateTime.tryParse(json['warrantyExpiryDate'])
        : null,
    receiptPhotos:
        (json['receiptPhotos'] as List?)?.map((e) => e.toString()).toList() ??
        [],
    status: ItemStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => ItemStatus.stored,
    ),
    isConsumable: json['isConsumable'] as bool? ?? false,
    expiryDate: json['expiryDate'] != null
        ? DateTime.tryParse(json['expiryDate'])
        : null,
    minQuantity:
        (json['minQuantity'] as num?)?.toDouble() ??
        (json['lowStockThreshold'] as num?)?.toDouble(),
    customAttributes: json['customAttributes'] is Map
        ? Map<String, dynamic>.from(json['customAttributes'])
        : {},
    lentQuantity: (json['lentQuantity'] as num?)?.toDouble() ?? 0,
    createdAt: json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
        : DateTime.now(),
    updatedAt: json['updatedAt'] != null
        ? DateTime.tryParse(json['updatedAt'])
        : null,
  );
}

/// Lending & Borrowing Record
class LendingRecord {
  final String id;
  final String itemId;
  final String borrowerName;
  final String borrowerContact;
  final DateTime lentDate;
  final DateTime? expectedReturnDate;
  final DateTime? actualReturnDate;
  final String notes;
  final double quantity;
  final bool isPartial;

  LendingRecord({
    String? id,
    required this.itemId,
    required this.borrowerName,
    this.borrowerContact = '',
    DateTime? lentDate,
    this.expectedReturnDate,
    this.actualReturnDate,
    this.notes = '',
    this.quantity = 1,
    this.isPartial = false,
  }) : id = id ?? const Uuid().v4(),
       lentDate = lentDate ?? DateTime.now();

  bool get isActive => actualReturnDate == null;
  bool get isOverdue =>
      isActive &&
      expectedReturnDate != null &&
      daysBetweenToday(expectedReturnDate!) < 0;

  LendingRecord copyWith({
    String? id,
    String? itemId,
    String? borrowerName,
    String? borrowerContact,
    DateTime? lentDate,
    DateTime? expectedReturnDate,
    DateTime? actualReturnDate,
    String? notes,
    double? quantity,
    bool? isPartial,
  }) {
    return LendingRecord(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      borrowerName: borrowerName ?? this.borrowerName,
      borrowerContact: borrowerContact ?? this.borrowerContact,
      lentDate: lentDate ?? this.lentDate,
      expectedReturnDate: expectedReturnDate ?? this.expectedReturnDate,
      actualReturnDate: actualReturnDate ?? this.actualReturnDate,
      notes: notes ?? this.notes,
      quantity: quantity ?? this.quantity,
      isPartial: isPartial ?? this.isPartial,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'itemId': itemId,
    'borrowerName': borrowerName,
    'borrowerContact': borrowerContact,
    'lentDate': lentDate.toIso8601String(),
    'expectedReturnDate': expectedReturnDate?.toIso8601String(),
    'actualReturnDate': actualReturnDate?.toIso8601String(),
    'notes': notes,
    'quantity': quantity,
    'isPartial': isPartial,
  };

  factory LendingRecord.fromJson(Map<String, dynamic> json) => LendingRecord(
    id: json['id'] ?? '',
    itemId: json['itemId'] ?? '',
    borrowerName: json['borrowerName'] ?? '',
    borrowerContact: json['borrowerContact'] ?? '',
    lentDate: json['lentDate'] != null
        ? DateTime.tryParse(json['lentDate']) ?? DateTime.now()
        : DateTime.now(),
    expectedReturnDate: _calendarDay(json['expectedReturnDate']),
    actualReturnDate: json['actualReturnDate'] != null
        ? DateTime.tryParse(json['actualReturnDate'])
        : null,
    notes: json['notes'] ?? '',
    quantity: (json['quantity'] as num?)?.toDouble() ?? 1,
    isPartial: json['isPartial'] == true,
  );
}

/// Category Helper for asset categorization and dynamic icon resolution
class CategoryHelper {
  static const List<String> defaultCategories = [
    'Electronics',
    'Clothing',
    'Tools & Hardware',
    'Kitchen & Dining',
    'Medicine & Health',
    'Documents & Books',
    'Gaming & Media',
    'Office & Stationery',
    'Personal & Misc',
  ];

  static IconData getCategoryIcon(String category) {
    final lower = category.toLowerCase().trim();
    if (lower.contains('electr') ||
        lower.contains('tech') ||
        lower.contains('device') ||
        lower.contains('phone') ||
        lower.contains('cable') ||
        lower.contains('laptop') ||
        lower.contains('audio') ||
        lower.contains('camera')) {
      return Icons.devices_outlined;
    }
    if (lower.contains('cloth') ||
        lower.contains('fashion') ||
        lower.contains('wear') ||
        lower.contains('shoe') ||
        lower.contains('shirt') ||
        lower.contains('apparel')) {
      return Icons.checkroom_outlined;
    }
    if (lower.contains('tool') ||
        lower.contains('hardware') ||
        lower.contains('diy') ||
        lower.contains('repair') ||
        lower.contains('screw')) {
      return Icons.handyman_outlined;
    }
    if (lower.contains('kitchen') ||
        lower.contains('cook') ||
        lower.contains('dining') ||
        lower.contains('food') ||
        lower.contains('dish')) {
      return Icons.restaurant_outlined;
    }
    if (lower.contains('med') ||
        lower.contains('health') ||
        lower.contains('pill') ||
        lower.contains('pharma') ||
        lower.contains('drug') ||
        lower.contains('care')) {
      return Icons.medical_services_outlined;
    }
    if (lower.contains('doc') ||
        lower.contains('book') ||
        lower.contains('paper') ||
        lower.contains('read') ||
        lower.contains('file')) {
      return Icons.menu_book_outlined;
    }
    if (lower.contains('game') ||
        lower.contains('media') ||
        lower.contains('play') ||
        lower.contains('toy') ||
        lower.contains('console')) {
      return Icons.sports_esports_outlined;
    }
    if (lower.contains('office') ||
        lower.contains('station') ||
        lower.contains('work') ||
        lower.contains('pen') ||
        lower.contains('desk')) {
      return Icons.edit_note_outlined;
    }
    if (lower.contains('bag') ||
        lower.contains('backpack') ||
        lower.contains('travel') ||
        lower.contains('luggage')) {
      return Icons.luggage_outlined;
    }
    if (lower.contains('sport') ||
        lower.contains('gym') ||
        lower.contains('fitness') ||
        lower.contains('bike')) {
      return Icons.fitness_center_outlined;
    }
    if (lower.contains('music') || lower.contains('instrument')) {
      return Icons.music_note_outlined;
    }
    if (lower.contains('art') ||
        lower.contains('craft') ||
        lower.contains('paint')) {
      return Icons.palette_outlined;
    }
    if (lower.contains('jewelry') ||
        lower.contains('watch') ||
        lower.contains('gold')) {
      return Icons.watch_outlined;
    }
    return Icons.category_outlined;
  }
}

/// User Account Model from Auth API
class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? avatarUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'Owner',
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    role: json['role'] ?? 'Owner',
    avatarUrl: json['avatarUrl'] ?? json['avatar_url'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
    if (avatarUrl != null) 'avatarUrl': avatarUrl,
  };
}

/// Inventory Health summary for Reports & Audit
class InventoryHealth {
  final int totalAssetsCount;
  final double totalEstimatedValue;
  final int storedCount;
  final int inUseCount;
  final int lentCount;
  final int lowStockCount;
  final int expiredCount;
  final int expiringSoonCount;
  final int storageLocationsCount;

  InventoryHealth({
    required this.totalAssetsCount,
    required this.totalEstimatedValue,
    required this.storedCount,
    required this.inUseCount,
    required this.lentCount,
    required this.lowStockCount,
    required this.expiredCount,
    required this.expiringSoonCount,
    required this.storageLocationsCount,
  });

  factory InventoryHealth.fromJson(Map<String, dynamic> json) {
    final breakdown = json['breakdown'] is Map ? json['breakdown'] as Map : {};
    return InventoryHealth(
      totalAssetsCount: (json['totalAssetsCount'] as num?)?.toInt() ?? 0,
      totalEstimatedValue:
          (json['totalEstimatedValue'] as num?)?.toDouble() ?? 0.0,
      storedCount: (breakdown['stored'] as num?)?.toInt() ?? 0,
      inUseCount: (breakdown['inUse'] as num?)?.toInt() ?? 0,
      lentCount: (breakdown['lent'] as num?)?.toInt() ?? 0,
      lowStockCount: (breakdown['lowStock'] as num?)?.toInt() ?? 0,
      expiredCount: (breakdown['expired'] as num?)?.toInt() ?? 0,
      expiringSoonCount: (breakdown['expiringSoon'] as num?)?.toInt() ?? 0,
      storageLocationsCount:
          (json['storageLocationsCount'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Smart QR / Barcode Scan Result from /scan/lookup
class ScanLookupResult {
  final String type; // 'box' or 'item' or 'unknown'
  final Map<String, dynamic> payload;

  ScanLookupResult({required this.type, required this.payload});

  bool get isBox => type == 'box';
  bool get isItem => type == 'item';
  String get id => payload['id']?.toString() ?? '';
  String get name => payload['name']?.toString() ?? '';

  factory ScanLookupResult.fromJson(Map<String, dynamic> json) =>
      ScanLookupResult(
        type: json['type']?.toString() ?? 'unknown',
        payload: json['payload'] is Map<String, dynamic>
            ? json['payload'] as Map<String, dynamic>
            : {},
      );
}

/// One row of an item's stock audit trail (`GET /items/:id/movements`).
class StockMovement {
  final String id;
  final double delta;
  final double quantityAfter;
  final String reason;
  final String note;
  final DateTime createdAt;

  const StockMovement({
    required this.id,
    required this.delta,
    required this.quantityAfter,
    required this.reason,
    required this.note,
    required this.createdAt,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) => StockMovement(
    id: json['id'] as String,
    delta: (json['delta'] as num?)?.toDouble() ?? 0,
    quantityAfter: (json['quantityAfter'] as num?)?.toDouble() ?? 0,
    reason: json['reason'] as String? ?? 'adjust',
    note: json['note'] as String? ?? '',
    createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
  );
}

class StockHistory {
  final List<StockMovement> movements;
  final double avgDailyConsumption30d;
  final double? estimatedDaysLeft;

  const StockHistory({
    required this.movements,
    required this.avgDailyConsumption30d,
    this.estimatedDaysLeft,
  });

  factory StockHistory.fromJson(Map<String, dynamic> json) => StockHistory(
    movements: ((json['movements'] as List?) ?? const [])
        .map((e) => StockMovement.fromJson(e as Map<String, dynamic>))
        .toList(),
    avgDailyConsumption30d:
        (json['avgDailyConsumption30d'] as num?)?.toDouble() ?? 0,
    estimatedDaysLeft: (json['estimatedDaysLeft'] as num?)?.toDouble(),
  );
}
