import 'dart:convert';

import 'package:http/http.dart' as http;

const String _fallbackBaseUrl = String.fromEnvironment(
  'EVALIS_API_URL',
  defaultValue: 'http://38.242.246.126:4100/api',
);

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  final http.Client _http = http.Client();
  String _baseUrl = _fallbackBaseUrl;
  String? _token;

  void updateToken(String? token) {
    _token = token;
  }

  String? get token => _token;

  void configureBaseUrl(String baseUrl) {
    _baseUrl = baseUrl;
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) async {
    final uri = _buildUri(path, query);
    final response = await _http.get(uri, headers: _headers());
    return _decode(response);
  }

  Future<dynamic> post(String path, {Object? body}) async {
    final response = await _http.post(
      _buildUri(path),
      headers: _headers(),
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(response);
  }

  Future<http.Response> getRaw(String path, {Map<String, String>? query}) async {
    final uri = _buildUri(path, query);
    final response = await _http.get(uri, headers: _headers(contentType: false));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }
    dynamic body;
    if (response.body.isNotEmpty) {
      try {
        body = jsonDecode(response.body);
      } catch (_) {
        body = response.body;
      }
    }
    final message = body is Map<String, dynamic>
        ? (body['message']?.toString() ?? 'Request failed')
        : (body is String && body.isNotEmpty ? body : 'Request failed');
    throw ApiException(message, statusCode: response.statusCode);
  }

  Future<dynamic> put(String path, {Object? body}) async {
    final response = await _http.put(
      _buildUri(path),
      headers: _headers(),
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(response);
  }

  Future<dynamic> patch(String path, {Object? body}) async {
    final response = await _http.patch(
      _buildUri(path),
      headers: _headers(),
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(response);
  }

  Future<dynamic> delete(String path) async {
    final response = await _http.delete(
      _buildUri(path),
      headers: _headers(contentType: false),
    );
    return _decode(response);
  }

  Future<dynamic> send(http.BaseRequest request) async {
    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return _decode(response);
  }

  Uri resolve(String path, {Map<String, String>? query}) => _buildUri(path, query);

  Uri _buildUri(String path, [Map<String, String>? query]) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse(_baseUrl + normalizedPath);
    if (query == null || query.isEmpty) {
      return uri;
    }
    return uri.replace(queryParameters: query);
  }

  Map<String, String> _headers({bool contentType = true}) {
    final headers = <String, String>{};
    if (contentType) {
      headers['Content-Type'] = 'application/json';
    }
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  dynamic _decode(http.Response response) {
    final statusCode = response.statusCode;
    final rawBody = response.body;
    dynamic body;
    if (rawBody.isNotEmpty) {
      try {
        body = jsonDecode(rawBody);
      } on FormatException {
        body = rawBody;
      }
    }
    if (statusCode >= 200 && statusCode < 300) {
      return body;
    }
    final message = body is Map<String, dynamic>
        ? (body['message']?.toString() ?? 'Request failed')
        : (body is String && body.isNotEmpty ? body : 'Request failed');
    throw ApiException(message, statusCode: statusCode);
  }
}
