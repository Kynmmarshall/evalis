import 'package:flutter/material.dart';

import '../app_settings.dart';
import '../l10n/app_texts.dart';

class LanguageMenuButton extends StatelessWidget {
  const LanguageMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AppLanguage>(
      tooltip: context.t(AppText.languageLabel),
      icon: const Icon(Icons.language),
      initialValue: context.settings.language,
      onSelected: context.settings.setLanguage,
      itemBuilder: (_) => AppLanguage.values
          .map(
            (language) => PopupMenuItem<AppLanguage>(
              value: language,
              child: Text(L10n.languageName(language)),
            ),
          )
          .toList(),
    );
  }
}
