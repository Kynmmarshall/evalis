import 'package:flutter/material.dart';

import 'l10n/app_texts.dart';

class AppSettings extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  AppLanguage _language = AppLanguage.english;

  ThemeMode get themeMode => _themeMode;
  AppLanguage get language => _language;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setLanguage(AppLanguage language) {
    if (_language == language) return;
    _language = language;
    notifyListeners();
  }
}

class AppSettingsScope extends InheritedNotifier<AppSettings> {
  const AppSettingsScope({required AppSettings settings, required Widget child, super.key})
      : super(notifier: settings, child: child);

  static AppSettings of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppSettingsScope>();
    assert(scope != null, 'AppSettingsScope not found in context');
    return scope!.notifier!;
  }
}

extension EvalisContext on BuildContext {
  AppSettings get settings => AppSettingsScope.of(this);
  String t(AppText key) => L10n.text(settings.language, key);
}
