import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'legacy plaintext session moves to secure storage and is wiped',
    () async {
      SharedPreferences.setMockInitialValues({
        'inventory_auth_token': 'tok',
        'inventory_auth_user':
            '{"id":"u1","name":"A","email":"a@b.c","role":"Owner"}',
      });
      FlutterSecureStorage.setMockInitialValues({});

      final api = ApiService();
      await api.init();

      expect(api.token, 'tok');
      expect(api.currentUser?.email, 'a@b.c');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('inventory_auth_token'), isNull);
      expect(prefs.getString('inventory_auth_user'), isNull);
      expect(
        await const FlutterSecureStorage().read(key: 'inventory_auth_token'),
        'tok',
      );

      await api.clearSession();
      expect(
        await const FlutterSecureStorage().read(key: 'inventory_auth_token'),
        isNull,
      );
    },
  );
}
