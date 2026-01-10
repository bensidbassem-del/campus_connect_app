import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/authentication/services/auth_service.dart';
import '../providers/auth_provider.dart';
import '../../features/authentication/models/user_model.dart';

class AuthServiceController {
  final Ref ref;
  final AuthService _service = AuthService();

  AuthServiceController(this.ref);

  // LOGIN
  Future<String?> login({
    required String username,
    required String password,
  }) async {
    final result = await _service.login(username: username, password: password);
    if (result['success'] == true) {
      final userJson = result['user'];
      ref.read(authProvider.notifier).state = AppUser.fromJson(userJson);
      return null; // No error
    }

    // Extract error from result['error']
    final errorData = result['error'];
    if (errorData is Map) {
      if (errorData.containsKey('non_field_errors')) {
        return errorData['non_field_errors'][0];
      }
      if (errorData.containsKey('detail')) {
        return errorData['detail'];
      }
      // Specific field errors if any
      final String firstKey = errorData.keys.first;
      final dynamic val = errorData[firstKey];
      if (val is List) return val[0];
      return val.toString();
    }
    return 'Login failed. Please check your credentials.';
  }

  // REGISTER
  Future<String?> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String studentId,
    required String role,
  }) async {
    final result = await _service.register(
      username: username,
      email: email,
      password: password,
      password2: password,
      firstName: firstName,
      lastName: lastName,
      studentId: studentId,
      role: role,
    );

    if (result['success'] == true) {
      return null; // No error
    }

    // Extract error from result['error']
    final errorData = result['error'];
    if (errorData is Map) {
      final List<String> errors = [];
      errorData.forEach((key, value) {
        if (value is List) {
          errors.add('$key: ${value.join(', ')}');
        } else {
          errors.add('$key: $value');
        }
      });
      if (errors.isNotEmpty) return errors.join('\n');
    } else if (errorData != null) {
      return errorData.toString();
    }
    return 'Registration failed. Please try again.';
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
