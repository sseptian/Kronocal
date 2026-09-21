import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/date_converter.dart';

class DateConversionPage extends StatefulWidget {
  const DateConversionPage({super.key});
  @override State<DateConversionPage> createState() => _DateConversionPageState();
}
class _DateConversionPageState extends State<DateConversionPage> {
  DateTime _selected = DateTime.now();
  final _daysCtrl = TextEditingController(text: '40');
  @override void dispose() { _daysCtrl.dispose(); super.dispose(); }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(context: context, initialDate: _selected,
        firstDate: DateTime(1), lastDate: DateTime(9999), helpText: 'Pilih Tanggal');
    if (picked != null) setState(() => _selected = picked);
  }
  void _shift(int sign) {
    final n = int.tryParse(_daysCtrl.text.trim()) ?? 0;
    if (n != 0) setState(() => _selected = _selected.add(Duration(days: sign * n)));
  }

  @override Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final results = DateConverter.all(_selected);
    final iconMap = {
      'Masehi': Icons.public_rounded, 'Hijriah': Icons.mosque_rounded,
      'Weton Jawa': Icons.temple_hindu_rounded, 'Shio Cina': Icons.pets_rounded,
      'Saka Bali': Icons.auto_awesome_rounded, 'Umur': Icons.cake_rounded,
    };
    return Container(
      color: cs.surface,
      child: ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Card(
          color: const Color(0xFFF3E5F5),
          child: InkWell(
            onTap: _pickDate,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(children: [
                const Icon(Icons.event_rounded, color: Color(0xFF7B1FA2), size: 34),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Tanggal Terpilih', style: TextStyle(color: Color(0xFF7B1FA2))),
                  const SizedBox(height: 2),
                  Text(DateConverter.masehi(_selected), style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A148C))),
                ])),
                const Icon(Icons.edit_calendar_rounded, color: Color(0xFFE91E63)),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: cs.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Matematika Tanggal (Date Math)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text('Geser tanggal maju atau mundur sejumlah hari.', style: TextStyle(color: cs.onSurfaceVariant)),
              const SizedBox(height: 14),
              TextField(controller: _daysCtrl, keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'Jumlah Hari', prefixIcon: Icon(Icons.today_rounded, color: Color(0xFF7B1FA2)))),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: FilledButton.tonalIcon(onPressed: () => _shift(-1), icon: const Icon(Icons.remove_rounded), label: const Text('Kurang'))),
                const SizedBox(width: 12),
                Expanded(child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE91E63), foregroundColor: Colors.white),
                  onPressed: () => _shift(1), icon: const Icon(Icons.add_rounded), label: const Text('Tambah'))),
              ]),
              Center(child: TextButton.icon(onPressed: () => setState(() => _selected = DateTime.now()),
                icon: const Icon(Icons.restart_alt_rounded), label: const Text('Reset ke Hari Ini'))),
            ]),
          ),
        ),
        const SizedBox(height: 8),
        Text('Hasil Penanggalan', style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: const Color(0xFF7B1FA2), fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...results.entries.map((e) => Card(
          margin: const EdgeInsets.only(bottom: 12), color: cs.surfaceContainerHigh,
          child: ListTile(
            leading: CircleAvatar(backgroundColor: const Color(0xFFF3E5F5),
              child: Icon(iconMap[e.key], color: const Color(0xFFE91E63))),
            title: Text(e.key), subtitle: Text(e.value),
          ),
        )),
      ],
      ),
    );
  }
}