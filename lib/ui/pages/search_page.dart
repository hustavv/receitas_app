// lib/ui/pages/search_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/recipe_repository.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _q = TextEditingController();
  List<Map<String,dynamic>> _results = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _search(); // initial
  }

  Future<void> _search() async {
    setState(()=>_loading = true);
    try {
      _results = await RecipeRepository().list(
        title: _q.text.trim().isEmpty ? null : _q.text.trim(),
        page: 0,
        size: 10,
      );
    } finally {
      setState(()=>_loading = false);
    }
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
            child: Row(children: [
              Expanded(child: TextField(controller: _q, onSubmitted: (_)=>_search(), decoration: const InputDecoration(hintText: 'Nome da receita...'))),
              IconButton(icon: const Icon(Icons.clear), onPressed: () { _q.clear(); _search(); }),
              IconButton(icon: const Icon(Icons.search), onPressed: _search),
            ]),
          ),
          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (_, i) => ListTile(
                    title: Text(_results[i]['title'] ?? _results[i]['name'] ?? 'Receita'),
                    onTap: () {
                      final id = (_results[i]['id'] ?? '').toString();
                      if (id.isNotEmpty) context.go('/recipe/$id');
                    },
                  ),
                ),
          )
        ],
      ),
    );
  }
}
