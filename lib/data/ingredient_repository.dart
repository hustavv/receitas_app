// lib/data/ingredient_repository.dart
import 'package:dio/dio.dart';
import '../core/http.dart';

class IngredientRepository {
  IngredientRepository() : _dio = ApiHttp.build();
  final Dio _dio;

  Future<List<Map<String, dynamic>>> list({String? name, int page = 0, int size = 100}) async {
    final res = await _dio.get('/ingredients', queryParameters: {
      if (name != null && name.isNotEmpty) 'name': name,
      'page': page,
      'size': size,
    });
    final data = res.data;
    if (data is Map && data['data'] is List) {
      return List<Map<String, dynamic>>.from(data['data']);
    }
    return [];
  }

  Future<Map<String, dynamic>> create({required String name, String? description}) async {
    final payload = {'name': name, if (description != null && description.isNotEmpty) 'description': description};
    final res = await _dio.post('/ingredients', data: payload);
    final data = res.data;
    return data is Map<String, dynamic> ? data : {'data': data};
  }
}
