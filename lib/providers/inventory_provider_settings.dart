part of 'inventory_provider.dart';

/// Profile and app preference management.
extension InventorySettings on InventoryProvider {
  // ==========================================
  // PROFILE & SETTINGS
  // ==========================================

  Future<bool> updateUserProfile(String name, String role) async {
    final trimmedName = name.trim();
    final trimmedRole = role.trim();
    if (trimmedName.isNotEmpty) _userName = trimmedName;
    if (trimmedRole.isNotEmpty) _userRole = trimmedRole;
    _notify();

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
    _notify();
    try {
      await _apiService.updateSettings({'currencySymbol': val});
    } catch (e) {
      debugPrint('updateSettings error: $e');
    }
  }

  Future<void> setDefaultUnit(String val) async {
    _defaultUnit = val;
    _notify();
    try {
      await _apiService.updateSettings({'defaultUnit': val});
    } catch (e) {
      debugPrint('updateSettings error: $e');
    }
  }

  Future<void> setExpiryWarningDays(int days) async {
    _expiryWarningDays = days;
    _notify();
    try {
      await _apiService.updateSettings({'expiryWarningDays': days});
    } catch (e) {
      debugPrint('updateSettings error: $e');
    }
  }

  Future<void> setWarrantyWarningDays(int days) async {
    _warrantyWarningDays = days;
    _notify();
    try {
      await _apiService.updateSettings({'warrantyWarningDays': days});
    } catch (e) {
      debugPrint('updateSettings error: $e');
    }
  }

  Future<void> setTimezone(String tz) async {
    _timezone = tz;
    _notify();
    try {
      await _apiService.updateSettings({'timezone': tz});
    } catch (e) {
      debugPrint('updateSettings error: $e');
    }
  }

  void setLowStockThreshold(int val) {
    _lowStockThreshold = val;
    _notify();
  }

  Future<void> setVibrateOnScan(bool val) async {
    _vibrateOnScan = val;
    _notify();
    try {
      await _apiService.updateSettings({'vibrateOnScan': val});
    } catch (e) {
      debugPrint('updateSettings error: $e');
    }
  }

  /// The backend has no field for this, so it is a per-device preference.
  Future<void> setBeepOnScan(bool val) async {
    _beepOnScan = val;
    _notify();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(InventoryProvider.beepPrefKey, val);
    } catch (e) {
      debugPrint('save beepOnScan error: $e');
    }
  }

  Future<void> loadDevicePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _beepOnScan = prefs.getBool(InventoryProvider.beepPrefKey) ?? _beepOnScan;
      final themeName = prefs.getString(InventoryProvider.themePrefKey);
      _themeMode = ThemeMode.values.firstWhere(
        (m) => m.name == themeName,
        orElse: () => _themeMode,
      );
      final lang = prefs.getString(InventoryProvider.localePrefKey);
      _locale = lang == null ? null : Locale(lang);
      _notify();
    } catch (e) {
      debugPrint('load device preferences error: $e');
    }
  }

  /// Haptic + sound feedback for a successful scan, per the user's settings.
  void playScanFeedback() {
    if (_vibrateOnScan) HapticFeedback.mediumImpact();
    if (_beepOnScan) SystemSound.play(SystemSoundType.click);
  }

  Future<void> setAutoOpenOnScan(bool val) async {
    _autoOpenOnScan = val;
    _notify();
    try {
      await _apiService.updateSettings({'autoOpenOnScan': val});
    } catch (e) {
      debugPrint('updateSettings error: $e');
    }
  }

  Future<void> setNotifyExpiring(bool val) async {
    _notifyExpiring = val;
    _notify();
    try {
      await _apiService.updateSettings({'notifyExpiring': val});
    } catch (e) {
      debugPrint('updateSettings error: $e');
    }
  }

  Future<void> setNotifyOverdue(bool val) async {
    _notifyOverdue = val;
    _notify();
    try {
      await _apiService.updateSettings({'notifyOverdue': val});
    } catch (e) {
      debugPrint('updateSettings error: $e');
    }
  }

  Future<void> setNotifyLowStock(bool val) async {
    _notifyLowStock = val;
    _notify();
    try {
      await _apiService.updateSettings({'notifyLowStock': val});
    } catch (e) {
      debugPrint('updateSettings error: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    _notify();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(InventoryProvider.themePrefKey, mode.name);
    } catch (e) {
      debugPrint('save themeMode error: $e');
    }
  }

  /// [languageCode] `null` follows the system language.
  Future<void> setLocale(String? languageCode) async {
    _locale = languageCode == null ? null : Locale(languageCode);
    _notify();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (languageCode == null) {
        await prefs.remove(InventoryProvider.localePrefKey);
      } else {
        await prefs.setString(InventoryProvider.localePrefKey, languageCode);
      }
    } catch (e) {
      debugPrint('save locale error: $e');
    }
  }
}
