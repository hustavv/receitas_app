// lib/ui/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/favorite_repository.dart';
import '../../data/user_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String,dynamic>> _favorites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final meWrap = await UserRepository().me();
      final me = Map<String, dynamic>.from(meWrap['data'] ?? meWrap);
      final userId = (me['id'] ?? '').toString();
      final v = await FavoriteRepository().list(userId: userId, page: 0, size: 50);
      if (!mounted) return;
      setState(() { _favorites = v; _loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _loading = false; });
    }
  }

  Future<void> _confirmRemove(String favoriteId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover dos favoritos?'),
        content: const Text('Deseja remover esta receita dos seus favoritos?'),
        actions: [
          TextButton(onPressed: ()=>Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: ()=>Navigator.pop(ctx, true), child: const Text('Remover')),
        ],
      ),
    );
    if (ok == true) {
      await FavoriteRepository().remove(favoriteId);
      await _fetch();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removido dos favoritos.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: ()=>context.go('/search')),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(child: Text('Minha conta')),
            ListTile(leading: const Icon(Icons.logout), title: const Text('Sair'), onTap: ()=>context.go('/login')),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()=>context.go('/recipe/new'),
        child: const Icon(Icons.add),
        tooltip: 'Nova receita',
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : (_favorites.isEmpty
            ? const Center(child: Text('Você ainda não tem favoritos.'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _favorites.length,
                separatorBuilder: (_, __)=> const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final fav = _favorites[i];
                  final recipe = Map<String,dynamic>.from(fav['recipe'] ?? {});
                  final id = (recipe['id'] ?? '').toString();
                  return ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    title: Text((recipe['title'] ?? recipe['name'] ?? 'Receita')),
                    subtitle: Text((recipe['category']?['name'] ?? '') ),
                    onTap: ()=>context.go('/recipe/$id'),
                    trailing: IconButton(
                      icon: const Icon(Icons.star),
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: ()=>_confirmRemove((fav['id'] ?? '').toString()),
                      tooltip: 'Remover dos favoritos',
                    ),
                  );
                },
              )
          ),
    );
  }
}
