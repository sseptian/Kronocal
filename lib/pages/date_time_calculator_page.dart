import 'package:flutter/material.dart';
import '../utils/date_converter.dart';

class DateTimeCalculatorPage extends StatefulWidget {
  const DateTimeCalculatorPage({super.key});
  @override State<DateTimeCalculatorPage> createState() => _DateTimeCalculatorPageState();
}

class _DateTimeCalculatorPageState extends State<DateTimeCalculatorPage> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 16, minute: 0);

  Future<void> _pickDate(bool start) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: start ? _startDate : _endDate,
      firstDate: DateTime(1),
      lastDate: DateTime(9999),
    );
    if (picked != null) setState(() => start ? _startDate = picked : _endDate = picked);
  }

  Future<void> _pickTime(bool start) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: start ? _startTime : _endTime,
    );
    if (picked != null) setState(() => start ? _startTime = picked : _endTime = picked);
  }

  String _dateDifference() {
    final a = DateTime(_startDate.year, _startDate.month, _startDate.day);
    final b = DateTime(_endDate.year, _endDate.month, _endDate.day);
    final diff = b.difference(a).inDays.abs();
    return '$diff Hari = ${diff ~/ 7} Minggu ${diff % 7} Hari';
  }

  String _timeDifference() {
    final a = DateTime(2000, 1, 1, _startTime.hour, _startTime.minute);
    var b = DateTime(2000, 1, 1, _endTime.hour, _endTime.minute);
    if (b.isBefore(a)) b = b.add(const Duration(days: 1));
    final diff = b.difference(a);
    return '${diff.inHours} Jam ${diff.inMinutes.remainder(60)} Menit';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kalkulator Penanggalan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Selisih Tanggal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ListTile(leading: const Icon(Icons.event), title: const Text('Tanggal Awal'),
                subtitle: Text(DateConverter.masehi(_startDate)), onTap: () => _pickDate(true)),
              ListTile(leading: const Icon(Icons.event_available), title: const Text('Tanggal Akhir'),
                subtitle: Text(DateConverter.masehi(_endDate)), onTap: () => _pickDate(false)),
              const Divider(),
              Text(_dateDifference(), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7B1FA2))),
            ]),
          )),
          const SizedBox(height: 14),
          Card(child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Selisih Waktu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ListTile(leading: const Icon(Icons.play_circle_outline), title: const Text('Waktu Mulai'),
                subtitle: Text(_startTime.format(context)), onTap: () => _pickTime(true)),
              ListTile(leading: const Icon(Icons.stop_circle_outlined), title: const Text('Waktu Selesai'),
                subtitle: Text(_endTime.format(context)), onTap: () => _pickTime(false)),
              const Divider(),
              Text(_timeDifference(), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7B1FA2))),
            ]),
          )),
        ],
      ),
    );
  }
}
