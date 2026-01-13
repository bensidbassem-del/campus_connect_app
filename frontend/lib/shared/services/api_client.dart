import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

class ApiClient {
  // Use a Completer to handle concurrent refresh requests
  Completer<bool>? _refreshCompleter;

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

  // Refresh the access token using the refresh token
  Future<bool> _refreshToken() async {
    // If a refresh is already in progress, return the future result
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<bool>();

    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');

      if (refreshToken == null) {
        _refreshCompleter!.complete(false);
        _refreshCompleter = null;
        return false;
      }

      final response = await http.post(
        Uri.parse('${baseUrl}auth/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await prefs.setString('access_token', data['access']);
        if (data.containsKey('refresh')) {
          await prefs.setString('refresh_token', data['refresh']);
        }
        debugPrint('ApiClient: Token refreshed successfully');
        _refreshCompleter!.complete(true);
        _refreshCompleter = null;
        return true;
      }

      _refreshCompleter!.complete(false);
      _refreshCompleter = null;
      return false;
    } catch (e) {
      debugPrint('ApiClient: Token refresh failed: $e');
      if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
        _refreshCompleter!.complete(false);
        _refreshCompleter = null;
      }
      return false;
    }
  }

  // GET request with automatic token refresh
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? queryParams,
    bool includeToken = true,
  }) async {
    var token = includeToken ? await _getToken() : null;

    final url = _buildUrl(endpoint, queryParams);
    debugPrint('ApiClient GET: $url');
    var response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    // Auto-refresh on 401 and retry once
    if (response.statusCode == 401 && includeToken) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        token = await _getToken();
        response = await http.get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        );
      }
    }

    debugPrint('ApiClient Response [${response.statusCode}]: $url');
    return response;
  }

  // POST request with automatic token refresh
  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool includeToken = true,
  }) async {
    var token = includeToken ? await _getToken() : null;

    final url = _buildUrl(endpoint);
    debugPrint('ApiClient POST: $url');
    var response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    // Auto-refresh on 401 and retry once
    if (response.statusCode == 401 && includeToken) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        token = await _getToken();
        response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
          body: jsonEncode(data),
        );
      }
    }

    debugPrint('ApiClient Response [${response.statusCode}]: $url');
    return response;
  }

  // PUT request with automatic token refresh
  Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> data, {
    bool includeToken = true,
  }) async {
    var token = includeToken ? await _getToken() : null;
    final url = _buildUrl(endpoint);

    var response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    // Auto-refresh on 401 and retry once
    if (response.statusCode == 401 && includeToken) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        token = await _getToken();
        response = await http.put(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
          body: jsonEncode(data),
        );
      }
    }

    return response;
  }

  // DELETE request with automatic token refresh
  Future<http.Response> delete(
    String endpoint, {
    bool includeToken = true,
  }) async {
    var token = includeToken ? await _getToken() : null;
    final url = _buildUrl(endpoint);

    var response = await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    // Auto-refresh on 401 and retry once
    if (response.statusCode == 401 && includeToken) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        token = await _getToken();
        response = await http.delete(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        );
      }
    }

    return response;
  }

  // Upload file (multipart)
  Future<http.StreamedResponse> uploadFile(
    String endpoint,
    String filePath,
    Map<String, String> fields, {
    String fileKey = 'file',
  }) async {
    final token = await _getToken();

    final url = _buildUrl(endpoint);
    var request = http.MultipartRequest('POST', Uri.parse(url));

    // Add authorization header
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Add file
    request.files.add(await http.MultipartFile.fromPath(fileKey, filePath));

    // Add other fields
    request.fields.addAll(fields);

    return await request.send();
  }
}
