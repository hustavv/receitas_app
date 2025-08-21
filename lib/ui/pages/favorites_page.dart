// lib/ui/pages/favorites_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/favorite_repository.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});
  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Map<String,dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    FavoriteRepository().list(page: 0, size: 10).then((v){
      setState((){ _items = v; _loading = false; });
    }).catchError((_){ setState((){ _loading = false; }); });
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
        title: const Text('Favoritos'),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _items.length,
            itemBuilder: (_, i) {
              final fav = _items[i];
              final recipe = fav['recipe'] ?? {};
              return Card(
                child: ListTile(
                  title: Text(recipe['title'] ?? recipe['name'] ?? 'Receita'),
                  trailing: const Icon(Icons.star),
                ),
              );
            },
          ),
    );
  }
}
