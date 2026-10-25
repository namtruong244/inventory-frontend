import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/inventory_models.dart';

/// Exception thrown when backend API returns an error or is unreachable
class ApiException implements Exception {
  final int statusCode;
  final String code;
  final String message;
  final List<dynamic> details;

  ApiException({
    required this.statusCode,
    this.code = 'UNKNOWN_ERROR',
    required this.message,
    this.details = const [],
  });

  @override
  String toString() => 'ApiException [$code] ($statusCode): $message';
}

/// Service handling all REST API interactions with the backend
class ApiService {
  static const String _defaultLocalhost = 'http://localhost:8080';
  static const String _envBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  static const String _prefKeyBaseUrl = 'inventory_api_base_url';
  static const String _prefKeyAuthToken = 'inventory_auth_token';
  static const String _prefKeyUser = 'inventory_auth_user';

  // Token and user live in the Keychain/Keystore; SharedPreferences keeps only
  // the server URL (and the legacy session keys, migrated on first launch).
  static const FlutterSecureStorage _secure = FlutterSecureStorage();

  String _baseUrl = _defaultLocalhost;
  String? _token;
  User? _currentUser;

  final _unauthorized = StreamController<String>.broadcast();

  /// Fires (with the error code) when the server rejects the stored token, after the
  /// session has been cleared. The offline queue is left alone.
  Stream<String> get onUnauthorized => _unauthorized.stream;

  String get baseUrl => _baseUrl;
  String? get token => _token;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  ApiService() {
    if (_envBaseUrl.isNotEmpty) {
      _baseUrl = _normalizeUrl(_envBaseUrl);
    } else if (!kIsWeb && Platform.isAndroid) {
      // Default URL detection: Android emulator needs 10.0.2.2 instead of localhost
      _baseUrl = 'http://10.0.2.2:8080';
    }
  }

  static String _normalizeUrl(String url) {
    var trimmed = url.trim();
    if (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }

  /// Initialize stored preferences (token, user, custom server URL)
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // If API_BASE_URL was provided at build/run time via --dart-define, it takes highest precedence.
      if (_envBaseUrl.isNotEmpty) {
        _baseUrl = _normalizeUrl(_envBaseUrl);
      } else {
        final savedUrl = prefs.getString(_prefKeyBaseUrl);
        if (savedUrl != null && savedUrl.isNotEmpty) {
          _baseUrl = savedUrl;
        }
      }

      await _migrateLegacySession(prefs);
      _token = await _secure.read(key: _prefKeyAuthToken);
      final savedUserJson = await _secure.read(key: _prefKeyUser);
      if (savedUserJson != null) {
        try {
          _currentUser = User.fromJson(jsonDecode(savedUserJson));
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('ApiService init error: $e');
    }
  }

  /// One-time move of a plaintext session from SharedPreferences to secure storage.
  Future<void> _migrateLegacySession(SharedPreferences prefs) async {
    final legacyToken = prefs.getString(_prefKeyAuthToken);
    final legacyUser = prefs.getString(_prefKeyUser);
    if (legacyToken == null && legacyUser == null) return;
    if (legacyToken != null &&
        await _secure.read(key: _prefKeyAuthToken) == null) {
      await _secure.write(key: _prefKeyAuthToken, value: legacyToken);
      if (legacyUser != null) {
        await _secure.write(key: _prefKeyUser, value: legacyUser);
      }
    }
    await prefs.remove(_prefKeyAuthToken);
    await prefs.remove(_prefKeyUser);
  }

  /// Update the backend base URL (e.g., from settings)
  Future<void> setBaseUrl(String newUrl) async {
    _baseUrl = _normalizeUrl(newUrl);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyBaseUrl, _baseUrl);
  }

  /// Save authentication session
  Future<void> setSession(String token, User user) async {
    _token = token;
    _currentUser = user;
    await _secure.write(key: _prefKeyAuthToken, value: token);
    await _secure.write(key: _prefKeyUser, value: jsonEncode(user.toJson()));
  }

  /// Clear authentication session
  Future<void> clearSession() async {
    _token = null;
    _currentUser = null;
    await _secure.delete(key: _prefKeyAuthToken);
    await _secure.delete(key: _prefKeyUser);
  }

  // -------------------------------------------------------------
  // HTTP Request Helpers
  // -------------------------------------------------------------

  Map<String, String> _buildHeaders({bool isJson = true}) {
    final headers = <String, String>{'Accept': 'application/json'};
    if (isJson) {
      headers['Content-Type'] = 'application/json';
    }
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParams]) {
    final urlString = '$_baseUrl$path';
    final uri = Uri.parse(urlString);
    if (queryParams != null && queryParams.isNotEmpty) {
      final cleanParams = <String, String>{};
      queryParams.forEach((key, value) {
        if (value != null) {
          cleanParams[key] = value.toString();
        }
      });
      return uri.replace(queryParameters: cleanParams);
    }
    return uri;
  }

  /// A 401 on a request that carried our token means the session is over.
  void _onAuthFailure(http.Response response, String code) {
    if (response.statusCode != 401) return;
    if (response.request?.headers.containsKey('Authorization') != true) return;
    if (!isAuthenticated) return;
    _token = null;
    unawaited(_secure.delete(key: _prefKeyAuthToken));
    _unauthorized.add(code);
  }

  dynamic _handleResponse(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      throw ApiException(
        statusCode: response.statusCode,
        code: 'INVALID_JSON_RESPONSE',
        message: 'Server returned non-JSON response (${response.statusCode})',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body is Map<String, dynamic>) {
        if (body['success'] == true) {
          return body['data'];
        }
        return body['data'] ?? body;
      }
      return body;
    }

    // Handle API error envelope
    if (body is Map<String, dynamic> && body['error'] is Map<String, dynamic>) {
      final err = body['error'];
      _onAuthFailure(response, err['code']?.toString() ?? 'UNAUTHORIZED');
      throw ApiException(
        statusCode: response.statusCode,
        code: err['code']?.toString() ?? 'API_ERROR',
        message: err['message']?.toString() ?? 'An error occurred',
        details: err['details'] is List ? err['details'] : [],
      );
    }

    _onAuthFailure(response, 'UNAUTHORIZED');
    throw ApiException(
      statusCode: response.statusCode,
      code: 'HTTP_${response.statusCode}',
      message: body is Map && body['message'] != null
          ? body['message'].toString()
          : 'Request failed with status ${response.statusCode}',
    );
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParams}) async {
    final uri = _buildUri(path, queryParams);
    final response = await http
        .get(uri, headers: _buildHeaders())
        .timeout(const Duration(seconds: 15));
    return _handleResponse(response);
  }

  Future<dynamic> post(String path, dynamic body) async {
    final uri = _buildUri(path);
    final response = await http
        .post(uri, headers: _buildHeaders(isJson: true), body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));
    return _handleResponse(response);
  }

  Future<dynamic> put(String path, dynamic body) async {
    final uri = _buildUri(path);
    final response = await http
        .put(uri, headers: _buildHeaders(isJson: true), body: jsonEncode(body))
        .timeout(const Duration(seconds: 15));
    return _handleResponse(response);
  }

  Future<dynamic> patch(String path, dynamic body) async {
    final uri = _buildUri(path);
    final response = await http
        .patch(
          uri,
          headers: _buildHeaders(isJson: true),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 15));
    return _handleResponse(response);
  }

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParams,
  }) async {
    final uri = _buildUri(path, queryParams);
    final response = await http
        .delete(uri, headers: _buildHeaders())
        .timeout(const Duration(seconds: 15));
    return _handleResponse(response);
  }

  // -------------------------------------------------------------
  // Module 4.1: Authentication
  // -------------------------------------------------------------

  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await post('/api/v1/auth/login', {
      'email': email,
      'password': password,
    });
    final token = data['token'] as String;
    final user = User.fromJson(data['user'] as Map<String, dynamic>);
    await setSession(token, user);
    return {'token': token, 'user': user};
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final data = await post('/api/v1/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });
    final token = data['token'] as String;
    final user = User.fromJson(data['user'] as Map<String, dynamic>);
    await setSession(token, user);
    return {'token': token, 'user': user};
  }

  /// Permanently deletes the account and all of its data on the server.
  Future<void> deleteAccount() async {
    await delete('/api/v1/auth/me');
  }

  /// Swaps the stored token for a fresh one (same user). Best effort.
  Future<void> refreshToken() async {
    final data = await post('/api/v1/auth/refresh', {});
    await setSession(
      data['token'] as String,
      User.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  /// Revokes every token issued to this account (all devices).
  Future<void> logoutAll() async {
    await post('/api/v1/auth/logout-all', {});
  }

  Future<User> getMe() async {
    final data = await get('/api/v1/auth/me');
    final user = User.fromJson(data as Map<String, dynamic>);
    _currentUser = user;
    return user;
  }

  Future<Map<String, dynamic>> loginWithGoogle({
    required String email,
    required String name,
    String? avatarUrl,
    String? idToken,
    String? accessToken,
  }) async {
    final payload = <String, dynamic>{
      'email': email,
      'name': name,
      'avatar_url': ?avatarUrl,
      'id_token': ?idToken,
      'access_token': ?accessToken,
    };
    try {
      final res = await post('/api/v1/auth/google', payload);
      final token = res['token'] as String;
      final user = User.fromJson(res['user'] as Map<String, dynamic>);
      await setSession(token, user);
      return {'token': token, 'user': user};
    } on ApiException catch (e) {
      // The server explicitly rejected the login (e.g. invalid token): never fake a session
      if (e.code == 'AUTH_FAILED' || e.code == 'INVALID_INPUT') rethrow;
      return _offlineGoogleSession(
        email: email,
        name: name,
        avatarUrl: avatarUrl,
      );
    } catch (_) {
      return _offlineGoogleSession(
        email: email,
        name: name,
        avatarUrl: avatarUrl,
      );
    }
  }

  Future<Map<String, dynamic>> _offlineGoogleSession({
    required String email,
    required String name,
    String? avatarUrl,
  }) async {
    // Offline / standalone fallback session
    final token = 'google_oauth_token_${DateTime.now().millisecondsSinceEpoch}';
    final user = User(
      id: 'google_${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}',
      name: name,
      email: email,
      role: 'Owner',
      avatarUrl: avatarUrl,
    );
    await setSession(token, user);
    return {'token': token, 'user': user};
  }

  // -------------------------------------------------------------
  // Module 4.2: Settings & Profile
  // -------------------------------------------------------------

  Future<Map<String, dynamic>> getSettings() async {
    final data = await get('/api/v1/settings');
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateSettings(
    Map<String, dynamic> delta,
  ) async {
    final data = await patch('/api/v1/settings', delta);
    return data as Map<String, dynamic>;
  }

  Future<User> updateProfile({
    String? name,
    String? role,
    String? avatarUrl,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (role != null) body['role'] = role;
    if (avatarUrl != null) body['avatarUrl'] = avatarUrl;
    final data = await patch('/api/v1/user/profile', body);
    final user = User.fromJson(data as Map<String, dynamic>);
    _currentUser = user;
    return user;
  }

  // -------------------------------------------------------------
  // Module 4.3: Categories
  // -------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getCategories() async {
    final data = await get('/api/v1/categories');
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> createCategory(String name) async {
    final data = await post('/api/v1/categories', {'name': name});
    return data as Map<String, dynamic>;
  }

  Future<void> deleteCategory(String name) async {
    await delete('/api/v1/categories/${Uri.encodeComponent(name)}');
  }

  // -------------------------------------------------------------
  // Module 4.4: Storage Spaces / Boxes
  // -------------------------------------------------------------

  Future<List<Box>> getBoxes({String? parentId, bool? tree}) async {
    final query = <String, dynamic>{};
    if (parentId != null) query['parentId'] = parentId;
    if (tree != null) query['tree'] = tree;

    final data = await get('/api/v1/boxes', queryParams: query);
    return (data as List)
        .map((json) => Box.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> getBoxDetails(String boxId) async {
    final data = await get('/api/v1/boxes/$boxId');
    return data as Map<String, dynamic>;
  }

  Future<Box> createBox(Box box) async {
    final body = {
      'id': box.id,
      'name': box.name,
      'type': box.type.name,
      'description': box.description,
      'label': box.label,
      if (box.parentId != null) 'parentId': box.parentId,
      if (box.icon != null) 'icon': box.icon,
    };
    final data = await post('/api/v1/boxes', body);
    return Box.fromJson(data as Map<String, dynamic>);
  }

  /// With [checkVersion], sends [Box.updatedAt] as the version the edit is based on and
  /// the server answers 409 when the box changed since (used when replaying offline edits).
  Future<Box> updateBox(Box box, {bool checkVersion = false}) async {
    final body = {
      if (checkVersion && box.updatedAt != null)
        'updatedAt': box.updatedAt!.toUtc().toIso8601String(),
      'name': box.name,
      'type': box.type.name,
      'description': box.description,
      'label': box.label,
      if (box.icon != null) 'icon': box.icon,
    };
    final data = await put('/api/v1/boxes/${box.id}', body);
    return Box.fromJson(data as Map<String, dynamic>);
  }

  Future<void> moveBox(String boxId, String? newParentId) async {
    await patch('/api/v1/boxes/$boxId/move', {'newParentId': newParentId});
  }

  Future<void> deleteBox(String boxId, {bool cascade = false}) async {
    await delete('/api/v1/boxes/$boxId', queryParams: {'cascade': cascade});
  }

  // -------------------------------------------------------------
  // Module 4.5: Items / Asset Catalog
  // -------------------------------------------------------------

  Future<List<Item>> getItems({
    String? query,
    String? boxId,
    String? category,
    String? status,
    bool? isLowStock,
    bool? isExpired,
    bool? isExpiring,
    int page = 1,
    int limit = 200,
  }) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (query != null && query.isNotEmpty) params['q'] = query;
    if (boxId != null) params['boxId'] = boxId;
    if (category != null) params['category'] = category;
    if (status != null) params['status'] = status;
    if (isLowStock != null) params['isLowStock'] = isLowStock;
    if (isExpired != null) params['isExpired'] = isExpired;
    if (isExpiring != null) params['isExpiring'] = isExpiring;

    final data = await get('/api/v1/items', queryParams: params);
    if (data is List) {
      return data
          .map((json) => Item.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Fetches every item by walking pages, since the backend caps `limit` at 200.
  Future<List<Item>> getAllItems({int pageSize = 200}) async {
    final all = <Item>[];
    for (var page = 1; ; page++) {
      final batch = await getItems(page: page, limit: pageSize);
      all.addAll(batch);
      if (batch.length < pageSize) break;
    }
    return all;
  }

  Future<Item> getItemById(String itemId) async {
    final data = await get('/api/v1/items/$itemId');
    return Item.fromJson(data as Map<String, dynamic>);
  }

  /// Backend stores dates as YYYY-MM-DD; send the calendar day the user picked.
  static String _dateOnly(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<Item> createItem(Item item) async {
    final body = <String, dynamic>{
      'id': item.id,
      'name': item.name,
      'description': item.description,
      'boxId': item.boxId,
      'categoryId': item.categoryId,
      'quantity': item.quantity,
      'unit': item.unit,
      'isConsumable': item.isConsumable,
      'status': item.status.name,
      'photos': item.photos,
      'receiptPhotos': item.receiptPhotos,
      'customAttributes': item.customAttributes,
    };
    if (item.minQuantity != null) body['minQuantity'] = item.minQuantity;
    if (item.purchasePrice != null) body['purchasePrice'] = item.purchasePrice;
    if (item.purchaseDate != null) {
      body['purchaseDate'] = _dateOnly(item.purchaseDate!);
    }
    if (item.warrantyExpiryDate != null) {
      body['warrantyExpiryDate'] = _dateOnly(item.warrantyExpiryDate!);
    }
    if (item.expiryDate != null) {
      body['expiryDate'] = _dateOnly(item.expiryDate!);
    }
    if (item.serialNumber != null && item.serialNumber!.isNotEmpty) {
      body['serialNumber'] = item.serialNumber;
    }
    if (item.barcode != null && item.barcode!.isNotEmpty) {
      body['barcode'] = item.barcode;
    }

    final data = await post('/api/v1/items', body);
    return Item.fromJson(data as Map<String, dynamic>);
  }

  /// With [checkVersion], sends [Item.updatedAt] as the version the edit is based on and
  /// the server answers 409 when the item changed since (used when replaying offline edits).
  Future<Item> updateItem(Item item, {bool checkVersion = false}) async {
    final body = <String, dynamic>{
      if (checkVersion && item.updatedAt != null)
        'updatedAt': item.updatedAt!.toUtc().toIso8601String(),
      'name': item.name,
      'description': item.description,
      'boxId': item.boxId,
      'categoryId': item.categoryId,
      'quantity': item.quantity,
      'unit': item.unit,
      'isConsumable': item.isConsumable,
      'status': item.status.name,
      'minQuantity': item.minQuantity,
      if (item.minQuantity == null) 'clearMinQuantity': true,
      'purchasePrice': item.purchasePrice,
      'photos': item.photos,
      'receiptPhotos': item.receiptPhotos,
      'customAttributes': item.customAttributes,
    };
    if (item.purchaseDate != null) {
      body['purchaseDate'] = _dateOnly(item.purchaseDate!);
    } else {
      body['purchaseDate'] = null;
    }
    if (item.warrantyExpiryDate != null) {
      body['warrantyExpiryDate'] = _dateOnly(item.warrantyExpiryDate!);
    } else {
      body['warrantyExpiryDate'] = null;
    }
    if (item.expiryDate != null) {
      body['expiryDate'] = _dateOnly(item.expiryDate!);
    } else {
      body['expiryDate'] = null;
    }
    body['serialNumber'] = item.serialNumber;
    body['barcode'] = item.barcode;

    final data = await put('/api/v1/items/${item.id}', body);
    return Item.fromJson(data as Map<String, dynamic>);
  }

  Future<void> moveItem(String itemId, String targetBoxId) async {
    await patch('/api/v1/items/$itemId/move', {'targetBoxId': targetBoxId});
  }

  Future<void> updateItemQuantity(
    String itemId,
    double quantity, {
    String? reason,
    String? note,
  }) async {
    await patch('/api/v1/items/$itemId/quantity', {
      'quantity': quantity,
      'reason': ?reason,
      if (note != null && note.isNotEmpty) 'note': note,
    });
  }

  /// Adds [delta] (negative to consume) atomically on the server; returns the new quantity.
  Future<double?> adjustItemQuantity(
    String itemId,
    double delta, {
    String? reason,
    String? note,
  }) async {
    final data = await patch('/api/v1/items/$itemId/quantity', {
      'delta': delta,
      'reason': ?reason,
      if (note != null && note.isNotEmpty) 'note': note,
    });
    return data is Map ? (data['quantity'] as num?)?.toDouble() : null;
  }

  Future<StockHistory> getItemMovements(String itemId) async {
    final data = await get('/api/v1/items/$itemId/movements');
    return StockHistory.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteItem(String itemId) async {
    await delete('/api/v1/items/$itemId');
  }

  // -------------------------------------------------------------
  // Trash (soft-deleted items & boxes)
  // -------------------------------------------------------------

  Future<({List<Item> items, List<Box> boxes})> getTrash() async {
    final data = await get('/api/v1/trash') as Map<String, dynamic>;
    return (
      items: ((data['items'] as List?) ?? [])
          .map((j) => Item.fromJson(j as Map<String, dynamic>))
          .toList(),
      boxes: ((data['boxes'] as List?) ?? [])
          .map((j) => Box.fromJson(j as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<void> restoreTrashItem(String id) async {
    await post('/api/v1/trash/items/$id/restore', {});
  }

  Future<void> restoreTrashBox(String id) async {
    await post('/api/v1/trash/boxes/$id/restore', {});
  }

  Future<void> purgeTrashItem(String id) async {
    await delete('/api/v1/trash/items/$id');
  }

  Future<void> purgeTrashBox(String id) async {
    await delete('/api/v1/trash/boxes/$id');
  }

  Future<void> emptyTrash() async {
    await delete('/api/v1/trash');
  }

  // -------------------------------------------------------------
  // Module 4.6: Lending & Borrowing
  // -------------------------------------------------------------

  Future<LendingRecord> lendItem({
    String? id,
    required String itemId,
    required String borrowerName,
    String borrowerContact = '',
    required DateTime lentDate,
    DateTime? expectedReturnDate,
    String notes = '',
    double? quantity,
  }) async {
    final body = {
      'id': ?id,
      'itemId': itemId,
      'borrowerName': borrowerName,
      'borrowerContact': borrowerContact,
      'lentDate': lentDate.toUtc().toIso8601String(),
      if (expectedReturnDate != null)
        // A calendar day, sent as UTC midnight so the server reads the same day.
        'expectedReturnDate': DateTime.utc(
          expectedReturnDate.year,
          expectedReturnDate.month,
          expectedReturnDate.day,
        ).toIso8601String(),
      'notes': notes,
      'quantity': ?quantity,
    };
    final data = await post('/api/v1/lending/lend', body);
    return LendingRecord.fromJson(data as Map<String, dynamic>);
  }

  Future<void> returnItem(String recordId) async {
    await post('/api/v1/lending/$recordId/return', {});
  }

  Future<List<LendingRecord>> getActiveLoans() async {
    final data = await get('/api/v1/lending/active');
    return (data as List)
        .map((json) => LendingRecord.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<LendingRecord>> getOverdueLoans() async {
    final data = await get('/api/v1/lending/overdue');
    return (data as List)
        .map((json) => LendingRecord.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<LendingRecord>> getLendingHistory(String itemId) async {
    final data = await get(
      '/api/v1/lending/history',
      queryParams: {'itemId': itemId},
    );
    return (data as List)
        .map((json) => LendingRecord.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // -------------------------------------------------------------
  // Module 4.7: Scanning & Lookup
  // -------------------------------------------------------------

  Future<Map<String, dynamic>?> lookupScan(String code) async {
    try {
      final data = await get(
        '/api/v1/scan/lookup',
        queryParams: {'code': code},
      );
      return data as Map<String, dynamic>;
    } on ApiException catch (e) {
      if (e.statusCode == 404 || e.code == 'NOT_FOUND') {
        return null;
      }
      rethrow;
    }
  }

  // -------------------------------------------------------------
  // Module 4.8: Alerts & Dashboard
  // -------------------------------------------------------------

  Future<Map<String, dynamic>> getAlertsSummary() async {
    final data = await get('/api/v1/alerts/summary');
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getAllAlerts() async {
    final data = await get('/api/v1/alerts/all');
    return data as Map<String, dynamic>;
  }

  // -------------------------------------------------------------
  // Module 4.9: Reports & Inventory Audit
  // -------------------------------------------------------------

  Future<Map<String, dynamic>> getInventoryHealth() async {
    final data = await get('/api/v1/reports/inventory-health');
    return data as Map<String, dynamic>;
  }

  // -------------------------------------------------------------
  // Module 4.10: Media Upload
  // -------------------------------------------------------------

  Future<String> uploadMedia(String filePath, {String folder = 'items'}) async {
    final uri = _buildUri('/api/v1/media/upload');
    final request = http.MultipartRequest('POST', uri);

    if (_token != null && _token!.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $_token';
    }

    request.fields['folder'] = folder;
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 30),
    );
    final response = await http.Response.fromStream(streamedResponse);
    final data = _handleResponse(response);
    return data['url'] as String;
  }
}
