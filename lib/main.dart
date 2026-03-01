import 'package:flutter/material.dart';

import 'app_settings.dart';
import 'l10n/app_texts.dart';
import 'routing/app_router.dart';
import 'screens/startup/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://fshklqbpmzqogiixjspe.supabase.co',
    anonKey: 'sb_publishable_URRjCW_tZ80ismwpuu3YPw_WLhoDjDh',
  );
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final AppSettings _settings = AppSettings();

  @override
  void dispose() {
    _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSettingsScope(
      settings: _settings,
      child: AnimatedBuilder(
        animation: _settings,
        builder: (context, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: L10n.text(_settings.language, AppText.appTitle),
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: _settings.themeMode,
            initialRoute: SplashScreen.routeName,
            onGenerateRoute: AppRouter.onGenerateRoute,
          );
        },
      ),
    );
  }
}
