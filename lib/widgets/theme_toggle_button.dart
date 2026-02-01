import 'package:flutter/material.dart';

import '../app_settings.dart';
import '../l10n/app_texts.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.settings.themeMode == ThemeMode.dark;
    return IconButton(
      tooltip: context.t(AppText.themeToggle),
      icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
      onPressed: context.settings.toggleTheme,
    );
  }
}
