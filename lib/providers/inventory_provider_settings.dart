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

  void setBeepOnScan(bool val) {
    _beepOnScan = val;
    _notify();
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
}
