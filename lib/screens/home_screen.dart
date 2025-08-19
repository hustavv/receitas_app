import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/recipe.dart';
import 'recipe_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    if (!app.ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(''),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.of(context).pushNamed('/search'),
          )
        ],
      ),
      drawer: const _MainDrawer(),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Futuro: Criar receita')),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Minhas receitas', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: app.myRecipes.length,
                itemBuilder: (context, i) {
                  final r = app.myRecipes[i];
                  return _RecipeCard(r: r);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final Recipe r;
  const _RecipeCard({required this.r});

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    final fav = app.favoriteIds.contains(r.id);
    return Card(
      child: ListTile(
        title: Text(r.titulo),
        subtitle: Text('Pronto em ${r.minutosPreparo} min'),
        trailing: IconButton(
          icon: Icon(fav ? Icons.star : Icons.star_border),
          onPressed: () => app.toggleFavorite(r.id),
        ),
        onTap: () {
          app.markViewed(r.id);
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => RecipeDetailsScreen(recipe: r),
          ));
        },
      ),
    );
  }
}

class _MainDrawer extends StatelessWidget {
  const _MainDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(Icons.public, size: 48),
              ),
            ),
            ListTile(
              title: const Text('Minha conta'),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Receitas favoritas'),
              onTap: () => Navigator.of(context).pushNamed('/favorites'),
            ),
            ListTile(
              title: const Text('Receitas visualizadas'),
              onTap: () => Navigator.of(context).pushNamed('/viewed'),
            ),
          ],
        ),
      ),
    );
  }
}
