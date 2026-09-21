import 'dart:async';
import 'package:flutter/material.dart';

class StopwatchPage extends StatefulWidget {
  const StopwatchPage({super.key});
  @override State<StopwatchPage> createState() => _StopwatchPageState();
}
class _StopwatchPageState extends State<StopwatchPage> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;
  final List<Duration> _laps = [];

  @override void dispose() { _ticker?.cancel(); super.dispose(); }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final c = (d.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
    return m + ':' + s + '.' + c;
  }
  void _startStop() {
    if (_stopwatch.isRunning) { _stopwatch.stop(); _ticker?.cancel(); }
    else {
      _stopwatch.start();
      _ticker = Timer.periodic(const Duration(milliseconds: 30), (_) => setState(() {}));
    }
    setState(() {});
  }
  void _reset() {
    _stopwatch.stop(); _stopwatch.reset(); _ticker?.cancel();
    setState(() => _laps.clear());
  }
  void _lap() {
    if (_stopwatch.isRunning) setState(() => _laps.insert(0, _stopwatch.elapsed));
  }

  @override Widget build(BuildContext context) {
    final running = _stopwatch.isRunning;
    final hasTime = _stopwatch.elapsedMilliseconds > 0;
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Container(
          width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 36),
          decoration: BoxDecoration(color: const Color(0xFFF3E5F5), borderRadius: BorderRadius.circular(24)),
          child: Column(children: [
            Text(running ? 'Sedang Berjalan' : (hasTime ? 'Dijeda' : 'Siap Dimulai')),
            const SizedBox(height: 10),
            FittedBox(child: Text(_format(_stopwatch.elapsed), style: const TextStyle(fontSize: 58, fontWeight: FontWeight.bold, color: Color(0xFF4A148C)))),
          ]),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(children: [
          Expanded(child: FilledButton.tonalIcon(onPressed: hasTime ? _reset : null, icon: const Icon(Icons.restart_alt_rounded), label: const Text('Reset'))),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: FilledButton.icon(onPressed: _startStop, icon: Icon(running ? Icons.pause_rounded : Icons.play_arrow_rounded), label: Text(running ? 'Jeda' : 'Mulai'))),
          const SizedBox(width: 12),
          Expanded(child: FilledButton.tonalIcon(onPressed: running ? _lap : null, icon: const Icon(Icons.flag_rounded), label: const Text('Lap'))),
        ]),
      ),
      const SizedBox(height: 16),
      Expanded(child: _laps.isEmpty
        ? const Center(child: Text('Belum ada catatan lap'))
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _laps.length,
            itemBuilder: (_, i) {
              final nomor = _laps.length - i;
              final selisih = i == _laps.length - 1 ? _laps[i] : _laps[i] - _laps[i + 1];
              return Card(child: ListTile(leading: CircleAvatar(child: Text(nomor.toString())), title: Text(_format(_laps[i])), subtitle: Text('Putaran: +' + _format(selisih))));
            },
          )),
    ]);
  }
}