import 'package:flutter/material.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';
  String _expression = '';
  double? _accumulator;
  String? pendingOp;
  bool startNew = true;

  String _fmt(double v) {
    if (v.isInfinite || v.isNaN) return 'Error';
    if (v == v.roundToDouble() && v.abs() < 1e15) {
      return v.toInt().toString();
    }
    return v
        .toStringAsFixed(8)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  void _inputDigit(String d) {
    setState(() {
      if (startNew) {
        _display = (d == '.') ? '0.' : d;
        startNew = false;
      } else {
        if (d == '.' && _display.contains('.')) return;
        if (_display == '0' && d != '.') {
          _display = d;
        } else {
          _display += d;
        }
      }
    });
  }

  void _clearAll() {
    setState(() {
      _display = '0';
      _expression = '';
      _accumulator = null;
      pendingOp = null;
      startNew = true;
    });
  }

  void _backspace() {
    setState(() {
      if (startNew) return;
      if (_display.length <= 1 ||
          (_display.length == 2 && _display.startsWith('-'))) {
        _display = '0';
        startNew = true;
      } else {
        _display = _display.substring(0, _display.length - 1);
      }
    });
  }

  void _toggleSign() {
    setState(() {
      if (_display == '0' || _display == 'Error') return;
      _display = _display.startsWith('-')
          ? _display.substring(1)
          : '-$_display';
    });
  }

  double _compute(double a, double b, String op) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case 'x':
        return a * b;
      case '/':
        return b == 0 ? double.nan : a / b;
      default:
        return b;
    }
  }

  void _setOperator(String op) {
    setState(() {
      final current = double.tryParse(_display) ?? 0;
      if (_accumulator == null) {
        _accumulator = current;
      } else if (!startNew) {
        _accumulator = _compute(_accumulator!, current, pendingOp ?? '+');
      }
      pendingOp = op;
      startNew = true;
      _display = _fmt(_accumulator!);
      _expression = '${_fmt(_accumulator!)} $op';
    });
  }

  void _equals() {
    setState(() {
      if (pendingOp == null || _accumulator == null) return;
      final current = double.tryParse(_display) ?? 0;
      final result = _compute(_accumulator!, current, pendingOp!);
      _expression = '${_fmt(_accumulator!)} $pendingOp ${_fmt(current)} =';
      _display = _fmt(result);
      _accumulator = null;
      pendingOp = null;
      startNew = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget btn(String label,
        {Color? bg, Color? fg, VoidCallback? onTap, IconData? icon}) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: AspectRatio(
            aspectRatio: 1,
            child: Material(
              color: bg ?? cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(22),
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: onTap,
                child: Center(
                  child: icon != null
                      ? Icon(icon, color: fg ?? const Color(0xFF7B1FA2), size: 26)
                      : Text(
                          label,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: fg ?? cs.onSurface,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            alignment: Alignment.bottomRight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _expression,
                  style: TextStyle(fontSize: 22, color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _display,
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
          child: Column(
            children: [
              Row(
                children: [
                  btn('AC',
                      bg: const Color(0xFFFFEBEE),
                      fg: const Color(0xFFD32F2F),
                      onTap: _clearAll),
                  btn('+/-',
                      bg: cs.surfaceContainerHigh,
                      fg: const Color(0xFF7B1FA2),
                      onTap: _toggleSign),
                  btn('',
                      icon: Icons.backspace_outlined,
                      bg: cs.surfaceContainerHigh,
                      fg: const Color(0xFFE91E63),
                      onTap: _backspace),
                  btn('/',
                      bg: const Color(0xFFF3E5F5),
                      fg: const Color(0xFF7B1FA2),
                      onTap: () => _setOperator('/')),
                ],
              ),
              Row(
                children: [
                  btn('7', onTap: () => _inputDigit('7')),
                  btn('8', onTap: () => _inputDigit('8')),
                  btn('9', onTap: () => _inputDigit('9')),
                  btn('x',
                      bg: const Color(0xFFF3E5F5),
                      fg: const Color(0xFF7B1FA2),
                      onTap: () => _setOperator('x')),
                ],
              ),
              Row(
                children: [
                  btn('4', onTap: () => _inputDigit('4')),
                  btn('5', onTap: () => _inputDigit('5')),
                  btn('6', onTap: () => _inputDigit('6')),
                  btn('-',
                      bg: const Color(0xFFF3E5F5),
                      fg: const Color(0xFF7B1FA2),
                      onTap: () => _setOperator('-')),
                ],
              ),
              Row(
                children: [
                  btn('1', onTap: () => _inputDigit('1')),
                  btn('2', onTap: () => _inputDigit('2')),
                  btn('3', onTap: () => _inputDigit('3')),
                  btn('+',
                      bg: const Color(0xFFF3E5F5),
                      fg: const Color(0xFF7B1FA2),
                      onTap: () => _setOperator('+')),
                ],
              ),
              Row(
                children: [
                  btn('0', onTap: () => _inputDigit('0')),
                  btn('.', onTap: () => _inputDigit('.')),
                  btn('%',
                      bg: cs.surfaceContainerHigh,
                      fg: const Color(0xFF7B1FA2),
                      onTap: () {
                        setState(() {
                          final v = (double.tryParse(_display) ?? 0) / 100;
                          _display = _fmt(v);
                        });
                      }),
                  btn('=',
                      bg: const Color(0xFFE91E63),
                      fg: Colors.white,
                      onTap: _equals),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}