import 'package:flutter/material.dart';
import '../models/person_entry.dart';
import '../pages/calculator_page.dart';
import '../pages/calendar_page.dart';
import '../pages/member_list_page.dart';
import '../pages/home_page.dart';
import '../pages/group_data_page.dart';

class HomeShell extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const HomeShell({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  final List<PersonEntry> people = [];

  void _addPerson(PersonEntry p) => setState(() => people.add(p));
  void _removePerson(int i) => setState(() => people.removeAt(i));

  static const _titles = [
    'Kalkulator',
    'Kalender & Agenda',
    'Daftar Anggota',
    'Kegiatan & Notifikasi',
    'Data Kelompok',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_index],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: widget.isDark ? 'Mode Terang' : 'Mode Gelap',
            onPressed: widget.onToggleTheme,
            icon: Icon(
              widget.isDark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              color: const Color(0xFFE91E63),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      // Menggunakan IndexedStack agar state halaman (seperti data kalkulator/kalender) tidak ter-reset saat berpindah tab
      body: IndexedStack(
        index: _index,
        children: [
          const CalculatorPage(),
          const CalendarPage(),
          const MemberListPage(),
          const HomePage(),
          GroupDataPage(
            people: people,
            onAdd: _addPerson,
            onRemove: _removePerson,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate_rounded, color: Color(0xFF7B1FA2)),
            label: 'Kalkulator',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded, color: Color(0xFF7B1FA2)),
            label: 'Kalender',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people_rounded, color: Color(0xFF7B1FA2)),
            label: 'Anggota',
          ),
          NavigationDestination(
            icon: Icon(Icons.notification_add_outlined),
            selectedIcon: Icon(Icons.notification_add_rounded, color: Color(0xFF7B1FA2)),
            label: 'Kegiatan',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups_rounded, color: Color(0xFF7B1FA2)),
            label: 'Kelompok',
          ),
        ],
      ),
    );
  }
}