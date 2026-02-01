import 'package:flutter/material.dart';

import '../../app_settings.dart';
import '../../l10n/app_texts.dart';
import '../../theme.dart';
import '../../widgets/language_menu_button.dart';
import '../../widgets/theme_toggle_button.dart';
import '../lecturer/lecturer_dashboard_screen.dart';
import '../student/student_dashboard_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [ThemeToggleButton(), SizedBox(width: 8), LanguageMenuButton()],
                ),
                const Spacer(),
                Text(
                  context.t(AppText.heroTitle),
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                Text(
                  context.t(AppText.heroSubtitle),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.white.withValues(alpha: 0.88)),
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit_note_rounded),
                      label: Text(context.t(AppText.lecturerCta)),
                      onPressed: () => Navigator.pushNamed(context, LecturerDashboardScreen.routeName),
                    ),
                    FilledButton.icon(
                      icon: const Icon(Icons.school_rounded),
                      label: Text(context.t(AppText.studentCta)),
                      onPressed: () => Navigator.pushNamed(context, StudentDashboardScreen.routeName),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.white70),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.t(AppText.prototypeMessage),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.white70, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(Icons.arrow_downward_rounded,
                      color: colorScheme.secondary.withValues(alpha: 0.5)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
