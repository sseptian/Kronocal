import 'package:flutter/material.dart';
import '../utils/session_manager.dart';
import '../utils/date_converter.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});
  Widget _guide(IconData icon, String title, List<String> steps) => Card(
    child: ExpansionTile(
      leading: CircleAvatar(backgroundColor: const Color(0xFFF3E5F5), child: Icon(icon, color: const Color(0xFFE91E63))),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: [Padding(padding: const EdgeInsets.fromLTRB(20,0,20,16), child: Column(
        children: List.generate(steps.length, (i) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text((i+1).toString()+'.', style: const TextStyle(color: Color(0xFF7B1FA2), fontWeight: FontWeight.bold)),
            const SizedBox(width: 8), Expanded(child: Text(steps[i])),
          ]),
        )),
      ))],
    ),
  );

  @override Widget build(BuildContext context) {
    final loginTime = SessionManager.loginTime;
    return Scaffold(
      appBar: AppBar(title: const Text('Bantuan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(color: const Color(0xFFF3E5F5), child: ListTile(
            leading: const CircleAvatar(backgroundColor: Color(0xFF7B1FA2), child: Icon(Icons.person, color: Colors.white)),
            title: Text(SessionManager.username, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(loginTime == null ? 'Sesi tidak aktif' : 'Masuk sejak ' + DateConverter.masehi(loginTime)),
          )),
          const SizedBox(height: 16),
          _guide(Icons.calculate, 'Kalkulator', ['Masukkan angka dan operator lalu tekan = untuk menghitung.', 'Gunakan AC, backspace, +/-, dan %.']),
          _guide(Icons.event, 'Penanggalan', ['Pilih tanggal untuk melihat Masehi, Hijriah, Weton Jawa, Shio, Saka Bali, dan umur.', 'Gunakan Date Math untuk menggeser tanggal beberapa hari.']),
          _guide(Icons.timer, 'Stopwatch', ['Tekan Mulai untuk menjalankan stopwatch.', 'Tekan Lap untuk mencatat putaran dan Reset untuk menghapusnya.']),
          _guide(Icons.groups, 'Data Kelompok', ['Tambah anggota dengan nama dan tanggal lahir.', 'Data disimpan di SQLite sehingga tetap tersedia setelah aplikasi ditutup.']),
          const SizedBox(height: 12),
          const Center(child: Text('KronoCalc versi 1.0.0')),
        ],
      ),
    );
  }
}