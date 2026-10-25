import 'package:flutter/foundation.dart';
import '../models/inventory_models.dart';
import '../services/api_service.dart';
import '../utils/formatters.dart';

class InventoryProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  final List<Box> _boxes = [];
  final List<Item> _items = [];
  final List<LendingRecord> _lendingRecords = [];
  final List<String> _categories = List.from(CategoryHelper.defaultCategories);

  List<Box> get boxes => List.unmodifiable(_boxes);
  List<Item> get items => List.unmodifiable(_items);
  List<LendingRecord> get lendingRecords => List.unmodifiable(_lendingRecords);
  List<String> get categories => List.unmodifiable(_categories);

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ApiService get api => _apiService;
  User? get currentUser => _apiService.currentUser;
  String get serverUrl => _apiService.baseUrl;
  bool get isAuthenticated => _apiService.isAuthenticated;
  String get userEmail => _apiService.currentUser?.email ?? '';
  String? get userAvatarUrl => _apiService.currentUser?.avatarUrl;

  // User Profile
  String _userName = 'Guest';
  String _userRole = 'Owner';
  String get userName => _userName;
  String get userRole => _userRole;

  // Preferences & Settings
  String _currency = '\$';
  String _defaultUnit = 'pcs';
  int _expiryWarningDays = 30;
  int _warrantyWarningDays = 30;
  String _timezone = 'UTC';
  int _lowStockThreshold = 2;
  bool _vibrateOnScan = true;
  bool _beepOnScan = true;
  bool _autoOpenOnScan = true;
  bool _notifyExpiring = true;
  bool _notifyOverdue = true;
  bool _notifyLowStock = true;

  String get currency => _currency;
  String get defaultUnit => _defaultUnit;

  /// Helper to format a monetary value according to the current active currency symbol.
  String formatPrice(num? price) => AppFormatters.formatCurrency(price, _currency);

  /// Helper to format quantity and unit with correct English pluralization.
  String formatQty(num qty, String unit) => AppFormatters.formatQuantity(qty, unit);
  int get expiryWarningDays => _expiryWarningDays;
  int get warrantyWarningDays => _warrantyWarningDays;
  String get timezone => _timezone;
  int get lowStockThreshold => _lowStockThreshold;
  bool get vibrateOnScan => _vibrateOnScan;
  bool get beepOnScan => _beepOnScan;
  bool get autoOpenOnScan => _autoOpenOnScan;
  bool get notifyExpiring => _notifyExpiring;
  bool get notifyOverdue => _notifyOverdue;
  bool get notifyLowStock => _notifyLowStock;

  Future<void>? _initFuture;
  Future<void> get initializationFuture => _initFuture ?? Future.value();

  String _initStatus = 'Initializing...';
  String get initStatus => _initStatus;

  InventoryProvider() {
    _initFuture = _initialize();
  }

  // ==========================================
  // INITIALIZATION & AUTHENTICATION
  // ==========================================

  Future<void> _initialize() async {
    _isLoading = true;
    _initStatus = 'Connecting to server...';
    notifyListeners();

    try {
      await _apiService.init();

      _initStatus = 'Authenticating...';
      notifyListeners();

      // Check existing authenticated session
      await _ensureAuthenticated();

      if (_apiService.isAuthenticated) {
        _initStatus = 'Syncing inventory...';
        notifyListeners();

        // Load all data from backend
        await fetchAllData();
        _initStatus = 'Ready';
      } else {
        _initStatus = 'Ready';
      }
      notifyListeners();
      // Brief pause for visual smoothness
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      debugPrint('Initialization error: $e');
      _initStatus = 'Ready';
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _ensureAuthenticated() async {
    if (_apiService.isAuthenticated) {
      try {
        final me = await _apiService.getMe();
        _userName = me.name;
        _userRole = me.role;
        _isConnected = true;
        _errorMessage = null;
        return;
      } catch (e) {
        debugPrint('Token check or getMe failed: $e. Using cached user if present...');
        if (_apiService.currentUser != null) {
          _userName = _apiService.currentUser!.name;
          _userRole = _apiService.currentUser!.role;
          _isConnected = true;
          _errorMessage = null;
          return;
        }
      }
    }
  }

  /// Change server URL and reconnect
  Future<void> setServerUrl(String newUrl) async {
    await _apiService.setBaseUrl(newUrl);
    await _apiService.clearSession();
    _initFuture = _initialize();
    await _initFuture;
  }

  /// Explicit login with custom credentials
  Future<bool> login(String email, String password) async {
    _isSyncing = true;
    notifyListeners();
    try {
      final res = await _apiService.login(email, password);
      final user = res['user'] as User;
      _userName = user.name;
      _userRole = user.role;
      _isConnected = true;
      _errorMessage = null;
      await fetchAllData();
      return true;
    } catch (e) {
      _errorMessage = 'Login failed: $e';
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Sign in with Google (Gmail)
  Future<bool> loginWithGoogle({
    required String email,
    required String name,
    String? avatarUrl,
    String? idToken,
    String? accessToken,
  }) async {
    _isSyncing = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final res = await _apiService.loginWithGoogle(
        email: email,
        name: name,
        avatarUrl: avatarUrl,
        idToken: idToken,
        accessToken: accessToken,
      );
      final user = res['user'] as User;
      _userName = user.name;
      _userRole = user.role;
      _isConnected = true;
      _errorMessage = null;
      await fetchAllData();
      return true;
    } catch (e) {
      _errorMessage = 'Google sign-in failed: $e';
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Register new user account
  Future<bool> register(String name, String email, String password) async {
    _isSyncing = true;
    notifyListeners();
    try {
      final res = await _apiService.register(name, email, password);
      final user = res['user'] as User;
      _userName = user.name;
      _userRole = user.role;
      _isConnected = true;
      _errorMessage = null;
      await fetchAllData();
      return true;
    } catch (e) {
      _errorMessage = 'Registration failed: $e';
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Logout and clear user session
  Future<void> logout() async {
    await _apiService.clearSession();
    _boxes.clear();
    _items.clear();
    _lendingRecords.clear();
    _isConnected = false;
    _userName = 'Guest';
    _userRole = 'Owner';
    _errorMessage = null;
    notifyListeners();
  }

  // ==========================================
  // SYNC ALL DATA FROM BACKEND
  // ==========================================

  Future<void> fetchAllData() async {
    if (!_apiService.isAuthenticated) return;

    _isSyncing = true;
    notifyListeners();

    try {
      // 1. Settings
      try {
        final settings = await _apiService.getSettings();
        if (settings['currencySymbol'] != null) {
          _currency = settings['currencySymbol'];
        }
        if (settings['defaultUnit'] != null) {
          _defaultUnit = settings['defaultUnit'];
        }
        if (settings['expiryWarningDays'] != null) {
          _expiryWarningDays = (settings['expiryWarningDays'] as num).toInt();
        }
        if (settings['warrantyWarningDays'] != null) {
          _warrantyWarningDays = (settings['warrantyWarningDays'] as num).toInt();
        }
        if (settings['timezone'] != null) {
          _timezone = settings['timezone'] as String;
        }
        if (settings['notifyExpiring'] != null) {
          _notifyExpiring = settings['notifyExpiring'];
        }
        if (settings['notifyOverdue'] != null) {
          _notifyOverdue = settings['notifyOverdue'];
        }
        if (settings['notifyLowStock'] != null) {
          _notifyLowStock = settings['notifyLowStock'];
        }
        if (settings['vibrateOnScan'] != null) {
          _vibrateOnScan = settings['vibrateOnScan'];
        }
        if (settings['autoOpenOnScan'] != null) {
          _autoOpenOnScan = settings['autoOpenOnScan'];
        }
      } catch (e) {
        debugPrint('Fetch settings error: $e');
      }

      // 2. Categories
      try {
        final catList = await _apiService.getCategories();
        _categories.clear();
        for (final c in catList) {
          final name = c['name']?.toString();
          if (name != null && name.isNotEmpty && !_categories.contains(name)) {
            _categories.add(name);
          }
        }
        // Ensure defaults exist
        for (final def in CategoryHelper.defaultCategories) {
          if (!_categories.contains(def)) {
            _categories.add(def);
          }
        }
      } catch (e) {
        debugPrint('Fetch categories error: $e');
      }

      // 3. Boxes
      try {
        final boxList = await _apiService.getBoxes();
        _boxes.clear();
        _boxes.addAll(boxList);
      } catch (e) {
        debugPrint('Fetch boxes error: $e');
      }

      // 4. Items
      try {
        final itemList = await _apiService.getAllItems();
        _items.clear();
        _items.addAll(itemList);
      } catch (e) {
        debugPrint('Fetch items error: $e');
      }

      // 5. Lending records (active + overdue)
      try {
        final activeLoans = await _apiService.getActiveLoans();
        final overdueLoans = await _apiService.getOverdueLoans();
        _lendingRecords.clear();

        final Set<String> seenIds = {};
        for (final record in [...activeLoans, ...overdueLoans]) {
          if (!seenIds.contains(record.id)) {
            seenIds.add(record.id);
            _lendingRecords.add(record);
          }
        }

        // Also fetch history for lent items or items with loan records
        for (final item in _items) {
          if (item.status == ItemStatus.lent) {
            try {
              final hist = await _apiService.getLendingHistory(item.id);
              for (final h in hist) {
                if (!seenIds.contains(h.id)) {
                  seenIds.add(h.id);
                  _lendingRecords.add(h);
                }
              }
            } catch (_) {}
          }
        }
      } catch (e) {
        debugPrint('Fetch lending records error: $e');
      }

      _isConnected = true;
      _errorMessage = null;

      // If database is completely empty on first launch, auto-seed sample demo data
      if (_boxes.isEmpty && _items.isEmpty) {
        debugPrint('Database is empty, auto-seeding sample demo data to backend...');
        await seedBackendWithSampleData();
      }
    } catch (e) {
      debugPrint('fetchAllData error: $e');
      _isConnected = false;
      _errorMessage = 'Sync failed: $e';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  // ==========================================
  // PROFILE & SETTINGS
  // ==========================================

  Future<bool> updateUserProfile(String name, String role) async {
    final trimmedName = name.trim();
    final trimmedRole = role.trim();
    if (trimmedName.isNotEmpty) _userName = trimmedName;
    if (trimmedRole.isNotEmpty) _userRole = trimmedRole;
    notifyListeners();

    try {
      await _apiService.updateProfile(name: trimmedName, role: trimmedRole);
      return true;
    } catch (e) {
      debugPrint('updateProfile error: $e');
      return false;
    }
  }

  Future<void> setCurrency(String val) async {
    _currency = val;
    notifyListeners();
    try {
      await _apiService.updateSettings({'currencySymbol': val});
    } catch (e) {
      debugPrint('updateSettings error: $e');
    }
  }

  Future<void> setDefaultUnit(String val) async {
    _defaultUnit = val;
    notifyListeners();
    try {
      await _apiService.updateSettings({'defaultUnit': val});
    } catch (e) {
      debugPrint('updateSettings error: $e');
    }
  }

  Future<void> setExpiryWarningDays(int days) async {
    _expiryWarningDays = days;
    notifyListeners();
    try {
      await _apiService.updateSettings({'expiryWarningDays': days});
    } catch (e) {
      debugPrint('updateSettings error: $e');
    }
  }

  Future<void> setWarrantyWarningDays(int days) async {
    _warrantyWarningDays = days;
    notifyListeners();
    try {
      await _apiService.updateSettings({'warrantyWarningDays': days});
    } catch (e) {
      debugPrint('updateSettings error: $e');
    }
  }

  Future<void> setTimezone(String tz) async {
    _timezone = tz;
    notifyListeners();
    try {
      await _apiService.updateSettings({'timezone': tz});
    } catch (e) {
      debugPrint('updateSettings error: $e');
    }
  }

  void setLowStockThreshold(int val) {
    _lowStockThreshold = val;
    notifyListeners();
  }

  Future<void> setVibrateOnScan(bool val) async {
    _vibrateOnScan = val;
    notifyListeners();
    try {
      await _apiService.updateSettings({'vibrateOnScan': val});
    } catch (e) {
      debugPrint('updateSettings error: $e');
    }
  }

  void setBeepOnScan(bool val) {
    _beepOnScan = val;
    notifyListeners();
  }

  Future<void> setAutoOpenOnScan(bool val) async {
    _autoOpenOnScan = val;
    notifyListeners();
    try {
      await _apiService.updateSettings({'autoOpenOnScan': val});
    } catch (e) {
      debugPrint('updateSettings error: $e');
    }
  }

  Future<void> setNotifyExpiring(bool val) async {
    _notifyExpiring = val;
    notifyListeners();
    try {
      await _apiService.updateSettings({'notifyExpiring': val});
    } catch (e) {
      debugPrint('updateSettings error: $e');
    }
  }

  Future<void> setNotifyOverdue(bool val) async {
    _notifyOverdue = val;
    notifyListeners();
    try {
      await _apiService.updateSettings({'notifyOverdue': val});
    } catch (e) {
      debugPrint('updateSettings error: $e');
    }
  }

  Future<void> setNotifyLowStock(bool val) async {
    _notifyLowStock = val;
    notifyListeners();
    try {
      await _apiService.updateSettings({'notifyLowStock': val});
    } catch (e) {
      debugPrint('updateSettings error: $e');
    }
  }

  // ==========================================
  // MODULE 1: HIERARCHY & LOCATION MANAGEMENT
  // ==========================================

  Future<bool> addBox(Box box) async {
    try {
      final created = await _apiService.createBox(box);
      _boxes.add(created);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('createBox error: $e');
      // Optimistic fallback
      _boxes.add(box);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBox(Box updatedBox) async {
    final index = _boxes.indexWhere((b) => b.id == updatedBox.id);
    if (index != -1) {
      _boxes[index] = updatedBox;
      notifyListeners();
    }
    try {
      final res = await _apiService.updateBox(updatedBox);
      if (index != -1) {
        _boxes[index] = res;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('updateBox error: $e');
      return false;
    }
  }

  /// Returns true on success. On API failure the local state is restored.
  /// Without [cascade] the server refuses to delete a box that still has contents.
  Future<bool> deleteBox(String boxId, {bool cascade = false}) async {
    final boxesSnapshot = List<Box>.from(_boxes);
    final itemsSnapshot = List<Item>.from(_items);
    final loansSnapshot = List<LendingRecord>.from(_lendingRecords);

    final doomed = <String>{boxId};
    var frontier = <String>[boxId];
    while (frontier.isNotEmpty) {
      final children = _boxes
          .where((b) => b.parentId != null && frontier.contains(b.parentId))
          .map((b) => b.id)
          .where(doomed.add)
          .toList();
      frontier = children;
    }
    final removedItemIds =
        _items.where((i) => doomed.contains(i.boxId)).map((i) => i.id).toSet();
    _items.removeWhere((i) => removedItemIds.contains(i.id));
    _lendingRecords.removeWhere((l) => removedItemIds.contains(l.itemId));
    _boxes.removeWhere((b) => doomed.contains(b.id));
    notifyListeners();

    try {
      await _apiService.deleteBox(boxId, cascade: cascade);
      return true;
    } catch (e) {
      debugPrint('deleteBox error: $e');
      _boxes
        ..clear()
        ..addAll(boxesSnapshot);
      _items
        ..clear()
        ..addAll(itemsSnapshot);
      _lendingRecords
        ..clear()
        ..addAll(loansSnapshot);
      notifyListeners();
      return false;
    }
  }

  List<Box> getRootBoxes() {
    return _boxes.where((b) => b.parentId == null).toList();
  }

  List<Box> getBoxesIn(String parentId) {
    return _boxes.where((b) => b.parentId == parentId).toList();
  }

  Box? getBoxById(String id) {
    try {
      return _boxes.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  Box? getBoxByLabel(String label) {
    final query = label.toLowerCase().trim();
    try {
      return _boxes.firstWhere(
        (b) => b.label.toLowerCase() == query || b.id.toLowerCase() == query,
      );
    } catch (_) {
      return null;
    }
  }

  List<Box> getBreadcrumb(String locationId) {
    final List<Box> path = [];
    String? currentId = locationId;

    while (currentId != null) {
      final currentBox = getBoxById(currentId);
      if (currentBox == null) break;
      path.insert(0, currentBox);
      currentId = currentBox.parentId;
    }

    return path;
  }

  String getBreadcrumbString(String locationId) {
    final path = getBreadcrumb(locationId);
    if (path.isEmpty) return 'Unassigned';
    return path.map((b) => b.name).join(' › ');
  }

  bool canMoveLocation(String locationId, String? targetParentId) {
    if (targetParentId == null) return true;
    if (locationId == targetParentId) return false;

    String? current = targetParentId;
    while (current != null) {
      if (current == locationId) return false;
      final parent = getBoxById(current);
      current = parent?.parentId;
    }
    return true;
  }

  bool bulkMoveLocation(String locationId, String? newParentId) {
    if (!canMoveLocation(locationId, newParentId)) {
      return false;
    }

    final index = _boxes.indexWhere((b) => b.id == locationId);
    if (index != -1) {
      _boxes[index] = _boxes[index].copyWith(
        parentId: newParentId,
        clearParent: newParentId == null,
      );
      notifyListeners();
    }

    _apiService.moveBox(locationId, newParentId).catchError((e) {
      debugPrint('moveBox error: $e');
    });
    return true;
  }

  int countTotalItemsIn(String locationId) {
    int total = _items.where((i) => i.boxId == locationId).length;
    final subBoxes = getBoxesIn(locationId);
    for (var sub in subBoxes) {
      total += countTotalItemsIn(sub.id);
    }
    return total;
  }

  // ==========================================
  // MODULE 2: ITEM CATALOG & ASSET TRACKING
  // ==========================================

  Future<bool> addCategory(String category) async {
    final trimmed = category.trim();
    if (trimmed.isEmpty) return false;
    final exists = _categories.any((c) => c.toLowerCase() == trimmed.toLowerCase());
    if (!exists) {
      _categories.add(trimmed);
      notifyListeners();
      try {
        await _apiService.createCategory(trimmed);
      } catch (e) {
        debugPrint('createCategory error: $e');
      }
      return true;
    }
    return false;
  }

  Future<bool> deleteCategory(String category) async {
    final trimmed = category.trim();
    if (_categories.contains(trimmed)) {
      _categories.remove(trimmed);
      for (int i = 0; i < _items.length; i++) {
        if (_items[i].categoryId.toLowerCase() == trimmed.toLowerCase()) {
          _items[i] = _items[i].copyWith(categoryId: 'General');
        }
      }
      notifyListeners();
      try {
        await _apiService.deleteCategory(trimmed);
      } catch (e) {
        debugPrint('deleteCategory error: $e');
      }
      return true;
    }
    return false;
  }

  int getItemCountForCategory(String category) {
    return _items.where((i) => i.categoryId.toLowerCase() == category.toLowerCase()).length;
  }

  double get totalInventoryValue {
    return _items.fold(0.0, (sum, item) => sum + ((item.purchasePrice ?? 0.0) * item.quantity));
  }

  Future<bool> addItem(Item item) async {
    if (item.categoryId.isNotEmpty &&
        !_categories.any((c) => c.toLowerCase() == item.categoryId.toLowerCase())) {
      _categories.add(item.categoryId);
    }

    try {
      final created = await _apiService.createItem(item);
      _items.add(created);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('createItem error: $e');
      _items.add(item);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateItem(Item updatedItem) async {
    final index = _items.indexWhere((i) => i.id == updatedItem.id);
    if (index != -1) {
      if (updatedItem.categoryId.isNotEmpty &&
          !_categories.any((c) => c.toLowerCase() == updatedItem.categoryId.toLowerCase())) {
        _categories.add(updatedItem.categoryId);
      }
      _items[index] = updatedItem;
      notifyListeners();
    }

    try {
      final res = await _apiService.updateItem(updatedItem);
      if (index != -1) {
        _items[index] = res;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('updateItem error: $e');
      return false;
    }
  }

  Future<bool> deleteItem(String itemId) async {
    final itemsSnapshot = List<Item>.from(_items);
    final loansSnapshot = List<LendingRecord>.from(_lendingRecords);
    _items.removeWhere((i) => i.id == itemId);
    _lendingRecords.removeWhere((l) => l.itemId == itemId);
    notifyListeners();

    try {
      await _apiService.deleteItem(itemId);
      return true;
    } catch (e) {
      debugPrint('deleteItem error: $e');
      _items
        ..clear()
        ..addAll(itemsSnapshot);
      _lendingRecords
        ..clear()
        ..addAll(loansSnapshot);
      notifyListeners();
      return false;
    }
  }

  Future<bool> moveItem(String itemId, String newLocationId) async {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      _items[index] = _items[index].copyWith(boxId: newLocationId);
      notifyListeners();
    }

    try {
      await _apiService.moveItem(itemId, newLocationId);
      return true;
    } catch (e) {
      debugPrint('moveItem error: $e');
      return false;
    }
  }

  Future<StockHistory?> getItemMovements(String itemId) async {
    try {
      return await _apiService.getItemMovements(itemId);
    } catch (e) {
      debugPrint('getItemMovements error: $e');
      return null;
    }
  }

  Future<bool> updateItemQuantity(String itemId, double quantity,
      {String? reason}) async {
    final index = _items.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      notifyListeners();
    }

    try {
      await _apiService.updateItemQuantity(itemId, quantity, reason: reason);
      return true;
    } catch (e) {
      debugPrint('updateItemQuantity error: $e');
      return false;
    }
  }

  List<Item> getItemsIn(String boxId) {
    return _items.where((i) => i.boxId == boxId).toList();
  }

  Item? getItemById(String id) {
    try {
      return _items.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  Item? getItemByBarcode(String barcode) {
    final trimmed = barcode.trim().toLowerCase();
    try {
      return _items.firstWhere(
        (i) =>
            (i.barcode != null && i.barcode!.toLowerCase().trim() == trimmed) ||
            (i.serialNumber != null && i.serialNumber!.toLowerCase().trim() == trimmed) ||
            i.id.toLowerCase() == trimmed,
      );
    } catch (_) {
      return null;
    }
  }

  // ==========================================
  // MODULE 5: LIFECYCLE & EXPIRATION ALERTS
  // ==========================================

  List<Item> getExpiredItems() {
    return _items.where((i) => i.isExpired).toList();
  }

  List<Item> getExpiringItems({int withinDays = 30}) {
    final now = DateTime.now();
    return _items.where((i) {
      if (i.expiryDate == null || i.isExpired) return false;
      final diff = i.expiryDate!.difference(now).inDays;
      return diff >= 0 && diff <= withinDays;
    }).toList();
  }

  List<Item> getExpiringWarranties({int withinDays = 30}) {
    final now = DateTime.now();
    return _items.where((i) {
      if (i.warrantyExpiryDate == null || i.isWarrantyExpired) return false;
      final diff = i.warrantyExpiryDate!.difference(now).inDays;
      return diff >= 0 && diff <= withinDays;
    }).toList();
  }

  List<Item> getLowStockItems() {
    return _items.where((i) => i.isLowStock).toList();
  }

  int get totalAlertCount {
    return getExpiredItems().length +
        getExpiringItems(withinDays: _expiryWarningDays).length +
        getOverdueLoans().length +
        (_notifyLowStock ? getLowStockItems().length : 0);
  }

  // ==========================================
  // MODULE 6: LENDING & BORROWING TRACKER
  // ==========================================

  List<LendingRecord> getActiveLoans() {
    return _lendingRecords.where((l) => l.isActive).toList();
  }

  List<LendingRecord> getOverdueLoans() {
    return _lendingRecords.where((l) => l.isOverdue).toList();
  }

  List<LendingRecord> getLendingHistoryForItem(String itemId) {
    return _lendingRecords.where((l) => l.itemId == itemId).toList();
  }

  LendingRecord? getActiveLoanForItem(String itemId) {
    try {
      return _lendingRecords.firstWhere(
        (l) => l.itemId == itemId && l.isActive,
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> lendItem({
    required String itemId,
    required String borrowerName,
    String borrowerContact = '',
    required DateTime lentDate,
    DateTime? expectedReturnDate,
    String notes = '',
  }) async {
    final localRecord = LendingRecord(
      itemId: itemId,
      borrowerName: borrowerName,
      borrowerContact: borrowerContact,
      lentDate: lentDate,
      expectedReturnDate: expectedReturnDate,
      notes: notes,
    );
    _lendingRecords.add(localRecord);

    final itemIndex = _items.indexWhere((i) => i.id == itemId);
    if (itemIndex != -1) {
      _items[itemIndex] = _items[itemIndex].copyWith(status: ItemStatus.lent);
    }
    notifyListeners();

    try {
      final remoteRecord = await _apiService.lendItem(
        itemId: itemId,
        borrowerName: borrowerName,
        borrowerContact: borrowerContact,
        lentDate: lentDate,
        expectedReturnDate: expectedReturnDate,
        notes: notes,
      );
      // Replace with remote record
      final idx = _lendingRecords.indexOf(localRecord);
      if (idx != -1) {
        _lendingRecords[idx] = remoteRecord;
      }
      return true;
    } catch (e) {
      debugPrint('lendItem error: $e');
      return false;
    }
  }

  Future<bool> returnItem(String recordId, {String? newLocationId}) async {
    final recordIndex = _lendingRecords.indexWhere((l) => l.id == recordId);
    String? itemId;
    if (recordIndex != -1) {
      final record = _lendingRecords[recordIndex];
      itemId = record.itemId;
      _lendingRecords[recordIndex] = record.copyWith(actualReturnDate: DateTime.now());

      final itemIndex = _items.indexWhere((i) => i.id == record.itemId);
      if (itemIndex != -1) {
        _items[itemIndex] = _items[itemIndex].copyWith(
          status: ItemStatus.stored,
          boxId: newLocationId ?? _items[itemIndex].boxId,
        );
      }
      notifyListeners();
    }

    try {
      await _apiService.returnItem(recordId);
      if (newLocationId != null && itemId != null) {
        await _apiService.moveItem(itemId, newLocationId);
      }
      return true;
    } catch (e) {
      debugPrint('returnItem error: $e');
      return false;
    }
  }

  // ==========================================
  // MODULE 7: SCANNING & LOOKUP
  // ==========================================

  Future<ScanLookupResult?> lookupScanCode(String code) async {
    try {
      final res = await _apiService.lookupScan(code);
      if (res != null) {
        return ScanLookupResult.fromJson(res);
      }
    } catch (e) {
      debugPrint('lookupScanCode remote error: $e');
    }

    // Local fallback
    final box = getBoxByLabel(code);
    if (box != null) {
      return ScanLookupResult(type: 'box', payload: box.toJson());
    }
    final item = getItemByBarcode(code);
    if (item != null) {
      return ScanLookupResult(type: 'item', payload: item.toJson());
    }
    return null;
  }

  Future<String?> uploadMedia(String filePath, {String folder = 'items'}) async {
    try {
      return await _apiService.uploadMedia(filePath, folder: folder);
    } catch (e) {
      debugPrint('uploadMedia error: $e');
      return null;
    }
  }

  // ==========================================
  // MODULE 9: REPORTS & INVENTORY AUDIT
  // ==========================================

  Future<InventoryHealth?> fetchInventoryHealth() async {
    try {
      final data = await _apiService.getInventoryHealth();
      return InventoryHealth.fromJson(data);
    } catch (e) {
      debugPrint('getInventoryHealth error: $e');
      return null;
    }
  }

  String generateInventoryReport() {
    final buffer = StringBuffer();
    final now = DateTime.now();
    buffer.writeln('========================================');
    buffer.writeln('       INVENTORY STATUS REPORT');
    buffer.writeln(
        'Generated: ${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}');
    buffer.writeln('Manager: $_userName ($_userRole)');
    buffer.writeln('Server Backend: ${_apiService.baseUrl}');
    buffer.writeln('========================================\n');

    buffer.writeln('1. OVERVIEW STATISTICS:');
    buffer.writeln('- Total Storage Containers: ${_boxes.length}');
    buffer.writeln('- Total Inventory Items: ${_items.length}');
    buffer.writeln(
        '- Total Estimated Value: ${formatPrice(totalInventoryValue)}');
    buffer.writeln('- Active Lent Items: ${getActiveLoans().length}');
    buffer.writeln('- Overdue Lent Items: ${getOverdueLoans().length}');
    buffer.writeln('- Expired Items: ${getExpiredItems().length}');
    buffer.writeln(
        '- Expiring Soon (within $_expiryWarningDays days): ${getExpiringItems(withinDays: _expiryWarningDays).length}\n');

    buffer.writeln('2. CATEGORIES BREAKDOWN:');
    for (final cat in _categories) {
      final count = getItemCountForCategory(cat);
      buffer.writeln('- $cat: $count items');
    }
    buffer.writeln('');

    buffer.writeln('3. CURRENT INVENTORY ITEMS:');
    for (final item in _items) {
      final box = getBoxById(item.boxId);
      final priceStr = item.purchasePrice != null
          ? ' | Price: ${formatPrice(item.purchasePrice)}'
          : '';
      buffer.writeln(
          '- ${item.name} (${formatQty(item.quantity, item.unit)}$priceStr) -> [${box?.name ?? "No Location"}]');
    }

    buffer.writeln('\n========================================');
    buffer.writeln('End of report');
    return buffer.toString();
  }

  // ==========================================
  // SEED SAMPLE DATA TO BACKEND
  // ==========================================

  Future<bool> seedBackendWithSampleData() async {
    _isSyncing = true;
    notifyListeners();

    try {
      final now = DateTime.now();

      // Create hierarchy
      final f1 = await _apiService.createBox(Box(
        name: '1st Floor',
        type: StorageType.room,
        label: 'loc_floor_1',
        description: 'Main ground level of the residence',
      ));
      final f2 = await _apiService.createBox(Box(
        name: '2nd Floor',
        type: StorageType.room,
        label: 'loc_floor_2',
        description: 'Upper living and working quarters',
      ));
      final living = await _apiService.createBox(Box(
        name: 'Living Room',
        type: StorageType.room,
        parentId: f1.id,
        label: 'loc_living_room',
        description: 'Family entertainment area',
      ));
      final office = await _apiService.createBox(Box(
        name: 'Home Office',
        type: StorageType.room,
        parentId: f2.id,
        label: 'loc_home_office',
        description: 'Workspace and study room',
      ));
      final kitchen = await _apiService.createBox(Box(
        name: 'Kitchen & Pantry',
        type: StorageType.room,
        parentId: f1.id,
        label: 'loc_kitchen',
        description: 'Cooking and dry food storage',
      ));

      final mediaConsole = await _apiService.createBox(Box(
        name: 'TV Media Console',
        type: StorageType.cabinet,
        parentId: living.id,
        label: 'cab_media_01',
        description: 'Cabinet underneath OLED TV',
      ));
      final oakBookshelf = await _apiService.createBox(Box(
        name: 'Oak Bookshelf',
        type: StorageType.shelf,
        parentId: office.id,
        label: 'shelf_oak_01',
        description: 'Main library and tech shelf',
      ));
      final medCupboard = await _apiService.createBox(Box(
        name: 'First Aid Cabinet',
        type: StorageType.cabinet,
        parentId: kitchen.id,
        label: 'cab_med_01',
        description: 'Wall mounted medical cabinet',
      ));

      final elecBox = await _apiService.createBox(Box(
        name: 'Electronics & Cables Box',
        type: StorageType.box,
        parentId: oakBookshelf.id,
        label: 'elec_001',
        description: 'High-speed cables, adapters, chargers',
      ));
      final gamingDrawer = await _apiService.createBox(Box(
        name: 'Gaming Accessories Drawer',
        type: StorageType.drawer,
        parentId: mediaConsole.id,
        label: 'box_game_01',
        description: 'Controllers, headsets, cartridges',
      ));
      final emergencyBox = await _apiService.createBox(Box(
        name: 'Emergency Medical Box',
        type: StorageType.box,
        parentId: medCupboard.id,
        label: 'box_med_01',
        description: 'Bandages, ointments, daily supplies',
      ));

      _boxes.clear();
      _boxes.addAll([
        f1,
        f2,
        living,
        office,
        kitchen,
        mediaConsole,
        oakBookshelf,
        medCupboard,
        elecBox,
        gamingDrawer,
        emergencyBox,
      ]);

      // Create items
      final macbook = await _apiService.createItem(Item(
        name: 'MacBook Pro 14" M3',
        description: 'Space Black, 18GB Unified Memory, 512GB SSD',
        boxId: office.id,
        categoryId: 'Electronics',
        quantity: 1,
        unit: 'unit',
        photos: const [
          'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1611186871348-b1ce696e52c9?w=800&auto=format&fit=crop&q=80',
        ],
        receiptPhotos: const [
          'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=800&auto=format&fit=crop&q=80',
        ],
        purchaseDate: now.subtract(const Duration(days: 90)),
        purchasePrice: 1999.00,
        serialNumber: 'SN-MBP14-M3-9821',
        barcode: '194253714201',
        warrantyExpiryDate: now.add(const Duration(days: 275)),
        status: ItemStatus.inUse,
        customAttributes: {'Color': 'Space Black', 'RAM': '18GB'},
      ));

      final charger = await _apiService.createItem(Item(
        name: '65W GaN Dual USB-C Charger',
        description: 'Compact fast charger for laptop and mobile devices',
        boxId: elecBox.id,
        categoryId: 'Electronics',
        quantity: 2,
        minQuantity: 3, // Low stock: 2 <= 3
        unit: 'pcs',
        photos: const [
          'https://images.unsplash.com/photo-1583863788434-e58a36330cf0?w=800&auto=format&fit=crop&q=80',
        ],
        purchaseDate: now.subtract(const Duration(days: 60)),
        purchasePrice: 42.00,
        barcode: '6934177712345',
        warrantyExpiryDate: now.add(const Duration(days: 305)),
        status: ItemStatus.stored,
        customAttributes: {'Max Output': '65W', 'Ports': '2x USB-C'},
      ));

      final hdmi = await _apiService.createItem(Item(
        name: 'Ultra High-Speed HDMI 2.1 Cable (2m)',
        description: '8K@60Hz / 4K@120Hz Braided Nylon Cable',
        boxId: elecBox.id,
        categoryId: 'Electronics',
        quantity: 3,
        unit: 'pcs',
        photos: const [
          'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=800&auto=format&fit=crop&q=80',
        ],
        purchasePrice: 18.50,
        status: ItemStatus.stored,
        customAttributes: {'Length': '2 meters', 'Bandwidth': '48Gbps'},
      ));

      final ps5 = await _apiService.createItem(Item(
        name: 'Sony PS5 DualSense Controller',
        description: 'Midnight Black wireless gamepad with haptic feedback',
        boxId: gamingDrawer.id,
        categoryId: 'Gaming & Media',
        quantity: 1,
        unit: 'pcs',
        photos: const [
          'https://images.unsplash.com/photo-1600080972464-8e5f35f63d08?w=800&auto=format&fit=crop&q=80',
        ],
        purchaseDate: now.subtract(const Duration(days: 120)),
        purchasePrice: 69.99,
        serialNumber: 'SN-DS5-77312',
        barcode: '711719541028',
        warrantyExpiryDate: now.add(const Duration(days: 245)),
        status: ItemStatus.stored,
        customAttributes: {'Color': 'Midnight Black'},
      ));

      final ointment = await _apiService.createItem(Item(
        name: 'Neosporin First Aid Antibiotic',
        description: 'Triple antibiotic infection protection ointment 1oz',
        boxId: emergencyBox.id,
        categoryId: 'Medicine & Health',
        quantity: 2,
        minQuantity: 4, // Low stock: 2 <= 4
        unit: 'tubes',
        photos: const [
          'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=800&auto=format&fit=crop&q=80',
        ],
        purchaseDate: now.subtract(const Duration(days: 350)),
        purchasePrice: 9.99,
        barcode: '300810733877',
        expiryDate: now.add(const Duration(days: 12)), // Expiring soon in 12 days
        status: ItemStatus.stored,
        customAttributes: {'Dosage': 'Topical'},
      ));

      final batteries = await _apiService.createItem(Item(
        name: 'AAA Alkaline Batteries (8-Pack)',
        description: 'Heavy duty backup cells for emergency remotes',
        boxId: elecBox.id,
        categoryId: 'Electronics',
        quantity: 8,
        unit: 'pcs',
        photos: const [
          'https://images.unsplash.com/photo-1619725002198-6a689b72f41d?w=800&auto=format&fit=crop&q=80',
        ],
        purchaseDate: now.subtract(const Duration(days: 400)),
        purchasePrice: 12.00,
        expiryDate: now.subtract(const Duration(days: 3)), // Expired 3 days ago
        status: ItemStatus.stored,
      ));

      final jacket = await _apiService.createItem(Item(
        name: 'North Face Waterproof Puffer Jacket',
        description: 'ThermoBall Eco insulated winter coat',
        boxId: mediaConsole.id,
        categoryId: 'Clothing',
        quantity: 1,
        unit: 'pcs',
        photos: const [
          'https://images.unsplash.com/photo-1544923246-77307dd654cb?w=800&auto=format&fit=crop&q=80',
        ],
        purchaseDate: now.subtract(const Duration(days: 200)),
        purchasePrice: 220.00,
        status: ItemStatus.stored,
        customAttributes: {'Size': 'L', 'Color': 'Matte Black'},
      ));

      _items.clear();
      _items.addAll([macbook, charger, hdmi, ps5, ointment, batteries, jacket]);

      // Create Overdue Loan for ps5 controller
      final loan = await _apiService.lendItem(
        itemId: ps5.id,
        borrowerName: 'Alex Johnson',
        borrowerContact: '+1 (555) 234-5678',
        lentDate: now.subtract(const Duration(days: 14)),
        expectedReturnDate: now.subtract(const Duration(days: 2)), // Overdue 2 days
        notes: 'Lent for weekend game tournament',
      );

      _lendingRecords.clear();
      _lendingRecords.add(loan);

      // Update ps5 status in local item list
      final ps5Idx = _items.indexWhere((i) => i.id == ps5.id);
      if (ps5Idx != -1) {
        _items[ps5Idx] = _items[ps5Idx].copyWith(status: ItemStatus.lent);
      }

      return true;
    } catch (e) {
      debugPrint('seedBackendWithSampleData error: $e');
      if (_boxes.isEmpty) {
        _populateOfflineDemoData();
      }
      return true;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  void _populateOfflineDemoData() {
    final now = DateTime.now();

    final f1 = Box(
      id: 'box-f1',
      name: '1st Floor',
      type: StorageType.room,
      label: 'loc_floor_1',
      description: 'Main ground level of the residence',
    );
    final f2 = Box(
      id: 'box-f2',
      name: '2nd Floor',
      type: StorageType.room,
      label: 'loc_floor_2',
      description: 'Upper living and working quarters',
    );
    final living = Box(
      id: 'box-living',
      name: 'Living Room',
      type: StorageType.room,
      parentId: f1.id,
      label: 'loc_living_room',
      description: 'Family entertainment area',
    );
    final office = Box(
      id: 'box-office',
      name: 'Home Office',
      type: StorageType.room,
      parentId: f2.id,
      label: 'loc_home_office',
      description: 'Workspace and study room',
    );
    final kitchen = Box(
      id: 'box-kitchen',
      name: 'Kitchen & Pantry',
      type: StorageType.room,
      parentId: f1.id,
      label: 'loc_kitchen',
      description: 'Cooking and dry food storage',
    );
    final mediaConsole = Box(
      id: 'box-media',
      name: 'TV Media Console',
      type: StorageType.cabinet,
      parentId: living.id,
      label: 'cab_media_01',
      description: 'Cabinet underneath OLED TV',
    );
    final oakBookshelf = Box(
      id: 'box-shelf',
      name: 'Oak Bookshelf',
      type: StorageType.shelf,
      parentId: office.id,
      label: 'shelf_oak_01',
      description: 'Main library and tech shelf',
    );
    final elecBox = Box(
      id: 'box-elec',
      name: 'Electronics & Cables Box',
      type: StorageType.box,
      parentId: oakBookshelf.id,
      label: 'elec_001',
      description: 'High-speed cables, adapters, chargers',
    );
    final gamingDrawer = Box(
      id: 'box-game',
      name: 'Gaming Accessories Drawer',
      type: StorageType.drawer,
      parentId: mediaConsole.id,
      label: 'box_game_01',
      description: 'Controllers, headsets, cartridges',
    );

    _boxes.clear();
    _boxes.addAll([f1, f2, living, office, kitchen, mediaConsole, oakBookshelf, elecBox, gamingDrawer]);

    final item1 = Item(
      id: 'item-usbc',
      name: 'Anker USB-C Thunderbolt 4 Cable',
      boxId: elecBox.id,
      categoryId: 'Electronics',
      quantity: 3,
      unit: 'pcs',
      minQuantity: 1,
      purchasePrice: 450000,
      status: ItemStatus.stored,
      description: 'Braided 40Gbps 100W PD charging cable',
    );
    final item2 = Item(
      id: 'item-charger',
      name: 'Anker Prime 67W GaN Wall Charger',
      boxId: elecBox.id,
      categoryId: 'Electronics',
      quantity: 1,
      unit: 'pcs',
      purchasePrice: 950000,
      status: ItemStatus.stored,
      description: '3-Port compact travel fast charger',
    );
    final item3 = Item(
      id: 'item-dualsense',
      name: 'DualSense Wireless Controller (Midnight Black)',
      boxId: gamingDrawer.id,
      categoryId: 'Gaming',
      quantity: 2,
      unit: 'pcs',
      minQuantity: 1,
      purchasePrice: 1750000,
      status: ItemStatus.stored,
    );
    final item4 = Item(
      id: 'item-ps5',
      name: 'Sony PlayStation 5 Disc Edition',
      boxId: mediaConsole.id,
      categoryId: 'Gaming',
      quantity: 1,
      unit: 'pcs',
      purchasePrice: 14500000,
      status: ItemStatus.lent,
      description: 'Next-gen console with 825GB SSD',
    );
    final item5 = Item(
      id: 'item-med',
      name: 'Paracetamol 500mg Extra Relief',
      boxId: kitchen.id,
      categoryId: 'Medical & Health',
      quantity: 4,
      unit: 'tablets',
      minQuantity: 10,
      purchasePrice: 42000,
      status: ItemStatus.stored,
      isConsumable: true,
      expiryDate: now.add(const Duration(days: 15)),
    );

    _items.clear();
    _items.addAll([item1, item2, item3, item4, item5]);

    final loan = LendingRecord(
      id: 'loan-demo-1',
      itemId: item4.id,
      borrowerName: 'Alex Vance',
      borrowerContact: '+84 901 234 567',
      lentDate: now.subtract(const Duration(days: 10)),
      expectedReturnDate: now.subtract(const Duration(days: 2)),
      notes: 'Borrowed for gaming weekend',
    );

    _lendingRecords.clear();
    _lendingRecords.add(loan);
  }

  Future<void> resetToMockData() async {
    await seedBackendWithSampleData();
  }

  void clearAllData() {
    _boxes.clear();
    _items.clear();
    _lendingRecords.clear();
    notifyListeners();
  }
}
