// lib/main.dart
import 'package:flutter/material.dart';
import 'router.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Receitas',
      routerConfig: router,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF7C4DFF)),
    );
  }
}
