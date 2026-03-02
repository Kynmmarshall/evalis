import 'package:flutter/material.dart';

import '../../app_settings.dart';
import '../../l10n/app_texts.dart';
import '../../services/auth_service.dart';
import '../../widgets/language_menu_button.dart';
import '../../widgets/theme_toggle_button.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  static const routeName = '/auth/register';

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t(AppText.registerTitle)),
        actions: const [
          ThemeToggleButton(),
          SizedBox(width: 4),
          LanguageMenuButton(),
          SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.t(AppText.registerSubtitle), style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: context.t(AppText.fullNameLabel),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),
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
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: context.t(AppText.passwordConfirmLabel),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 12),
            Builder(
              builder: (context) {
                final strength = _passwordStrength;
                final colorScheme = Theme.of(context).colorScheme;
                final color = _strengthColor(strength, colorScheme);
                final label = '${context.t(AppText.passwordStrengthLabel)} - '
                  '${context.t(_strengthLabelKey(strength))}';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: color, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        minHeight: 6,
                        value: strength,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleRegistration,
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
                    : Text(context.t(AppText.registerButton)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(context.t(AppText.haveAccount)),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.t(AppText.goToLogin)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRegistration() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final fullName = _nameController.text.trim();

    if (password != confirmPassword) {
      _showError(context.t(AppText.passwordMismatch));
      return;
    }

    if (email.isEmpty || password.isEmpty) {
      _showError(context.t(AppText.authMissingCredentials));
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() => _isSubmitting = true);
    try {
      await AuthService.instance.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.t(AppText.registrationSuccess))));
      Navigator.pop(context);
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

  double get _passwordStrength => _calculatePasswordStrength(_passwordController.text);

  double _calculatePasswordStrength(String password) {
    double score = 0;
    if (password.length >= 8) score += 0.3;
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 0.2;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 0.2;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) score += 0.3;
    return score.clamp(0, 1);
  }

  AppText _strengthLabelKey(double value) {
    if (value >= 0.75) return AppText.passwordStrengthStrong;
    if (value >= 0.4) return AppText.passwordStrengthMedium;
    return AppText.passwordStrengthWeak;
  }

  Color _strengthColor(double value, ColorScheme scheme) {
    if (value >= 0.75) return scheme.primary;
    if (value >= 0.4) return scheme.secondary;
    return scheme.error;
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
