import 'package:flutter/material.dart';
import '../utils/db_helper.dart';

class GroupDataPage extends StatefulWidget {
  const GroupDataPage({super.key});
  @override State<GroupDataPage> createState() => _GroupDataPageState();
}

class _GroupDataPageState extends State<GroupDataPage> {
  List<Map<String, dynamic>> _people = [];
  final _nameCtrl = TextEditingController();
  final _nimCtrl = TextEditingController();

  @override void initState() { super.initState(); _loadPeople(); }
  @override void dispose() { _nameCtrl.dispose(); _nimCtrl.dispose(); super.dispose(); }

  Future<void> _loadPeople() async {
    final db = await DBHelper.db;
    final rows = await db.query('group_members', orderBy: 'id DESC');
    if (mounted) setState(() => _people = rows);
  }

  Future<void> _savePerson() async {
    final name = _nameCtrl.text.trim();
    final nim = _nimCtrl.text.trim();
    if (name.isEmpty || nim.isEmpty) return;
    final db = await DBHelper.db;
    await db.insert('group_members', {'name': name, 'nim': nim});
    _nameCtrl.clear();
    _nimCtrl.clear();
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
    _nimCtrl.clear();
    await showModalBottomSheet(
      context: context, isScrollControlled: true, showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Tambah Anggota', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF7B1FA2))),
          const SizedBox(height: 16),
          TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nama', prefixIcon: Icon(Icons.person_rounded))),
          const SizedBox(height: 12),
          TextField(controller: _nimCtrl, keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'NIM', prefixIcon: Icon(Icons.badge_rounded))),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: FilledButton.icon(
            onPressed: _savePerson, icon: const Icon(Icons.save_rounded), label: const Text('Simpan'))),
        ]),
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
                final name = (p['name'] ?? '').toString();
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(name.isEmpty ? '?' : name.substring(0, 1).toUpperCase())),
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('NIM: \${(p['nim'] ?? '').toString()}'),
                    trailing: IconButton(
                      onPressed: () => _removePerson(p['id'] as int),
                      icon: Icon(Icons.delete_outline_rounded, color: cs.error),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
