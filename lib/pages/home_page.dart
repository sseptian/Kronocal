import 'package:flutter/material.dart';
import 'calendar_page.dart';
import 'date_conversion_page.dart';
import 'date_time_calculator_page.dart';
import 'group_data_page.dart';
import 'time_age_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Daftar Anggota', 'Kelola nama dan NIM anggota kelompok', Icons.groups_rounded, const GroupDataPage()),
      ('Kalkulator Penanggalan', 'Hitung selisih dan tambah/kurang tanggal', Icons.calculate_rounded, const DateTimeCalculatorPage()),
      ('Konversi Kalender', 'Masehi, Hijriah, Weton, Shio, dan Saka Bali', Icons.event_available_rounded, const DateConversionPage()),
      ('Konversi Waktu & Umur', 'Hitung umur dan konversi durasi waktu', Icons.access_time_filled_rounded, const TimeAgePage()),
      ('Kalender & Agenda', 'Simpan, ubah, dan hapus agenda kegiatan', Icons.calendar_month_rounded, const CalendarPage()),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Card(
          color: const Color(0xFFF3E5F5),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(0xFF7B1FA2),
                  child: Icon(Icons.access_time_rounded, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('KronoCalc', style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold, color: const Color(0xFF4A148C))),
                      const SizedBox(height: 3),
                      Text('Kalkulator penanggalan dan waktu',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text('Menu Utama', style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold, color: const Color(0xFF7B1FA2))),
        const SizedBox(height: 10),
        ...items.map((item) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFF3E5F5),
              child: Icon(item.$3, color: const Color(0xFFE91E63)),
            ),
            title: Text(item.$1, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(item.$2),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _open(context, item.$4),
          ),
        )),
      ],
    );
  }
}
