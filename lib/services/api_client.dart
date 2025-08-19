import 'dart:async';

import '../models/category.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../models/user.dart';

class ApiClient {
  final String baseUrl;
  final bool mockMode;
  ApiClient({this.baseUrl = 'http://localhost:8080', this.mockMode = true});

  Future<AppUser> login(String email, String senha) async {
    if (mockMode) {
      await Future.delayed(const Duration(milliseconds: 250));
      return AppUser(
        id: '00000000-0000-0000-0000-000000000001',
        nome: 'Gustavo',
        sobrenome: 'Henrique',
        email: email,
        isAtivo: true,
      );
    }
    throw UnimplementedError();
  }

  Future<List<Recipe>> getRecipes({
    String? query,
    String? categoriaId,
    int? maxMinutos,
    Dificuldade? dificuldade,
    List<String>? ingredientIds,
  }) async {
    if (mockMode) {
      await Future.delayed(const Duration(milliseconds: 200));
      var data = List<Recipe>.from(_mockRecipes);
      if (query != null && query.trim().isNotEmpty) {
        data = data.where((r) => r.titulo.toLowerCase().contains(query.toLowerCase())).toList();
      }
      if (categoriaId != null) {
        data = data.where((r) => r.idCategoria == categoriaId).toList();
      }
      if (maxMinutos != null) {
        data = data.where((r) => r.minutosPreparo <= maxMinutos).toList();
      }
      if (dificuldade != null) {
        data = data.where((r) => r.dificuldade == dificuldade).toList();
      }
      if (ingredientIds != null && ingredientIds.isNotEmpty) {
        final byRecipe = _mockRecipeIngredient;
        data = data.where((r) => (byRecipe[r.id] ?? []).any((id) => ingredientIds.contains(id))).toList();
      }
      return data;
    }
    throw UnimplementedError();
  }

  Future<List<Recipe>> getUserRecipes(String userId) async {
    final all = await getRecipes();
    return all.where((r) => r.idUsuario == userId).toList();
  }

  Future<List<String>> getRecipeIngredients(String recipeId) async {
    if (mockMode) {
      await Future.delayed(const Duration(milliseconds: 160));
      return _mockRecipeIngredient[recipeId] ?? [];
    }
    throw UnimplementedError();
  }

  // Mock data
  static final List<Category> _mockCategories = [
    Category(id: 'cat-1', nome: 'Sobremesas', descricao: 'Doces e sobremesas'),
    Category(id: 'cat-2', nome: 'Massas', descricao: 'Massas e molhos'),
    Category(id: 'cat-3', nome: 'Saudáveis', descricao: 'Opções leves'),
  ];

  static final List<Ingredient> _mockIngredients = [
    Ingredient(id: 'ing-1', nome: 'Farinha'),
    Ingredient(id: 'ing-2', nome: 'Açúcar'),
    Ingredient(id: 'ing-3', nome: 'Ovo'),
    Ingredient(id: 'ing-4', nome: 'Leite'),
    Ingredient(id: 'ing-5', nome: 'Frango'),
    Ingredient(id: 'ing-6', nome: 'Cenoura'),
    Ingredient(id: 'ing-7', nome: 'Batata'),
  ];

  static final List<Recipe> _mockRecipes = [
    Recipe(
      id: 'rec-1',
      idUsuario: '00000000-0000-0000-0000-000000000001',
      idCategoria: 'cat-1',
      titulo: 'Pizza Portuguesa',
      instrucoes: 'Massa, molho, queijo, presunto, ovos e cebola. Assar 20–25 min.',
      minutosPreparo: 30,
      porcoes: 4,
      dificuldade: Dificuldade.iniciante,
      urlImagem: null,
      criadoEm: DateTime.now(),
    ),
    Recipe(
      id: 'rec-2',
      idUsuario: 'user-abc',
      idCategoria: 'cat-2',
      titulo: 'Espaguete ao Alho e Óleo',
      instrucoes: 'Cozinhar macarrão, saltear no alho e óleo, sal e pimenta.',
      minutosPreparo: 20,
      porcoes: 2,
      dificuldade: Dificuldade.iniciante,
      urlImagem: null,
      criadoEm: DateTime.now(),
    ),
    Recipe(
      id: 'rec-3',
      idUsuario: 'user-xyz',
      idCategoria: 'cat-3',
      titulo: 'Salada de Frango',
      instrucoes: 'Grelhar frango, fatiar e servir com folhas e molho.',
      minutosPreparo: 25,
      porcoes: 2,
      dificuldade: Dificuldade.intermediario,
      urlImagem: null,
      criadoEm: DateTime.now(),
    ),
  ];

  static final Map<String, List<String>> _mockRecipeIngredient = {
    'rec-1': ['ing-1', 'ing-2', 'ing-3', 'ing-4'],
    'rec-2': ['ing-1', 'ing-4'],
    'rec-3': ['ing-5', 'ing-7'],
  };

  List<Category> getMockCategories() => _mockCategories;
  List<Ingredient> getMockIngredients() => _mockIngredients;
}
