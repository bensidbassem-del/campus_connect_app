import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/services/api_client.dart';

class AuthService {
  final ApiClient _api = ApiClient();
  
  // REGISTER - Connects to: POST /api/auth/register/
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String password2,
    required String firstName,
    required String lastName,
    required String studentId,
    String? birthDate,
    String? phone,
    String? address,
  }) async {
    try {
      final response = await _api.post('/auth/register/', {
        'username': username,
        'email': email,
        'password': password,
        'password2': password2,
        'first_name': firstName,
        'last_name': lastName,
        'student_id': studentId,
        if (birthDate != null) 'birth_date': birthDate,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
      });
      
      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': jsonDecode(response.body),
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  // LOGIN - Connects to: POST /api/auth/login/
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _api.post('/auth/login/', {
        'username': username,
        'password': password,
      });
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Save tokens
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', data['access']);
        await prefs.setString('refresh_token', data['refresh']);
        await prefs.setString('user', jsonEncode(data['user']));
        
        return {
          'success': true,
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'error': jsonDecode(response.body),
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  // GET USER PROFILE - Connects to: GET /api/auth/profile/
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _api.get('/auth/profile/');
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'user': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to fetch profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  // LOGOUT - Connects to: POST /api/auth/logout/
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get refresh token
    final refreshToken = prefs.getString('refresh_token');
    
    // Try to blacklist token on server
    if (refreshToken != null) {
      try {
        await _api.post('/auth/logout/', {
          'refresh': refreshToken,
        });
      } catch (e) {
        // Continue even if server request fails
      }
    }
    
    // Clear local storage
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user');
  }
  
  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('access_token');
  }
  
  // Get stored user data
  Future<Map<String, dynamic>?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');
    if (userString != null) {
      return jsonDecode(userString);
    }
    return null;
  }
}