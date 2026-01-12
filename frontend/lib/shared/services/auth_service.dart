import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../../features/authentication/models/user_model.dart';
import './api_client.dart';

class AuthService {
  final Ref _ref;
  final ApiClient _api;

  AuthService(this._ref, this._api);

  // --- CORE AUTH METHODS ---

  /// Login and update the auth state
  Future<String?> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _api.post('/auth/login/', {
        'username': username,
        'password': password,
      }, includeToken: false);

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);

        if (decoded == null || decoded is! Map) {
          return 'Invalid response from server (Not a JSON object)';
        }

        final Map<String, dynamic> data = Map<String, dynamic>.from(decoded);

        // Verify expected data exists and is not null
        if (data['access'] == null || data['user'] == null) {
          return 'Server response missing essential data (access/user)';
        }

        // Save tokens locally
        await _saveAuthData(data);

        // Update Riverpod state
        final userJson = data['user'];
        if (userJson != null && userJson is Map) {
          _ref.read(authProvider.notifier).state = AppUser.fromJson(
            Map<String, dynamic>.from(userJson),
          );
          return null;
        } else {
          return 'Failed to parse user data from server';
        }
      } else {
        return _parseError(response.body);
      }
    } catch (e, stack) {
      debugPrint('LOGIN ERROR: $e');
      debugPrint('STACKTRACE: $stack');
      return 'Connection error: ${e.toString()}';
    }
  }

  /// Register a new student/teacher account
  Future<String?> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String studentId,
    required String role,
  }) async {
    try {
      final response = await _api.post('/auth/register/', {
        'username': username,
        'email': email,
        'password': password,
        'password2': password,
        'first_name': firstName,
        'last_name': lastName,
        'student_id': studentId,
        'role': role,
      }, includeToken: false);

      if (response.statusCode == 201) {
        return null; // Success
      } else {
        return _parseError(response.body);
      }
    } catch (e) {
      return 'Connection error: ${e.toString()}';
    }
  }

  /// Logout and clear storage
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');

      // Optional: Inform backend (note: backend doesn't currently blacklist)
      if (refreshToken != null) {
        await _api.post('/auth/logout/', {'refresh': refreshToken});
      }
    } catch (_) {
      // Ignore network errors on logout
    } finally {
      // Always clear local state
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('user');

      _ref.read(authProvider.notifier).state = null;
    }
  }

  /// Load user from storage if tokens exist (used on startup)
  Future<void> loadFromStorage() async {
    try {
      // Optimization: Skip if already loaded
      if (_ref.read(authProvider) != null) return;

      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');

      if (userString != null && userString.isNotEmpty && userString != 'null') {
        final dynamic decoded = jsonDecode(userString);
        if (decoded != null && decoded is Map) {
          final userMap = Map<String, dynamic>.from(decoded);
          _ref.read(authProvider.notifier).state = AppUser.fromJson(userMap);
          debugPrint('AuthService: User loaded from storage');
        }
      }
    } catch (e, stack) {
      debugPrint('AuthService: Error loading user from storage: $e');
      debugPrint(stack.toString());
      await logout(); // Clear potentially corrupted data
    }
  }

  /// Fetch latest user profile from server
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _api.get('/auth/profile/');
      if (response.statusCode == 200) {
        return {'success': true, 'user': jsonDecode(response.body)};
      } else {
        return {'success': false, 'error': 'Failed to fetch profile'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // --- PRIVATE HELPERS ---

  Future<void> _saveAuthData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', data['access']);
    await prefs.setString('refresh_token', data['refresh']);
    await prefs.setString('user', jsonEncode(data['user']));
  }

  String _parseError(String responseBody) {
    try {
      final errorData = jsonDecode(responseBody);
      if (errorData is Map) {
        if (errorData.containsKey('non_field_errors')) {
          return errorData['non_field_errors'][0];
        }
        if (errorData.containsKey('detail')) return errorData['detail'];

        // Return first validation error found
        final String firstKey = errorData.keys.first;
        final dynamic val = errorData[firstKey];
        if (val is List) return '$firstKey: ${val[0]}';
        return val.toString();
      }
    } catch (_) {}
    return 'Action failed. Please try again.';
  }
}

/// Provider for the AuthService (Unified)
final authServiceProvider = Provider<AuthService>((ref) {
  final api = ref.watch(apiClientProvider);
  return AuthService(ref, api);
});
