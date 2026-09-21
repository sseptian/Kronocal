import 'package:flutter/material.dart';
import '../models/person_entry.dart';
import '../utils/date_converter.dart';

class GroupDataPage extends StatefulWidget {
  final List<PersonEntry> people;
  final void Function(PersonEntry) onAdd;
  final void Function(int) onRemove;

  const GroupDataPage({
    super.key,
    required this.people,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<GroupDataPage> createState() => _GroupDataPageState();
}

class _GroupDataPageState extends State<GroupDataPage> {
  final TextEditingController _nameCtrl = TextEditingController();
  DateTime? _birth;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickBirth(StateSetter refresh) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime(2000),
      firstDate: DateTime(1),
      lastDate: DateTime.now(),
      helpText: 'Pilih Tanggal Lahir',
    );
    if (picked != null) refresh(() => _birth = picked);
  }

  void _openForm() {
    _nameCtrl.clear();
    _birth = null;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, refresh) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 8,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tambah Anggota',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7B1FA2))),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nama',
                      prefixIcon: Icon(Icons.person_rounded, color: Color(0xFF7B1FA2)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _pickBirth(refresh),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Lahir',
                        prefixIcon: Icon(Icons.cake_rounded, color: Color(0xFFE91E63)),
                      ),
                      child: Text(
                        _birth == null
                            ? 'Ketuk untuk memilih'
                            : DateConverter.masehi(_birth!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE91E63),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        final name = _nameCtrl.text.trim();
                        if (name.isEmpty || _birth == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Isi nama & tanggal lahir dulu.')),
                          );
                          return;
                        }
                        widget.onAdd(
                            PersonEntry(name: name, birthDate: _birth!));
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final people = widget.people;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
        onPressed: _openForm,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Tambah'),
      ),
      body: people.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.groups_2_outlined,
                    size: 72,
                    color: const Color(0xFFE91E63).withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Text('Belum ada anggota',
                      style: TextStyle(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text(
                    'Tekan tombol Tambah untuk memulai',
                    style: TextStyle(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              itemCount: people.length,
              itemBuilder: (context, i) {
                final p = people[i];
                final conv = DateConverter.all(p.birthDate);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Card(
                    color: cs.surfaceContainerHigh,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFF7B1FA2),
                                foregroundColor: Colors.white,
                                child: Text(
                                  p.name.isNotEmpty
                                      ? p.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  p.name,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              IconButton(
                                onPressed: () => widget.onRemove(i),
                                icon: Icon(Icons.delete_outline_rounded,
                                    color: cs.error),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          ...conv.entries.map(
                            (e) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 96,
                                    child: Text(
                                      e.key,
                                      style: TextStyle(
                                          color: cs.onSurfaceVariant,
                                          fontSize: 13),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      e.value,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}