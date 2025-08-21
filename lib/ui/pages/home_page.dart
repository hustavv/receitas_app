// lib/ui/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/recipe_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String,dynamic>> _recipes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final v = await RecipeRepository().list(page: 0, size: 10);
      setState((){ _recipes = v; _loading = false; });
    } catch (_) {
      setState((){ _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas receitas'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: ()=>context.go('/search')),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('Minha conta')),
            ListTile(leading: const Icon(Icons.star), title: const Text('Favoritos'), onTap: ()=>context.go('/favorites')),
            ListTile(leading: const Icon(Icons.logout), title: const Text('Sair'), onTap: ()=>context.go('/login')),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: ()=>context.go('/recipe/new'), child: const Icon(Icons.add)),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _recipes.length,
            separatorBuilder: (_, __)=> const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final r = _recipes[i];
              final id = (r['id'] ?? '').toString();
              return ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                title: Text((r['title'] ?? r['name'] ?? 'Receita')),
                subtitle: Text((r['category']?['name'] ?? r['category']?['title'] ?? '')),
                onTap: ()=>context.go('/recipe/$id'),
              );
            },
          ),
    );
  }
}
