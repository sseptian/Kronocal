import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'widgets/home_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KronoCalcApp());
}

class KronoCalcApp extends StatefulWidget {
  const KronoCalcApp({super.key});

  /// Mengizinkan widget anak untuk mengakses fungsi toggleTheme secara global
  static _KronoCalcAppState of(BuildContext context) {
    return context.findAncestorStateOfType<_KronoCalcAppState>()!;
  }

  @override
  State<KronoCalcApp> createState() => _KronoCalcAppState();
}

class _KronoCalcAppState extends State<KronoCalcApp> {
  ThemeMode _themeMode = ThemeMode.light;

  bool get isDark => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KronoCalc',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: AppTheme.buildTheme(Brightness.light),
      darkTheme: AppTheme.buildTheme(Brightness.dark),
      home: HomeShell(
        isDark: isDark,
        onToggleTheme: toggleTheme,
      ),
    );
  }
}