import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_role.dart';
import 'api_client.dart';

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  static const String _tokenKey = 'evalis_auth_token';

  final ApiClient _api = ApiClient.instance;
  AppRole? _cachedRole;

  AppRole? get currentRole => _cachedRole;
  String? get token => _api.token;

  Future<AppRole?> bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null) {
      return null;
    }
    _api.updateToken(token);
    try {
      final response = await _api.get('/auth/me') as Map<String, dynamic>;
      final user = response['user'] as Map<String, dynamic>?;
      _cachedRole = _extractRole(user) ?? AppRole.student;
      return _cachedRole;
    } on ApiException {
      await signOut();
      return null;
    }
  }

  Future<AppRole> signInWithEmail({
    required String email,
    required String password,
    AppRole? fallbackRole,
  }) async {
    try {
      final response = await _api.post(
        '/auth/login',
        body: {
          'email': email,
          'password': password,
        },
      ) as Map<String, dynamic>;
      return _persistSession(response, fallbackRole: fallbackRole);
    } on ApiException catch (error) {
      throw AuthException(error.message);
    }
  }

  Future<AppRole> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required AppRole role,
  }) async {
    try {
      final response = await _api.post(
        '/auth/register',
        body: {
          'email': email,
          'password': password,
          'name': fullName,
          'role': role.name,
        },
      ) as Map<String, dynamic>;
      return _persistSession(response, fallbackRole: role);
    } on ApiException catch (error) {
      throw AuthException(error.message);
    }
  }

  Future<void> signOut() async {
    _cachedRole = null;
    _api.updateToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  AppRole resolveRole({AppRole fallback = AppRole.student}) {
    return _cachedRole ?? fallback;
  }

  AppRole _persistSession(
    Map<String, dynamic> response, {
    AppRole? fallbackRole,
  }) {
    final token = response['token'] as String?;
    final user = response['user'] as Map<String, dynamic>?;
    if (token == null || user == null) {
      throw const AuthException('Malformed response from server');
    }
    _api.updateToken(token);
    _cachedRole = _extractRole(user) ?? fallbackRole ?? AppRole.student;
    _persistToken(token);
    return _cachedRole!;
  }

  Future<void> _persistToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  AppRole? _extractRole(Map<String, dynamic>? payload) {
    final raw = payload?['role'];
    final asString = raw is String ? raw : payload?['role_label'];
    if (asString is String) {
      final normalized = asString.toLowerCase();
      for (final role in AppRole.values) {
        if (role.name == normalized) {
          return role;
        }
      }
    }
    return null;
  }
}
