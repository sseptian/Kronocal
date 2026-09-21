import 'package:flutter/material.dart';
import '../utils/db_helper.dart';
import '../utils/date_converter.dart';

class MemberListPage extends StatefulWidget {
  const MemberListPage({super.key});

  @override
  State<MemberListPage> createState() => _MemberListPageState();
}

class _MemberListPageState extends State<MemberListPage> {
  List<Map<String, dynamic>> _members = [];

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final db = await DBHelper.db;
    final data = await db.query('members');
    setState(() => _members = data);
  }

  void _addMemberDialog() {
    final nameCtrl = TextEditingController();
    DateTime? birthDate;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          title: const Text('Tambah Anggota Baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Anggota')),
              const SizedBox(height: 12),
              ListTile(
                title: Text(birthDate == null ? 'Pilih Tgl Lahir' : '${birthDate!.day}/${birthDate!.month}/${birthDate!.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setDlgState(() => birthDate = picked);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            FilledButton(
              onPressed: () async {
                if (nameCtrl.text.isNotEmpty && birthDate != null) {
                  final db = await DBHelper.db;
                  await db.insert('members', {
                    'name': nameCtrl.text,
                    'birth_date': birthDate!.toIso8601String(),
                  });
                  if (!mounted) return;
                  Navigator.pop(ctx);
                  _loadMembers();
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
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Anggota')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE91E63),
        onPressed: _addMemberDialog,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
      body: _members.isEmpty
          ? const Center(child: Text('Belum ada anggota terdaftar'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _members.length,
              itemBuilder: (ctx, i) {
                final m = _members[i];
                final bDate = DateTime.parse(m['birth_date']);
                final u = DateConverter.hitungUmurLengkap(bDate);
                final weton = DateConverter.wetonJawa(bDate);
                final hijriah = DateConverter.hijriah(bDate);
                final saka = DateConverter.sakaBali(bDate);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
children: [
  Text(
    m['name'], 
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF7B1FA2)),
  ),
  const SizedBox(height: 4),
  Text('Umur: $u'), // Ganti u['tahun'] dst. menjadi $u langsung
  const Divider(),
  Text('• Weton: $weton', style: const TextStyle(fontSize: 12)),
  Text('• Hijriah: $hijriah', style: const TextStyle(fontSize: 12)),
  Text('• Saka Bali: $saka', style: const TextStyle(fontSize: 12)),
],
                    ),
                  ),
                );
              },
            ),
    );
  }
}