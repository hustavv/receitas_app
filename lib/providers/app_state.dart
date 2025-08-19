import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import '../models/user.dart';
import '../services/api_client.dart';
import '../repositories/favorites_repository.dart';
import '../repositories/viewed_repository.dart';

class AppState extends ChangeNotifier {
  final ApiClient api;
  final FavoritesRepository favoritesRepo;
  final ViewedRepository viewedRepo;

  AppState({required this.api, required this.favoritesRepo, required this.viewedRepo});

  AppUser? _user;
  AppUser? get user => _user;

  List<Recipe> _allRecipes = [];
  List<Recipe> get allRecipes => _allRecipes;

  List<Recipe> _myRecipes = [];
  List<Recipe> get myRecipes => _myRecipes;

  Set<String> _favoriteIds = {};
  Set<String> get favoriteIds => _favoriteIds;

  List<String> _viewedIds = [];
  List<String> get viewedIds => _viewedIds;

  bool _ready = false;
  bool get ready => _ready;

  Future<void> login(String email, String senha) async {
    _user = await api.login(email, senha);
    await initAfterLogin();
  }

  Future<void> initAfterLogin() async {
    _favoriteIds = await favoritesRepo.loadFavorites();
    _viewedIds = await viewedRepo.loadViewed();
    _allRecipes = await api.getRecipes();
    if (_user != null) {
      _myRecipes = await api.getUserRecipes(_user!.id);
    } else {
      _myRecipes = [];
    }
    _ready = true;
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    await favoritesRepo.toggle(id);
    _favoriteIds = await favoritesRepo.loadFavorites();
    notifyListeners();
  }

  Future<void> markViewed(String id) async {
    await viewedRepo.addViewed(id);
    _viewedIds = await viewedRepo.loadViewed();
    notifyListeners();
  }

  List<Recipe> get favoriteRecipes =>
      _allRecipes.where((r) => _favoriteIds.contains(r.id)).toList();

  List<Recipe> get viewedRecipes =>
      _allRecipes.where((r) => _viewedIds.contains(r.id)).toList();
}
