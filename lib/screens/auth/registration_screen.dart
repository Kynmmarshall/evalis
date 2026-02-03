import 'package:flutter/material.dart';

import '../../app_settings.dart';
import '../../l10n/app_texts.dart';
import '../../models/app_role.dart';

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
  AppRole _role = AppRole.student;

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
      appBar: AppBar(title: Text(context.t(AppText.registerTitle))),
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
                        backgroundColor: colorScheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Text(context.t(AppText.roleLabel), style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 12),
            SegmentedButton<AppRole>(
              segments: [
                ButtonSegment(value: AppRole.lecturer, label: Text(context.t(AppText.lecturerRole))),
                ButtonSegment(value: AppRole.student, label: Text(context.t(AppText.studentRole))),
              ],
              selected: <AppRole>{_role},
              onSelectionChanged: (value) => setState(() => _role = value.first),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleRegistration,
                child: Text(context.t(AppText.registerButton)),
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

  void _handleRegistration() {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.t(AppText.passwordMismatch))));
      return;
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.t(AppText.registrationSuccess))));
    Navigator.pop(context);
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
}
