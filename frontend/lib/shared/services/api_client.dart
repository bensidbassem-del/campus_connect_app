import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    } else if (Platform.isAndroid) {
      // 10.0.2.2 is the special IP that points to the host computer's localhost
      return 'http://10.0.2.2:8000/api';
    } else {
      return 'http://localhost:8000/api';
    }
  }

  // NOTE: If using a PHYSICAL device, you must:
  // 1. Connect both phone and computer to the same Wi-Fi
  // 2. Change the IP below to your computer's local IP (e.g., 192.168.1.5)
  // 3. Run Django with: py manage.py runserver 0.0.0.0:8000
  // static const String baseUrl = 'http://192.168.1.5:8000/api';

  // Get stored JWT token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // GET request
  Future<http.Response> get(String endpoint, {bool includeToken = true}) async {
    final token = includeToken ? await _getToken() : null;

    return await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  // POST request
  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool includeToken = true,
  }) async {
    final token = includeToken ? await _getToken() : null;

    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
  }

  // PUT request
  Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> data, {
    bool includeToken = true,
  }) async {
    final token = includeToken ? await _getToken() : null;

    return await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
  }

  // DELETE request
  Future<http.Response> delete(
    String endpoint, {
    bool includeToken = true,
  }) async {
    final token = includeToken ? await _getToken() : null;

    return await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  // Upload file (multipart)
  Future<http.StreamedResponse> uploadFile(
    String endpoint,
    String filePath,
    Map<String, String> fields,
  ) async {
    final token = await _getToken();

    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));

    // Add authorization header
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Add file
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    // Add other fields
    request.fields.addAll(fields);

    return await request.send();
  }
}
