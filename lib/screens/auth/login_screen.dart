import 'package:flutter/material.dart';

import '../../app_settings.dart';
import '../../l10n/app_texts.dart';
import '../../models/app_role.dart';
import '../../services/auth_service.dart';
import '../../widgets/language_menu_button.dart';
import '../../widgets/theme_toggle_button.dart';
import '../landing/landing_screen.dart';
import '../lecturer/lecturer_dashboard_screen.dart';
import '../student/student_dashboard_screen.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = '/auth/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  AppRole _selectedRole = AppRole.lecturer;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  ThemeToggleButton(),
                  SizedBox(width: 8),
                  LanguageMenuButton(),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                context.t(AppText.loginTitle),
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(context.t(AppText.loginSubtitle), style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 24),
              SegmentedButton<AppRole>(
                segments: [
                  ButtonSegment(
                    value: AppRole.lecturer,
                    label: Text(context.t(AppText.lecturerRole)),
                    icon: const Icon(Icons.campaign_rounded),
                  ),
                  ButtonSegment(
                    value: AppRole.student,
                    label: Text(context.t(AppText.studentRole)),
                    icon: const Icon(Icons.school_rounded),
                  ),
                ],
                selected: <AppRole>{_selectedRole},
                onSelectionChanged:
                    _isSubmitting ? null : (value) => setState(() => _selectedRole = value.first),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: context.t(AppText.emailLabel),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: context.t(AppText.passwordLabel),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleLogin,
                  child: _isSubmitting
                      ? SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : Text(context.t(AppText.loginButton)),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                            final result = await Navigator.pushNamed(
                              context,
                              RegistrationScreen.routeName,
                            );
                            if (!mounted || result is! AppRole) return;
                            setState(() => _selectedRole = result);
                          },
                  child: Text(context.t(AppText.registerLink)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: Divider(color: colorScheme.outlineVariant)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      context.t(AppText.guestDivider),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Expanded(child: Divider(color: colorScheme.outlineVariant)),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _continueAsGuest(AppRole.lecturer),
                  icon: const Icon(Icons.edit_note_rounded),
                  label: Text(context.t(AppText.guestLecturer)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _continueAsGuest(AppRole.student),
                  icon: const Icon(Icons.emoji_people_rounded),
                  label: Text(context.t(AppText.guestStudent)),
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => Navigator.pushNamed(context, LandingScreen.routeName),
                  icon: const Icon(Icons.travel_explore_rounded),
                  label: Text(context.t(AppText.exploreLanding)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError(context.t(AppText.authMissingCredentials));
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() => _isSubmitting = true);
    try {
      final role = await AuthService.instance.signInWithEmail(
        email: email,
        password: password,
        fallbackRole: _selectedRole,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.t(AppText.loginSuccess))));
      _navigateToRole(role);
    } on AuthException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError(context.t(AppText.authGenericError));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _continueAsGuest(AppRole role) {
    _navigateToRole(role);
  }

  void _navigateToRole(AppRole role) {
    final route = role == AppRole.lecturer
        ? LecturerDashboardScreen.routeName
        : StudentDashboardScreen.routeName;
    Navigator.pushReplacementNamed(context, route);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
