import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app_settings.dart';
import '../../l10n/app_texts.dart';
import '../../models/app_role.dart';
import '../../services/auth_service.dart';
import '../../theme.dart';
import '../auth/login_screen.dart';
import '../lecturer/lecturer_dashboard_screen.dart';
import '../student/student_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const routeName = '/splash';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      final role = AuthService.instance.resolveRole(session.user);
      _navigateToRole(role);
      return;
    }

    _goToLogin();
  }

  void _navigateToRole(AppRole role) {
    final target = role == AppRole.lecturer
        ? LecturerDashboardScreen.routeName
        : StudentDashboardScreen.routeName;
    Navigator.pushReplacementNamed(context, target);
  }

  void _goToLogin() {
    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.t(AppText.appTitle),
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall
                      ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Text(
                  context.t(AppText.splashTagline),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircularProgressIndicator(color: colorScheme.secondary),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        context.t(AppText.prototypeMessage),
                        softWrap: true,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.white70, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
