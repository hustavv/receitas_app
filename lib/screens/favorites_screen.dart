import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/recipe.dart';
import 'recipe_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final items = app.favoriteRecipes;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer()),
        title: const Text(''),
        actions: const [Padding(padding: EdgeInsets.only(right: 16), child: Icon(Icons.search))],
      ),
      drawer: const _FavDrawer(),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final r = items[i];
          return Card(
            child: ListTile(
              title: Text(r.titulo),
              trailing: const Icon(Icons.star),
              onTap: () {
                context.read<AppState>().markViewed(r.id);
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => RecipeDetailsScreen(recipe: r)));
              },
            ),
          );
        },
      ),
    );
  }
}

class _FavDrawer extends StatelessWidget {
  const _FavDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            const DrawerHeader(child: Align(alignment: Alignment.centerLeft, child: Icon(Icons.public, size: 48))),
            ListTile(title: const Text('Minha conta'), onTap: (){}),
            ListTile(title: const Text('Receitas favoritas'), onTap: () => Navigator.pop(context)),
            ListTile(title: const Text('Receitas visualizadas'), onTap: () => Navigator.of(context).pushNamed('/viewed')),
          ],
        ),
      ),
    );
  }
}
