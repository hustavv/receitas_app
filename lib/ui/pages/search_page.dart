// lib/ui/pages/search_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/recipe_repository.dart';
import '../../data/category_repository.dart';
import '../../data/favorite_repository.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _q = TextEditingController();
  final _cookCtrl = TextEditingController();
  final _servCtrl = TextEditingController();
  String? _categoryId;

  List<Map<String,dynamic>> _results = [];
  List<Map<String,dynamic>> _categories = [];
  bool _loading = false;
  bool _hasTyped = false;
  Timer? _deb;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _q.addListener(_onChanged);
    _cookCtrl.addListener(_onChanged);
    _servCtrl.addListener(_onChanged);
  }

  void _onChanged() {
    _hasTyped = _q.text.trim().isNotEmpty;
    _deb?.cancel();
    _deb = Timer(const Duration(milliseconds: 350), _search);
    setState((){});
  }

  Future<void> _loadCategories() async {
    _categories = await CategoryRepository().list(page: 0, size: 100);
    setState(() {});
  }

  Future<void> _search() async {
    if (!_hasTyped) return;
    setState(()=>_loading = true);
    try {
      final cook = int.tryParse(_cookCtrl.text.trim());
      final serv = int.tryParse(_servCtrl.text.trim());
      _results = await RecipeRepository().list(
        title: _q.text.trim(),
        cookTimeMinutes: cook,
        servings: serv,
        categoryId: _categoryId,
        page: 0,
        size: 20,
      );
    } finally {
      if (mounted) setState(()=>_loading = false);
    }
  }

  
Future<void> _addFavorite(Map<String,dynamic> recipe) async {
  try {
    await FavoriteRepository().addFromRecipe(recipe);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Adicionado aos favoritos!')));
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao favoritar: $e')));
  }
}


  @override
  void dispose() {
    _deb?.cancel();
    _q.dispose();
    _cookCtrl.dispose();
    _servCtrl.dispose();
    super.dispose();
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
        title: const Text('Buscar'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(children: [
                  Expanded(child: TextField(controller: _q, decoration: const InputDecoration(hintText: 'Nome da receita...'))),
                  IconButton(icon: const Icon(Icons.clear), onPressed: () { _q.clear(); _onChanged(); }),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: TextField(controller: _cookCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Tempo (min)'))),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(controller: _servCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Porções'))),
                ]),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: _categoryId,
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todas as categorias')),
                    ..._categories.map((c)=>DropdownMenuItem(value: (c['id']??'').toString(), child: Text(c['name']))),
                  ],
                  onChanged: (v){ setState(()=>_categoryId = v); _onChanged(); },
                  decoration: const InputDecoration(labelText: 'Categoria'),
                ),
              ],
            ),
          ),
          Expanded(
            child: !_hasTyped
              ? const Center(child: Text('Digite para buscar receitas.'))
              : (_loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (_, i) {
                        final r = _results[i];
                        final id = (r['id'] ?? '').toString();
                        return ListTile(
                          title: Text(r['title'] ?? r['name'] ?? 'Receita'),
                          subtitle: Text((r['category']?['name'] ?? '')),
                          onTap: ()=>context.go('/recipe/$id'),
                          trailing: IconButton(icon: const Icon(Icons.star_border), onPressed: () => _addFavorite(r),
                            tooltip: 'Adicionar aos favoritos',
                          ),
                        );
                      },
                    )
                ),
          )
        ],
      ),
    );
  }
}
