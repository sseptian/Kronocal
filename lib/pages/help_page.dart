import 'package:flutter/material.dart';
import '../utils/session_manager.dart';
import '../utils/date_converter.dart';

class HelpPage extends StatelessWidget {
  final VoidCallback? onLogout;
  const HelpPage({super.key, this.onLogout});

  Widget _guide(IconData icon, String title, List<String> steps) => Card(
    child: ExpansionTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFF3E5F5),
        child: Icon(icon, color: const Color(0xFFE91E63)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            children: List.generate(steps.length, (i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('\${i + 1}.', style: const TextStyle(color: Color(0xFF7B1FA2), fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(steps[i])),
                ],
              ),
            )),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final loginTime = SessionManager.loginTime;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: const Color(0xFFF3E5F5),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF7B1FA2),
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(SessionManager.username, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(loginTime == null ? 'Sesi tidak aktif' : 'Masuk sejak \${DateConverter.masehi(loginTime)}'),
          ),
        ),
        const SizedBox(height: 16),
        _guide(Icons.groups, 'Daftar Anggota', [
          'Buka Daftar Anggota dari Home.',
          'Tambah anggota menggunakan Nama dan NIM. Tanggal lahir tidak diperlukan.',
          'Gunakan tombol hapus untuk menghapus data anggota.',
        ]),
        _guide(Icons.calculate, 'Kalkulator Penanggalan', [
          'Pilih dua tanggal untuk menghitung selisih hari.',
          'Pilih waktu mulai dan selesai untuk menghitung durasi.',
        ]),
        _guide(Icons.event_available, 'Konversi Kalender', [
          'Pilih tanggal untuk melihat Masehi, Hijriah, Weton Jawa, Shio, dan Saka Bali.',
          'Gunakan Date Math untuk menambah atau mengurangi hari.',
        ]),
        _guide(Icons.access_time, 'Konversi Waktu & Umur', [
          'Pilih tanggal dan waktu lahir.',
          'Aplikasi menampilkan umur dalam tahun, bulan, hari, jam, menit, dan detik.',
          'Konversi durasi juga dapat mengubah total detik menjadi hari, jam, menit, dan detik.',
        ]),
        _guide(Icons.calendar_month, 'Kalender & Agenda', [
          'Pilih tanggal pada kalender.',
          'Tambah agenda dengan tombol +.',
          'Gunakan menu Edit atau Hapus pada agenda. Fitur ini merupakan CRUD agenda.',
        ]),
        _guide(Icons.timer, 'Stopwatch', [
          'Tekan Mulai untuk menjalankan stopwatch.',
          'Tekan Lap untuk mencatat putaran dan Reset untuk menghapusnya.',
        ]),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onLogout,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout'),
          ),
        ),
        const SizedBox(height: 8),
        const Center(child: Text('KronoCalc versi 1.0.0')),
      ],
    );
  }
}
