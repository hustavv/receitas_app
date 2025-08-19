import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'recipe_details_screen.dart';

class ViewedScreen extends StatelessWidget {
  const ViewedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final items = app.viewedRecipes;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        title: const Text('Visualizadas'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final r = items[i];
          return Card(
            child: ListTile(
              title: Text(r.titulo),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RecipeDetailsScreen(recipe: r))),
            ),
          );
        },
      ),
    );
  }
}
