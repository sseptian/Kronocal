import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'widgets/home_shell.dart';
import 'pages/login_page.dart';
import 'utils/session_manager.dart';
import 'utils/db_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.db;
  runApp(const KronoCalcApp());
}

class KronoCalcApp extends StatefulWidget {
  const KronoCalcApp({super.key});
  @override
  State<KronoCalcApp> createState() => _KronoCalcAppState();
}

class _KronoCalcAppState extends State<KronoCalcApp> {
  ThemeMode _themeMode = ThemeMode.light;
  bool _loggedIn = SessionManager.isLoggedIn;

  void _toggleTheme() => setState(() {
        _themeMode =
            _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
      });

  void _onLoginSuccess() => setState(() => _loggedIn = true);
  void _onLogout() => setState(() => _loggedIn = false);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KronoCalc',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: AppTheme.buildTheme(Brightness.light),
      darkTheme: AppTheme.buildTheme(Brightness.dark),
      home: _loggedIn
          ? HomeShell(
              isDark: _themeMode == ThemeMode.dark,
              onToggleTheme: _toggleTheme,
              onLogout: _onLogout,
            )
          : LoginPage(onLoginSuccess: _onLoginSuccess),
    );
  }
}