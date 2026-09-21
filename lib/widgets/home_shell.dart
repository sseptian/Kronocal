import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/stopwatch_page.dart';
import '../pages/help_page.dart';
import '../utils/session_manager.dart';

class HomeShell extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;
  final VoidCallback onLogout;
  const HomeShell({super.key, required this.isDark, required this.onToggleTheme, required this.onLogout});
  @override State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  static const _titles = ['Home', 'Stopwatch', 'Bantuan'];

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari Aplikasi?'),
        content: Text('Sesi \${SessionManager.username} akan diakhiri.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Ya, Keluar')),
        ],
      ),
    );
    if (ok == true && mounted) {
      SessionManager.logout();
      widget.onLogout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const HomePage(),
      const StopwatchPage(),
      HelpPage(onLogout: _logout),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index], style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: widget.isDark ? 'Mode Terang' : 'Mode Gelap',
            onPressed: widget.onToggleTheme,
            icon: Icon(widget.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: const Color(0xFFE91E63)),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded, color: Color(0xFF7B1FA2)), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.timer_outlined), selectedIcon: Icon(Icons.timer_rounded, color: Color(0xFF7B1FA2)), label: 'Stopwatch'),
          NavigationDestination(icon: Icon(Icons.help_outline_rounded), selectedIcon: Icon(Icons.help_rounded, color: Color(0xFF7B1FA2)), label: 'Bantuan'),
        ],
      ),
    );
  }
}
