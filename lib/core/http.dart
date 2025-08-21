// lib/core/http.dart
import 'package:dio/dio.dart';
import 'package:dio/browser.dart';
import 'cookies.dart';

class ApiHttp {
  static Dio build({String baseUrl = 'http://localhost:8080/api/v1'}) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {'Accept': 'application/json'},
    ));
    // Flutter web cookie support
    dio.httpClientAdapter = BrowserHttpClientAdapter()..withCredentials = true;

    // CSRF header injection for mutating requests
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      final m = options.method.toUpperCase();
      if (m == 'POST' || m == 'PUT' || m == 'PATCH' || m == 'DELETE') {
        final xsrf = readCookie('XSRF-TOKEN');
        if (xsrf != null && xsrf.isNotEmpty) {
          options.headers['X-XSRF-TOKEN'] = xsrf;
        }
      }
      handler.next(options);
    }));

    // 401 -> try refresh
    dio.interceptors.add(InterceptorsWrapper(onError: (err, handler) async {
      if (err.response?.statusCode == 401 && !_isAuthPath(err.requestOptions.path)) {
        try {
          final refreshDio = Dio(BaseOptions(baseUrl: dio.options.baseUrl));
          refreshDio.httpClientAdapter = BrowserHttpClientAdapter()..withCredentials = true;
          await refreshDio.post('/auth/refresh');
          final retry = await dio.fetch(err.requestOptions);
          return handler.resolve(retry);
        } catch (_) {}
      }
      return handler.next(err);
    }));

    return dio;
  }

  static bool _isAuthPath(String p) =>
      p.startsWith('/auth/login') || p.startsWith('/auth/logout') || p.startsWith('/auth/refresh');
}
