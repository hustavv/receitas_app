import 'package:dio/dio.dart';
import '../core/http.dart';

class RecipeRepository {
  RecipeRepository() : _dio = ApiHttp.instance;
  final Dio _dio;

  Future<List<Map<String, dynamic>>> list({
    String? title,
    int? cookTimeMinutes,
    int? servings,
    String? categoryId,
    int page = 0,
    int size = 10,
  }) async {
    final res = await _dio.get('/recipes', queryParameters: {
      if (title != null && title.isNotEmpty) 'title': title,
      if (cookTimeMinutes != null) 'cookTimeMinutes': cookTimeMinutes,
      if (servings != null) 'servings': servings,
      if (categoryId != null && categoryId.isNotEmpty) 'categoryId': categoryId,
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

  Future<Map<String, dynamic>?> byId(String id) async {
    final res = await _dio.get('/recipes/$id');
    final data = res.data;
    if (data is Map && data['data'] is Map) {
      return Map<String, dynamic>.from(data['data']);
    }
    return data is Map<String, dynamic> ? data : null;
  }

  Future<Map<String, dynamic>> create({
    required String title,
    required String instructions,
    required int cookTimeMinutes,
    required int servings,
    String? imageUrl,
    required Map<String, dynamic> category, // {id,name,description}
    required List<Map<String, dynamic>> ingredients, // [{ingredient:{...}, quantity}]
  }) async {
    final payload = {
      'title': title,
      'instructions': instructions,
      'cookTimeMinutes': cookTimeMinutes,
      'servings': servings,
      if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
      'category': category,
      'ingredients': ingredients,
    };
    final res = await _dio.post('/recipes', data: payload);
    final data = res.data;
    return data is Map<String, dynamic> ? data : {'data': data};
  }
}