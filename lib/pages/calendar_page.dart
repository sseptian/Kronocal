import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../utils/db_helper.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadAgendas();
  }

  Future<void> _loadAgendas() async {
    final db = await DBHelper.db;
    final List<Map<String, dynamic>> res = await db.query('agendas');
    Map<DateTime, List<Map<String, dynamic>>> newEvents = {};

    for (var item in res) {
      DateTime dt = DateTime.parse(item['date']);
      DateTime key = DateTime(dt.year, dt.month, dt.day);
      if (newEvents[key] == null) newEvents[key] = [];
      newEvents[key]!.add(item);
    }

    setState(() {
      _events = newEvents;
    });
  }

  void _addAgendaDialog() {
    final titleCtrl = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();
    Color selectedColor = Colors.pink;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder( // Ganti StatefulWidget menjadi StatefulBuilder
  builder: (context, setDlgState) => AlertDialog(
    title: const Text('Tambah Agenda / Tanggal Penting'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: titleCtrl, 
          decoration: const InputDecoration(labelText: 'Judul Agenda'),
        ),
        const SizedBox(height: 12),
        ListTile(
          title: Text('Waktu: ${selectedTime.format(context)}'),
          trailing: const Icon(Icons.access_time),
          onTap: () async {
            final t = await showTimePicker(context: context, initialTime: selectedTime);
            if (t != null) setDlgState(() => selectedTime = t);
          },
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [Colors.pink, Colors.purple, Colors.orange, Colors.blue].map((c) {
            return GestureDetector(
              onTap: () => setDlgState(() => selectedColor = c),
              child: CircleAvatar(
                backgroundColor: c,
                child: selectedColor == c ? const Icon(Icons.check, color: Colors.white) : null,
              ),
            );
          }).toList(),
        )
      ],
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
      FilledButton(
        onPressed: () async {
          if (titleCtrl.text.isNotEmpty && _selectedDay != null) {
            final db = await DBHelper.db;
            await db.insert('agendas', {
              'title': titleCtrl.text,
              'date': _selectedDay!.toIso8601String(),
              'time': selectedTime.format(context),
              'color': selectedColor.toARGB32(), // Ganti selectedColor.value dengan toARGB32()
            });
            if (!mounted) return;
            Navigator.pop(ctx);
            _loadAgendas();
          }
        },
        child: const Text('Simpan'),
      )
    ],
  ),
),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime selectedKey = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    List<Map<String, dynamic>> dayEvents = _events[selectedKey] ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Kalender Agenda & Catatan')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE91E63),
        onPressed: _addAgendaDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (sDay, fDay) {
              setState(() {
                _selectedDay = sDay;
                _focusedDay = fDay;
              });
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                DateTime k = DateTime(date.year, date.month, date.day);
                if (_events[k] != null && _events[k]!.isNotEmpty) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _events[k]!.map((e) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Color(e['color'])),
                      );
                    }).toList(),
                  );
                }
                return null;
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: dayEvents.length,
              itemBuilder: (ctx, i) {
                final item = dayEvents[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: Color(item['color'])),
                    title: Text(item['title']),
                    subtitle: Text('Waktu: ${item['time']}'),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}