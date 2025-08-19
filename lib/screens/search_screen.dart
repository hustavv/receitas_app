import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/recipe.dart';
import '../services/api_client.dart';
import 'recipe_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchCtrl = TextEditingController();
  int? _maxMinutos;
  Dificuldade? _dificuldade;
  final List<String> _ingredientIds = [];

  List<Recipe> _results = [];
  bool _loading = false;

  Future<void> _doSearch(AppState app) async {
    setState(() => _loading = true);
    try {
      final res = await app.api.getRecipes(
        query: _searchCtrl.text,
        maxMinutos: _maxMinutos,
        dificuldade: _dificuldade,
        ingredientIds: _ingredientIds,
      );
      setState(() => _results = res);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final ings = app.api.getMockIngredients();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        title: TextField(
          controller: _searchCtrl,
          decoration: const InputDecoration(border: InputBorder.none, hintText: 'Buscar'),
          onSubmitted: (_) => _doSearch(app),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.menu), onPressed: () => _openFilters(context, ings)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _results.length,
              itemBuilder: (context, i) {
                final r = _results[i];
                return Card(
                  child: ListTile(
                    title: Text(r.titulo),
                    onTap: () {
                      app.markViewed(r.id);
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => RecipeDetailsScreen(recipe: r)));
                    },
                  ),
                );
              },
            ),
    );
  }

  void _openFilters(BuildContext context, List ings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tempo de preparo', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButton<int>(
                isExpanded: true,
                value: _maxMinutos,
                items: const [
                  DropdownMenuItem(value: 15, child: Text('≤ 15 min')),
                  DropdownMenuItem(value: 30, child: Text('≤ 30 min')),
                  DropdownMenuItem(value: 45, child: Text('≤ 45 min')),
                ],
                hint: const Text('Selecione'),
                onChanged: (v) => setState(() => _maxMinutos = v),
              ),
              const SizedBox(height: 12),
              Text('Dificuldade', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButton<Dificuldade>(
                isExpanded: true,
                value: _dificuldade,
                items: const [
                  DropdownMenuItem(value: Dificuldade.iniciante, child: Text('Iniciante')),
                  DropdownMenuItem(value: Dificuldade.intermediario, child: Text('Iniciante+')),
                  DropdownMenuItem(value: Dificuldade.avancado, child: Text('Avançado')),
                ],
                hint: const Text('Selecione'),
                onChanged: (v) => setState(() => _dificuldade = v),
              ),
              const SizedBox(height: 12),
              Text('Ingredientes', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final i in ings)
                    FilterChip(
                      label: Text(i.nome),
                      selected: _ingredientIds.contains(i.id),
                      onSelected: (sel) {
                        setState(() {
                          if (sel) {
                            _ingredientIds.add(i.id);
                          } else {
                            _ingredientIds.remove(i.id);
                          }
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
