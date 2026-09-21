import 'package:flutter/material.dart';
import '../utils/session_manager.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const LoginPage({super.key, required this.onLoginSuccess});
  @override State<LoginPage> createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _errorMessage;

  @override void dispose() { _userCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _errorMessage = null; });
    final berhasil = await SessionManager.login(_userCtrl.text, _passCtrl.text);
    if (!mounted) return;
    if (berhasil) {
      widget.onLoginSuccess();
    } else {
      setState(() {
        _loading = false;
        _errorMessage = 'Username atau password salah.';
      });
    }
  }

  @override Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  height: 96, width: 96, alignment: Alignment.center,
                  decoration: const BoxDecoration(color: Color(0xFFF3E5F5), shape: BoxShape.circle),
                  child: const Icon(Icons.calculate_rounded, size: 48, color: Color(0xFF7B1FA2)),
                ),
                const SizedBox(height: 20),
                const Text('KronoCalc', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF7B1FA2))),
                const SizedBox(height: 6),
                Text('Kalkulator & Sinkronisasi Penanggalan', style: TextStyle(color: cs.onSurfaceVariant)),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _userCtrl,
                  decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.person_rounded)),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Username tidak boleh kosong';
                    if (v.trim().length < 3) return 'Username minimal 3 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  onFieldSubmitted: (_) => _handleLogin(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password tidak boleh kosong';
                    if (v.length < 5) return 'Password minimal 5 karakter';
                    return null;
                  },
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 14),
                  Text(_errorMessage!, style: const TextStyle(color: Color(0xFFD32F2F))),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: _loading ? null : _handleLogin,
                    icon: _loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.login_rounded),
                    label: Text(_loading ? 'Memproses...' : 'Masuk'),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Akun Demo: admin / 12345', style: TextStyle(color: cs.onSurfaceVariant)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}