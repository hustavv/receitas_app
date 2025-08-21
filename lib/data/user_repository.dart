// lib/data/user_repository.dart
import 'package:dio/dio.dart';
import '../core/http.dart';

class UserRepository {
  UserRepository() : _dio = ApiHttp.build();
  final Dio _dio;

  Future<void> login(String email, String password) async {
    await _dio.post('/auth/login', data: {'email': email, 'password': password});
  }

  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }

  Future<Map<String, dynamic>> me() async {
    final res = await _dio.get('/users/me');
    final data = res.data;
    return data is Map<String, dynamic> ? data : {'data': data};
  }


Future<void> register({
  required String firstName,
  required String lastName,
  required String email,
  required String password,
}) async {
  await _dio.post('/users', data: {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'password': password,
  });
}
}
