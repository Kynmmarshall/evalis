import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_role.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final SupabaseClient _client = Supabase.instance.client;

  Future<AppRole> signInWithEmail({
    required String email,
    required String password,
    AppRole? fallbackRole,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    return _extractRole(response.user?.userMetadata) ?? fallbackRole ?? AppRole.student;
  }

  Future<AppRole> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required AppRole role,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': role.name,
      },
    );

    return _extractRole(response.user?.userMetadata) ?? role;
  }

  AppRole resolveRole(User? user, {AppRole fallback = AppRole.student}) {
    return _extractRole(user?.userMetadata) ?? fallback;
  }

  AppRole? _extractRole(Map<String, dynamic>? metadata) {
    final value = metadata?['role'];
    if (value is String) {
      final normalized = value.toLowerCase();
      for (final role in AppRole.values) {
        if (role.name == normalized) {
          return role;
        }
      }
    }
    return null;
  }
}
