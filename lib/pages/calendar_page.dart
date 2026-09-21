import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../utils/db_helper.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});
  @override State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> _events = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadAgendas();
  }

  Future<void> _loadAgendas() async {
    final db = await DBHelper.db;
    final rows = await db.query('agendas', orderBy: 'date ASC, time ASC');
    if (mounted) setState(() => _events = rows);
  }

  List<Map<String, dynamic>> get _dayEvents {
    final d = _selectedDay!;
    return _events.where((e) {
      final dt = DateTime.parse(e['date'] as String);
      return dt.year == d.year && dt.month == d.month && dt.day == d.day;
    }).toList();
  }

  Future<void> _openAgendaForm({Map<String, dynamic>? item}) async {
    final titleCtrl = TextEditingController(text: item?['title']?.toString() ?? '');
    TimeOfDay selectedTime = TimeOfDay.now();
    if (item != null) {
      final raw = item['time']?.toString() ?? '';
      final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(raw);
      if (match != null) {
        selectedTime = TimeOfDay(hour: int.parse(match.group(1)!), minute: int.parse(match.group(2)!));
      }
    }
    Color selectedColor = item?['color'] is int ? Color(item!['color'] as int) : Colors.pink;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: Text(item == null ? 'Tambah Agenda' : 'Edit Agenda'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Judul Agenda')),
              const SizedBox(height: 12),
              ListTile(
                title: Text('Waktu: ${selectedTime.format(ctx)}'),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final t = await showTimePicker(context: ctx, initialTime: selectedTime);
                  if (t != null) setDlgState(() => selectedTime = t);
                },
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [Colors.pink, Colors.purple, Colors.orange, Colors.blue].map((c) =>
                  GestureDetector(
                    onTap: () => setDlgState(() => selectedColor = c),
                    child: CircleAvatar(
                      backgroundColor: c,
                      child: selectedColor.toARGB32() == c.toARGB32() ? const Icon(Icons.check, color: Colors.white) : null,
                    ),
                  )).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            FilledButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty) return;
                final db = await DBHelper.db;
                final data = {
                  'title': titleCtrl.text.trim(),
                  'date': _selectedDay!.toIso8601String(),
                  'time': selectedTime.format(ctx),
                  'color': selectedColor.value,
                };
                if (item == null) {
                  await db.insert('agendas', data);
                } else {
                  await db.update('agendas', data, where: 'id = ?', whereArgs: [item['id']]);
                }
                if (!mounted) return;
                Navigator.pop(ctx);
                await _loadAgendas();
              },
              child: Text(item == null ? 'Simpan' : 'Update'),
            ),
          ],
        ),
      ),
    );
    titleCtrl.dispose();
  }

  Future<void> _confirmDelete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Agenda?'),
        content: const Text('Agenda yang dihapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (ok == true) {
      final db = await DBHelper.db;
      await db.delete('agendas', where: 'id = ?', whereArgs: [id]);
      await _loadAgendas();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dayEvents = _dayEvents;
    return Container(
      color: cs.surface,
      child: Stack(
        children: [
          Column(
      )
          ]
        ),
      );
  }
}
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selected, focused) => setState(() {
              _selectedDay = selected;
              _focusedDay = focused;
            }),
            eventLoader: (day) => _events.where((e) {
              final dt = DateTime.parse(e['date'] as String);
              return dt.year == day.year && dt.month == day.month && dt.day == day.day;
            }).toList(),
          ),
          const Divider(),
          Expanded(
            child: dayEvents.isEmpty
                ? const Center(child: Text('Belum ada agenda pada tanggal ini'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                    itemCount: dayEvents.length,
                    itemBuilder: (ctx, i) {
                      final item = dayEvents[i];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(backgroundColor: Color(item['color'] as int)),
                          title: Text(item['title'].toString()),
                          subtitle: Text('Waktu: ${item['time']}'),
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == 'edit') _openAgendaForm(item: item);
                              if (v == 'delete') _confirmDelete(item['id'] as int);
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(value: 'delete', child: Text('Hapus')),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
