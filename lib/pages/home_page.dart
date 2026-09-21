import 'package:flutter/material.dart';
import 'member_list_page.dart';
import 'calendar_page.dart';
import 'calculator_page.dart';
import 'group_data_page.dart'; // Menggunakan snake_case untuk nama file

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMenuButton(
                context,
                'Daftar Anggota',
                Icons.people,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MemberListPage()),
                ),
              ),
              const SizedBox(height: 12),
              _buildMenuButton(
                context,
                'Kalender',
                Icons.calendar_month,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CalendarPage()),
                ),
              ),
              const SizedBox(height: 12),
              _buildMenuButton(
                context,
                'Kalkulator', // Disesuaikan dengan CalculatorPage
                Icons.calculate,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CalculatorPage()),
                ),
              ),
              // const SizedBox(height: 12),
              // _buildMenuButton(
              //   context,
              //   'Data Kelompok', 
              //   Icons.group,
              //   () => Navigator.push(
              //     context,
              //     MaterialPageRoute(builder: (_) => const GroupDataPage ()),
              //   ),
              // ),
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: 220, // Memberikan lebar seragam untuk semua tombol
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}