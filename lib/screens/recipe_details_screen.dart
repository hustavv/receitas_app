import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/api_client.dart';

class RecipeDetailsScreen extends StatelessWidget {
  final Recipe recipe;
  const RecipeDetailsScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final api = ApiClient(mockMode: true);
    return Scaffold(
      appBar: AppBar(title: Text(recipe.titulo)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${recipe.porcoes} porções • ${recipe.minutosPreparo} min',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Text('Ingredientes', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            FutureBuilder<List<String>>(
              future: api.getRecipeIngredients(recipe.id),
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final ings = snap.data ?? [];
                if (ings.isEmpty) return const Text('—');
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: ings.map((e) => Text('• $e')).toList(),
                );
              },
            ),
            const SizedBox(height: 16),
            Text('Instruções', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Expanded(child: SingleChildScrollView(child: Text(recipe.instrucoes))),
          ],
        ),
      ),
    );
  }
}
