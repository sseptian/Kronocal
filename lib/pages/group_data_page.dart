import 'package:flutter/material.dart';
import '../utils/db_helper.dart';
import '../utils/date_converter.dart';

class GroupDataPage extends StatefulWidget {
  const GroupDataPage({super.key});
  @override State<GroupDataPage> createState() => _GroupDataPageState();
}
class _GroupDataPageState extends State<GroupDataPage> {
  List<Map<String, dynamic>> _people = [];
  final _nameCtrl = TextEditingController();
  DateTime? _birth;

  @override void initState() { super.initState(); _loadPeople(); }
  @override void dispose() { _nameCtrl.dispose(); super.dispose(); }

  Future<void> _loadPeople() async {
    final db = await DBHelper.db;
    final rows = await db.query('group_members', orderBy: 'id DESC');
    if (mounted) setState(() => _people = rows);
  }

  Future<void> _addPerson() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || _birth == null) return;
    final db = await DBHelper.db;
    await db.insert('group_members', {'name': name, 'birth_date': _birth!.toIso8601String()});
    _nameCtrl.clear();
    _birth = null;
    if (mounted) Navigator.pop(context);
    await _loadPeople();
  }

  Future<void> _removePerson(int id) async {
    final db = await DBHelper.db;
    await db.delete('group_members', where: 'id = ?', whereArgs: [id]);
    await _loadPeople();
  }

  Future<void> _openForm() async {
    _nameCtrl.clear();
    _birth = null;
    await showModalBottomSheet(
      context: context, isScrollControlled: true, showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, refresh) => Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Tambah Anggota', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF7B1FA2))),
            const SizedBox(height: 16),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nama', prefixIcon: Icon(Icons.person_rounded))),
            const SizedBox(height: 12),
            ListTile(
              title: Text(_birth == null ? 'Pilih tanggal lahir' : DateConverter.masehi(_birth!)),
              leading: const Icon(Icons.cake_rounded),
              onTap: () async {
                final picked = await showDatePicker(context: ctx, initialDate: _birth ?? DateTime(2000), firstDate: DateTime(1), lastDate: DateTime.now());
                if (picked != null) refresh(() => _birth = picked);
              },
            ),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _addPerson, icon: const Icon(Icons.save_rounded), label: const Text('Simpan'))),
          ]),
        ),
      ),
    );
  }

  @override Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm, backgroundColor: const Color(0xFFE91E63), foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1_rounded), label: const Text('Tambah')),
      body: _people.isEmpty
          ? const Center(child: Text('Belum ada anggota kelompok'))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              itemCount: _people.length,
              itemBuilder: (context, i) {
                final p = _people[i];
                final birth = DateTime.parse(p['birth_date'] as String);
                final conv = DateConverter.all(birth);
                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
                    Row(children: [
                      CircleAvatar(child: Text((p['name'] as String).substring(0, 1).toUpperCase())),
                      const SizedBox(width: 12),
                      Expanded(child: Text(p['name'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                      IconButton(onPressed: () => _removePerson(p['id'] as int), icon: Icon(Icons.delete_outline_rounded, color: cs.error)),
                    ]),
                    const Divider(),
                    ...conv.entries.map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(children: [
                        SizedBox(width: 96, child: Text(e.key, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13))),
                        Expanded(child: Text(e.value, style: const TextStyle(fontWeight: FontWeight.w600))),
                      ]),
                    )),
                  ])),
                );
              },
            ),
    );
  }
}