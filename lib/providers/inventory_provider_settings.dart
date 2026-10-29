part of 'inventory_provider.dart';

/// Profile and app preference management.
extension InventorySettings on InventoryProvider {
  /// Copies the server's settings map into the fields (missing keys keep their value).
  void _applySettings(Map<String, dynamic> m) {
    _currency = m['currencySymbol'] as String? ?? _currency;
    _defaultUnit = m['defaultUnit'] as String? ?? _defaultUnit;
    _expiryWarningDays =
        (m['expiryWarningDays'] as num?)?.toInt() ?? _expiryWarningDays;
    _warrantyWarningDays =
        (m['warrantyWarningDays'] as num?)?.toInt() ?? _warrantyWarningDays;
    _timezone = m['timezone'] as String? ?? _timezone;
    _notifyExpiring = m['notifyExpiring'] as bool? ?? _notifyExpiring;
    _notifyOverdue = m['notifyOverdue'] as bool? ?? _notifyOverdue;
    _notifyLowStock = m['notifyLowStock'] as bool? ?? _notifyLowStock;
    _vibrateOnScan = m['vibrateOnScan'] as bool? ?? _vibrateOnScan;
    _autoOpenOnScan = m['autoOpenOnScan'] as bool? ?? _autoOpenOnScan;
  }

  /// Sends a settings change, or queues it offline. The local value stays (the UI already
  /// shows it); the cached copy is updated so a restart offline keeps it too.
  Future<void> _saveSetting(Map<String, dynamic> delta) async {
    final store = _store;
    if (store != null) {
      await store.saveSettings({...?await store.loadSettings(), ...delta});
    }
    await _commit(PendingOp('updateSettings', {'delta': delta}), () async {
      await _apiService.updateSettings(delta);
    });
  }

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
    await _saveSetting({'currencySymbol': val});
  }

  Future<void> setDefaultUnit(String val) async {
    _defaultUnit = val;
    _notify();
    await _saveSetting({'defaultUnit': val});
  }

  Future<void> setExpiryWarningDays(int days) async {
    _expiryWarningDays = days;
    _notify();
    await _saveSetting({'expiryWarningDays': days});
  }

  Future<void> setWarrantyWarningDays(int days) async {
    _warrantyWarningDays = days;
    _notify();
    await _saveSetting({'warrantyWarningDays': days});
  }

  Future<void> setTimezone(String tz) async {
    _timezone = tz;
    _notify();
    await _saveSetting({'timezone': tz});
  }

  void setLowStockThreshold(int val) {
    _lowStockThreshold = val;
    _notify();
  }

  Future<void> setVibrateOnScan(bool val) async {
    _vibrateOnScan = val;
    _notify();
    await _saveSetting({'vibrateOnScan': val});
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
    await _saveSetting({'autoOpenOnScan': val});
  }

  Future<void> setNotifyExpiring(bool val) async {
    _notifyExpiring = val;
    _notify();
    await _saveSetting({'notifyExpiring': val});
  }

  Future<void> setNotifyOverdue(bool val) async {
    _notifyOverdue = val;
    _notify();
    await _saveSetting({'notifyOverdue': val});
  }

  Future<void> setNotifyLowStock(bool val) async {
    _notifyLowStock = val;
    _notify();
    await _saveSetting({'notifyLowStock': val});
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
