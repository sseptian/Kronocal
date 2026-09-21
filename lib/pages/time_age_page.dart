import 'package:flutter/material.dart';
import '../utils/date_converter.dart';

class TimeAgePage extends StatefulWidget {
  const TimeAgePage({super.key});
  @override State<TimeAgePage> createState() => _TimeAgePageState();
}

class _TimeAgePageState extends State<TimeAgePage> {
  DateTime _birthDate = DateTime(2005, 11, 22, 8, 0);
  final TextEditingController _durationController = TextEditingController(text: '3661');

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context, initialDate: _birthDate, firstDate: DateTime(1), lastDate: DateTime.now(),
      helpText: 'Pilih Tanggal Lahir',
    );
    if (picked == null) return;
    final pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_birthDate));
    if (pickedTime == null) return;
    setState(() => _birthDate = DateTime(picked.year, picked.month, picked.day, pickedTime.hour, pickedTime.minute));
  }

  String _durationFromSeconds(String value) {
    final total = int.tryParse(value.trim());
    if (total == null || total < 0) return 'Masukkan jumlah detik yang valid.';
    final days = total ~/ 86400;
    final hours = (total % 86400) ~/ 3600;
    final minutes = (total % 3600) ~/ 60;
    final seconds = total % 60;
    return '\$days Hari \$hours Jam \$minutes Menit \$seconds Detik';
  }

  @override
  Widget build(BuildContext context) {
    final age = DateConverter.hitungUmurLengkap(_birthDate);
    return Scaffold(
      appBar: AppBar(title: const Text('Konversi Waktu & Umur')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Hitung Umur', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text('Masukkan tanggal dan waktu lahir untuk menghitung umur lengkap.'),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.cake_rounded, color: Color(0xFFE91E63)),
                  title: const Text('Tanggal & Waktu Lahir'),
                  subtitle: Text('\${_birthDate.day}/\${_birthDate.month}/\${_birthDate.year} \${TimeOfDay.fromDateTime(_birthDate).format(context)}'),
                  onTap: _pickBirthDate,
                ),
                const Divider(),
                Text(age, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF7B1FA2))),
              ]),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Konversi Durasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text('Ubah total detik menjadi hari, jam, menit, dan detik.'),
                const SizedBox(height: 14),
                TextField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Total Detik', prefixIcon: Icon(Icons.timer_outlined)),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                Text(_durationFromSeconds(_durationController.text),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF7B1FA2))),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
