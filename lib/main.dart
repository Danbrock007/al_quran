import 'package:flutter/material.dart';
import 'core/app_config.dart';
import 'core/app_theme.dart';
import 'screens/app_shell.dart';
import 'services/notification_service.dart';
import 'services/preferences_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();
  runApp(const AlQuranApp());
}

class AlQuranApp extends StatefulWidget {
  const AlQuranApp({super.key});

  @override
  State<AlQuranApp> createState() => _AlQuranAppState();
}

class _AlQuranAppState extends State<AlQuranApp> {
  final _preferences = PreferencesService();
  bool _dark = false;

  @override
  void initState() {
    super.initState();
    _preferences.darkMode().then((value) {
      if (mounted) setState(() => _dark = value);
    });
  }

  Future<void> _setDark(bool value) async {
    setState(() => _dark = value);
    await _preferences.setDarkMode(value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConfig.appName,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
      home: AppShell(darkMode: _dark, onDarkModeChanged: _setDark),
    );
  }
}

