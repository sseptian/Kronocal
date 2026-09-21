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
    if (mounted) {
      setState(() => _events = rows);
    }
  }

  List<Map<String, dynamic>> get _dayEvents {
    final d = _selectedDay ?? DateTime.now();
    return _events.where((e) {
      final dt = DateTime.parse(e['date'] as String);
      return dt.year == d.year && dt.month == d.month && dt.day == d.day;
    }).toList();
  }

  Future<void> _openAgendaForm({Map<String, dynamic>? item}) async {
    final titleCtrl = TextEditingController(
      text: item?['title']?.toString() ?? '',
    );

    TimeOfDay selectedTime = TimeOfDay.now();

    if (item != null) {
      final raw = item['time']?.toString() ?? '';
      final match = RegExp(r'^(\\d{1,2}):(\\d{2})').firstMatch(raw);
      if (match != null) {
        selectedTime = TimeOfDay(
          hour: int.parse(match.group(1)!),
          minute: int.parse(match.group(2)!),
        );
      }
    }

    final cs = Theme.of(context).colorScheme;
    Color selectedColor = item?['color'] is int
        ? Color(item!['color'] as int)
        : cs.primary;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: Text(item == null ? 'Tambah Agenda' : 'Edit Agenda'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Judul Agenda',
                    prefixIcon: Icon(Icons.event_note_rounded),
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Waktu: ${selectedTime.format(ctx)}'),
                  trailing: const Icon(Icons.access_time_rounded),
                  onTap: () async {
                    final t = await showTimePicker(
                      context: ctx,
                      initialTime: selectedTime,
                    );
                    if (t != null) {
                      setDlgState(() => selectedTime = t);
                    }
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    cs.primary,
                    cs.secondary,
                    Colors.orange,
                    Colors.blue,
                  ].map((c) {
                    return GestureDetector(
                      onTap: () => setDlgState(() => selectedColor = c),
                      child: CircleAvatar(
                        backgroundColor: c,
                        child: selectedColor.toARGB32() == c.toARGB32()
                            ? Icon(Icons.check, color: cs.onPrimary)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Judul agenda wajib diisi.'),
                    ),
                  );
                  return;
                }

                try {
                  final db = await DBHelper.db;
                  final data = {
                    'title': titleCtrl.text.trim(),
                    'date': (_selectedDay ?? DateTime.now()).toIso8601String(),
                    'time': selectedTime.format(ctx),
                    'color': selectedColor.toARGB32(),
                  };

                  if (item == null) {
                    await db.insert('agendas', data);
                  } else {
                    await db.update(
                      'agendas',
                      data,
                      where: 'id = ?',
                      whereArgs: [item['id']],
                    );
                  }

                  if (!mounted) return;
                  Navigator.pop(ctx);
                  await _loadAgendas();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        item == null
                            ? 'Agenda berhasil ditambahkan.'
                            : 'Agenda berhasil diperbarui.',
                      ),
                    ),
                  );
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal menyimpan agenda: $e')),
                    );
                  }
                }
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
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (ok == true) {
      final db = await DBHelper.db;
      await db.delete(
        'agendas',
        where: 'id = ?',
        whereArgs: [id],
      );
      await _loadAgendas();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dayEvents = _dayEvents;

    return Container(
      color: cs.surface,
      child: Stack(
        children: [
          Column(
            children: [
              Material(
                color: cs.surface,
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) =>
                      isSameDay(_selectedDay, day),
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selectedDay = selected;
                      _focusedDay = focused;
                    });
                  },
                  eventLoader: (day) {
                    return _events.where((e) {
                      final dt = DateTime.parse(e['date'] as String);
                      return dt.year == day.year &&
                          dt.month == day.month &&
                          dt.day == day.day;
                    }).toList();
                  },
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    defaultTextStyle: TextStyle(color: cs.onSurface),
                    weekendTextStyle: TextStyle(color: cs.secondary),
                    todayDecoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: TextStyle(
                      color: cs.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: TextStyle(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    markerDecoration: BoxDecoration(
                      color: cs.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                    titleTextStyle: TextStyle(
                      color: cs.onSurface,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: cs.onSurface,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: cs.onSurface,
                    ),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: cs.onSurfaceVariant),
                    weekendStyle: TextStyle(color: cs.secondary),
                  ),
                ),
              ),
              Divider(height: 1, color: cs.outlineVariant),
              Expanded(
                child: dayEvents.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada agenda pada tanggal ini',
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          12,
                          16,
                          96,
                        ),
                        itemCount: dayEvents.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (ctx, i) {
                          final item = dayEvents[i];
                          final itemColor = Color(item['color'] as int);

                          return Card(
                            margin: EdgeInsets.zero,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 5,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: itemColor,
                                child: Icon(
                                  Icons.event_rounded,
                                  color: cs.onPrimary,
                                ),
                              ),
                              title: Text(
                                item['title'].toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Waktu: ${item['time']}',
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _openAgendaForm(item: item);
                                  } else if (value == 'delete') {
                                    _confirmDelete(item['id'] as int);
                                  }
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit'),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Hapus'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: _openAgendaForm,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
