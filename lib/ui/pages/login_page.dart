// lib/ui/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/user_repository.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _pwd = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _doLogin() async {
    setState(() { _loading = true; _error = null; });
    try {
      await UserRepository().login(_email.text.trim(), _pwd.text);
      if (!mounted) return;
      context.go('/');
    } catch (e) {
      setState(() { _error = 'Falha no login'; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: const Text('Login'),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'E-mail')),
            const SizedBox(height: 8),
            TextField(controller: _pwd, obscureText: true, decoration: const InputDecoration(labelText: 'Senha')),
            const SizedBox(height: 12),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children:[TextButton(onPressed: ()=>context.go('/register'), child: const Text('Registrar-se'))],
            ),
            const SizedBox(height: 4),
            FilledButton(
              onPressed: _loading ? null : _doLogin,
              child: _loading ? const SizedBox(height:20, width:20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Entrar'),
            ),
          ],
        ),
      ),
    );
  }
}
