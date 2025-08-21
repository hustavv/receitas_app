// lib/data/favorite_repository.dart
import 'package:dio/dio.dart';
import '../core/http.dart';
import 'user_repository.dart';

class FavoriteRepository {
  FavoriteRepository() : _dio = ApiHttp.build();
  final Dio _dio;

  Future<List<Map<String, dynamic>>> list({
    String? userId,
    int page = 0,
    int size = 10,
  }) async {
    final res = await _dio.get('/favorites', queryParameters: {
      if (userId != null && userId.isNotEmpty) 'userId': userId,
      'page': page,
      'size': size,
    });
    final data = res.data;
    if (data is Map && data['data'] is List) {
      return List<Map<String, dynamic>>.from(data['data']);
    }
    if (data is List) return List<Map<String, dynamic>>.from(data);
    return [];
  }

  Future<void> add(String recipeId) async {
    await _dio.post('/favorites', data: {'recipe': {'id': recipeId}});
  }

  Future<void> remove(String favoriteId) async {
    await _dio.delete('/favorites/$favoriteId');
  }


/// Adiciona um favorito enviando o payload completo esperado pela API
/// { user: {...}, recipe: {...} }
Future<void> addFromRecipe(Map<String, dynamic> recipe) async {
  // Obter usuário logado
  final meWrap = await UserRepository().me();
  final user = Map<String, dynamic>.from(meWrap['data'] ?? meWrap);
  // Montar payload conforme swagger
  final payload = {
    'user': user,
    'recipe': recipe,
  };
  await _dio.post('/favorites', data: payload);
}
}