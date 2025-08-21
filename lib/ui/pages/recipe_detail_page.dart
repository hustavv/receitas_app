// lib/ui/pages/recipe_detail_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/recipe_repository.dart';

class RecipeDetailPage extends StatefulWidget {
  final String id;
  const RecipeDetailPage({super.key, required this.id});
  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  Map<String,dynamic>? _recipe;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    RecipeRepository().byId(widget.id).then((v){
      setState((){ _recipe = v; _loading = false; });
    }).catchError((_){ setState(()=>_loading = false); });
  }

  @override
  Widget build(BuildContext context) {
    final r = _recipe;
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
        title: Text(r?['title'] ?? r?['name'] ?? 'Receita'),
      ),
      body: _loading ? const Center(child: CircularProgressIndicator()) :
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if ((r?['imageUrl'] ?? '').toString().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(r!['imageUrl'], height: 180, fit: BoxFit.cover),
              ),
            const SizedBox(height: 12),
            Wrap(spacing: 12, children: [
              Chip(label: Text('⏱ ${r?['cookTimeMinutes'] ?? '-'} min')),
              Chip(label: Text('🍽 ${r?['servings'] ?? '-'} porções')),
              if (r?['category']?['name']!=null) Chip(label: Text(r!['category']['name'])),
            ]),
            const SizedBox(height: 16),
            Text(r?['instructions'] ?? '', style: const TextStyle(height: 1.4)),
          ],
        ),
    );
  }
}
