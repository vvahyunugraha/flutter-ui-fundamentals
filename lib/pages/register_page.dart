
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  final _confirmC = TextEditingController();

  String _selectedRole = 'seeker';

  bool _loading = false;

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _passC.dispose();
    _confirmC.dispose();
    super.dispose();
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final response = await AuthService.instance.register(
        name: _nameC.text.trim(),
        email: _emailC.text.trim(),
        password: _passC.text,
        role: _selectedRole,
      );

      if (!mounted) return;

      if (response.session == null) {
        _showMessage(
          'Registrasi berhasil. Silakan login dengan akun Anda.',
        );

        Navigator.of(context).pop();
      } else {
        _showMessage('Registrasi berhasil.');
        // AuthGate otomatis menampilkan DashboardPage
        // ketika session tersedia.
      }
    } on AuthException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      _showMessage(
        'Terjadi kesalahan. Periksa koneksi internet Anda.',
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Course Explorer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Input Nama
              TextFormField(
                controller: _nameC,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Nama wajib diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // Input Email
              TextFormField(
                controller: _emailC,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Email wajib diisi';
                  }

                  if (!v.contains('@')) {
                    return 'Format email tidak valid';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),

              // Input Password
              TextFormField(
                controller: _passC,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Password wajib diisi';
                  }

                  if (v.length < 6) {
                    return 'Minimal 6 karakter';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),

              // Konfirmasi Password
              TextFormField(
                controller: _confirmC,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Konfirmasi Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Konfirmasi password wajib diisi';
                  }

                  if (v != _passC.text) {
                    return 'Password tidak sama';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),

              // Pilihan Role
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Pilih Role',
                  prefixIcon: Icon(Icons.people),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'seeker',
                    child: Text('Seeker'),
                  ),
                  DropdownMenuItem(
                    value: 'owner',
                    child: Text('Owner'),
                  ),
                ],
                onChanged: _loading
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            _selectedRole = value;
                          });
                        }
                      },
              ),

              const SizedBox(height: 24),

              // Tombol Register
              FilledButton(
                onPressed: _loading ? null : _register,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
