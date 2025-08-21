// lib/ui/pages/register_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/user_repository.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _pwd = TextEditingController();
  final _pwd2 = TextEditingController();
  bool _saving = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(()=>_saving = true);
    try {
      await UserRepository().register(
        firstName: _first.text.trim(),
        lastName: _last.text.trim(),
        email: _email.text.trim(),
        password: _pwd.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cadastro criado! Faça login.')));
      context.go('/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao cadastrar: $e')));
    } finally {
      if (mounted) setState(()=>_saving = false);
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
              context.go('/login');
            }
          },
        ),
        title: const Text('Registrar-se'),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _first,
                decoration: const InputDecoration(labelText: 'Nome *'),
                validator: (v)=> (v==null || v.trim().isEmpty) ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _last,
                decoration: const InputDecoration(labelText: 'Sobrenome *'),
                validator: (v)=> (v==null || v.trim().isEmpty) ? 'Informe o sobrenome' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'E-mail *'),
                keyboardType: TextInputType.emailAddress,
                validator: (v)=> (v==null || !v.contains('@')) ? 'E-mail inválido' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _pwd,
                decoration: const InputDecoration(labelText: 'Senha *'),
                obscureText: true,
                validator: (v)=> (v==null || v.length<6) ? 'Mínimo 6 caracteres' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _pwd2,
                decoration: const InputDecoration(labelText: 'Confirmar senha *'),
                obscureText: true,
                validator: (v)=> (v != _pwd.text) ? 'As senhas não coincidem' : null,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _saving ? null : _submit,
                icon: _saving ? const SizedBox(height:18, width:18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.person_add),
                label: const Text('Criar conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
