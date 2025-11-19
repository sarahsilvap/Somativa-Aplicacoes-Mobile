// lib/ui/widgets/auth/login_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Tela de Login
/// Ajuste a variável `djangoLoginUrl` para apontar ao seu backend Django (ex.: http://10.0.2.2:8000/api/login/)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  // TODO: configure sua URL de login Django aqui (ou deixe vazio para usar mock)
  final String djangoLoginUrl = ''; // ex: 'http://10.0.2.2:8000/api/auth/login/'

  Future<bool> _attemptLogin(String username, String password) async {
    if (djangoLoginUrl.isEmpty) {
      // Mock local para permitir testes sem backend
      await Future.delayed(const Duration(milliseconds: 400));
      return username == 'test' && password == '1234';
    }
    try {
      final resp = await http.post(
        Uri.parse(djangoLoginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        // Se o backend retornar token/data, você pode salvar aqui
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Login error: $e');
      throw Exception('Erro ao conectar com o servidor.');
    }
  }

  void _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final ok = await _attemptLogin(_usernameCtrl.text.trim(), _passwordCtrl.text);
      if (ok) {
        // Navegar para a home (ajuste a rota se o seu projeto usar outra)
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        setState(() {
          _error = 'Usuário ou senha inválidos.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erro: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18.0),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _usernameCtrl,
                      decoration: const InputDecoration(labelText: 'Usuário'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o usuário' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordCtrl,
                      decoration: const InputDecoration(labelText: 'Senha'),
                      obscureText: true,
                      validator: (v) => (v == null || v.isEmpty) ? 'Informe a senha' : null,
                    ),
                    const SizedBox(height: 16),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _onSubmit,
                        child: _loading
                            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Entrar'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Não tem conta?'),
                        TextButton(
                          onPressed: () => Navigator.of(context).pushNamed('/register'),
                          child: const Text('Cadastrar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Dica: para testes sem backend use usuário "test" e senha "1234".',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
