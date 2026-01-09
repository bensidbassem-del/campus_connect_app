import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import 'auth_provider.dart';
import '../models/app_user.dart';

class AuthServiceController {
  final Ref ref;
  final AuthService _service = AuthService();

  AuthServiceController(this.ref);

  // LOGIN
  Future<bool> login({required String username, required String password}) async {
    final result = await _service.login(username: username, password: password);
    if (result['success'] == true) {
      final userJson = result['user'];
      ref.read(authProvider.notifier).state = AppUser.fromJson(userJson);
      return true;
    }
    return false;
  }

  // LOAD from storage (on app startup)
  Future<void> loadFromStorage() async {
    final user = await _service.getStoredUser();
    if (user != null) {
      ref.read(authProvider.notifier).state = AppUser.fromJson(user);
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _service.logout();
    ref.read(authProvider.notifier).state = null;
  }
}

final authServiceProvider = Provider<AuthServiceController>((ref) {
  return AuthServiceController(ref);
});
