import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  // Change this to your Django server URL
  static const String baseUrl = 'http://localhost:8000/api';

  // For Android emulator, use: http://10.0.2.2:8000/api
  // For iOS simulator, use: http://localhost:8000/api
  // For physical device, use your computer's IP: http://192.168.1.100:8000/api

  // Get stored JWT token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // GET request
  Future<http.Response> get(String endpoint) async {
    final token = await _getToken();

    return await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  // POST request
  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final token = await _getToken();

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
  Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    final token = await _getToken();

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
  Future<http.Response> delete(String endpoint) async {
    final token = await _getToken();

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
