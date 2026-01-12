import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

class ApiClient {
  static String get baseUrl {
    String host;
    if (kIsWeb) {
      host = 'http://localhost:8000';
    } else if (Platform.isAndroid) {
      // 10.0.2.2 is the host loopback for Android emulators
      host = 'http://10.0.2.2:8000';
    } else {
      // iOS simulators and Desktop use localhost
      host = 'http://localhost:8000';
    }
    return '$host/api/';
  }

  // Helper to ensure URL joining is safe
  String _buildUrl(String endpoint, [Map<String, String>? queryParams]) {
    final cleanEndpoint = endpoint.startsWith('/')
        ? endpoint.substring(1)
        : endpoint;

    final uri = Uri.parse('$baseUrl$cleanEndpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams).toString();
    }
    return uri.toString();
  }

  // Get stored JWT token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  // GET request
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? queryParams,
    bool includeToken = true,
  }) async {
    final token = includeToken ? await _getToken() : null;

    final url = _buildUrl(endpoint, queryParams);
    debugPrint('ApiClient GET: $url');
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    debugPrint('ApiClient Response [${response.statusCode}]: $url');
    return response;
  }

  // POST request
  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool includeToken = true,
  }) async {
    final token = includeToken ? await _getToken() : null;

    final url = _buildUrl(endpoint);
    debugPrint('ApiClient POST: $url');
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    debugPrint('ApiClient Response [${response.statusCode}]: $url');
    return response;
  }

  // PUT request
  Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> data, {
    bool includeToken = true,
  }) async {
    final token = includeToken ? await _getToken() : null;

    return await http.put(
      Uri.parse(_buildUrl(endpoint)),
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
      Uri.parse(_buildUrl(endpoint)),
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
