// lib/ui/pages/recipe_create_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/recipe_repository.dart';
import '../../data/category_repository.dart';
import '../../data/ingredient_repository.dart';

class RecipeCreatePage extends StatefulWidget {
  const RecipeCreatePage({super.key});
  @override
  State<RecipeCreatePage> createState() => _RecipeCreatePageState();
}

class _RecipeCreatePageState extends State<RecipeCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _instructions = TextEditingController();
  final _cook = TextEditingController();
  final _serv = TextEditingController();
  final _img  = TextEditingController();

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _allIngredients = [];
  Map<String, dynamic>? _selectedCategory;
  final List<Map<String, dynamic>> _selectedIngredients = []; // {ingredient:{...}, quantity}

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadIngredients();
  }

  Future<void> _loadCategories() async {
    _categories = await CategoryRepository().list(page: 0, size: 50);
    setState(() {});
  }

  Future<void> _loadIngredients() async {
    _allIngredients = await IngredientRepository().list(page: 0, size: 100);
    setState(() {});
  }

  Future<void> _createCategoryInline() async {
    final name = TextEditingController();
    final desc = TextEditingController();
    final created = await showDialog<Map<String,dynamic>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova categoria'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Nome *')),
            TextField(controller: desc, decoration: const InputDecoration(labelText: 'Descrição')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(onPressed: () async {
            if (name.text.trim().isEmpty) return;
            final res = await CategoryRepository().create(name: name.text.trim(), description: desc.text.trim());
            Navigator.pop(ctx, (res['data'] ?? res));
          }, child: const Text('Criar'))
        ],
      ),
    );
    if (created != null) {
      await _loadCategories();
      final createdId = (created['id'] ?? created['data']?['id'])?.toString();
      _selectedCategory = _categories.firstWhere(
        (c) => (c['id']?.toString() == createdId) || (c['name'] == created['name']),
        orElse: () => created,
      );
      setState((){});
    }
  }

  Future<void> _addIngredientInline() async {
    Map<String, dynamic>? selected;
    final qtyCtrl = TextEditingController();
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('Adicionar ingrediente'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Map<String, dynamic>>(
                items: _allIngredients.map((i)=>DropdownMenuItem(value: i, child: Text(i['name']))).toList(),
                onChanged: (v)=> setSt(()=>selected = v),
                decoration: const InputDecoration(labelText: 'Ingrediente'),
              ),
              TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: 'Quantidade')),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () async {
                    final name = TextEditingController();
                    final desc = TextEditingController();
                    final created = await showDialog<Map<String,dynamic>>(
                      context: ctx,
                      builder: (c2) => AlertDialog(
                        title: const Text('Novo ingrediente'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(controller: name, decoration: const InputDecoration(labelText: 'Nome *')),
                            TextField(controller: desc, decoration: const InputDecoration(labelText: 'Descrição')),
                          ],
                        ),
                        actions: [
                          TextButton(onPressed: ()=>Navigator.pop(c2), child: const Text('Cancelar')),
                          FilledButton(onPressed: () async {
                            if (name.text.trim().isEmpty) return;
                            final res = await IngredientRepository().create(name: name.text.trim(), description: desc.text.trim());
                            Navigator.pop(c2, (res['data'] ?? res));
                          }, child: const Text('Criar')),
                        ],
                      ),
                    );
                    if (created != null) {
                      await _loadIngredients();
                      final newId = (created['id'] ?? created['data']?['id'])?.toString();
                      selected = _allIngredients.firstWhere(
                        (i) => (i['id']?.toString() == newId) || (i['name'] == created['name']),
                        orElse: () => created,
                      );
                      setSt((){});
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Novo ingrediente'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(onPressed: (){
              if (selected != null && qtyCtrl.text.trim().isNotEmpty) {
                Navigator.pop(ctx, {'ingredient': selected!, 'quantity': qtyCtrl.text.trim()});
              }
            }, child: const Text('Adicionar')),
          ],
        ),
      ),
    );
    if (result != null) {
      setState(()=> _selectedIngredients.add(result));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) return;
    setState(()=>_saving = true);
    try {
      await RecipeRepository().create(
        title: _title.text.trim(),
        instructions: _instructions.text.trim(),
        cookTimeMinutes: int.parse(_cook.text.trim()),
        servings: int.parse(_serv.text.trim()),
        imageUrl: _img.text.trim().isEmpty ? null : _img.text.trim(),
        category: _selectedCategory!,
        ingredients: _selectedIngredients,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Receita criada!')));
      context.go('/');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao criar: $e')));
    } finally {
      if (mounted) setState(()=>_saving = false);
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
        title: const Text('Nova receita'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Título *'),
              validator: (v)=> (v==null || v.trim().isEmpty) ? 'Informe o título' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _instructions,
              decoration: const InputDecoration(labelText: 'Instruções *'),
              maxLines: 3,
              validator: (v)=> (v==null || v.trim().isEmpty) ? 'Informe as instruções' : null,
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: TextFormField(controller: _cook, decoration: const InputDecoration(labelText: 'Tempo (min) *'), keyboardType: TextInputType.number, validator: (v)=> (int.tryParse(v??'')==null)?'Número':null)),
              const SizedBox(width: 8),
              Expanded(child: TextFormField(controller: _serv, decoration: const InputDecoration(labelText: 'Porções *'), keyboardType: TextInputType.number, validator: (v)=> (int.tryParse(v??'')==null)?'Número':null)),
            ]),
            const SizedBox(height: 8),
            TextFormField(controller: _img, decoration: const InputDecoration(labelText: 'Imagem (URL)')),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<Map<String, dynamic>>(
                    items: _categories.map((c)=>DropdownMenuItem(value: c, child: Text(c['name']))).toList(),
                    value: _selectedCategory,
                    onChanged: (v)=>setState(()=>_selectedCategory = v),
                    decoration: const InputDecoration(labelText: 'Categoria *'),
                    validator: (v)=> v==null ? 'Selecione ou crie uma categoria' : null,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _createCategoryInline,
                  icon: const Icon(Icons.add),
                  tooltip: 'Nova categoria',
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              title: const Text('Ingredientes'),
              trailing: IconButton(icon: const Icon(Icons.add), onPressed: _addIngredientInline),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (int i=0;i<_selectedIngredients.length;i++)
                  Chip(
                    label: Text("${_selectedIngredients[i]['ingredient']['name']} - ${_selectedIngredients[i]['quantity']}"),
                    onDeleted: ()=>setState(()=>_selectedIngredients.removeAt(i)),
                  )
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving ? const SizedBox(height:18, width:18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save),
              label: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
