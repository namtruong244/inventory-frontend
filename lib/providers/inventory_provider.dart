import 'package:flutter/foundation.dart';
import '../models/inventory_models.dart';
import '../services/api_service.dart';
import '../services/offline_store.dart';
import '../utils/formatters.dart';

part 'inventory_provider_seed.dart';
part 'inventory_provider_lending.dart';
part 'inventory_provider_items.dart';
part 'inventory_provider_boxes.dart';
part 'inventory_provider_settings.dart';
part 'inventory_provider_alerts.dart';
part 'inventory_provider_reports.dart';
part 'inventory_provider_trash.dart';
part 'inventory_provider_offline.dart';

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

  /// Stock changes made offline that still wait for the next sync.
  int _pendingChanges = 0;
  int get pendingChanges => _pendingChanges;

  /// Showing cached data because the server could not be reached.
  bool _isOffline = false;
  bool get isOffline => _isOffline;

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

  /// Lets the extension modules in the part files notify listeners.
  void _notify() => notifyListeners();

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
      await _flushPending();

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
      var reachedServer = true;
      try {
        final boxList = await _apiService.getBoxes();
        _boxes.clear();
        _boxes.addAll(boxList);
      } catch (e) {
        debugPrint('Fetch boxes error: $e');
        reachedServer = !_isNetworkError(e);
      }

      if (!reachedServer) {
        // Offline: keep browsing and scanning against the last synced data.
        final hadCache = await _loadSnapshot();
        _isOffline = true;
        _isConnected = false;
        _errorMessage = hadCache ? 'Offline: showing saved data' : 'Cannot reach the server';
        return;
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
      _isOffline = false;
      _errorMessage = null;
      await _saveSnapshot();

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

}
