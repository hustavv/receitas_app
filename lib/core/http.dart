import 'package:dio/dio.dart';
import 'package:dio/browser.dart';
import 'cookies.dart';

class ApiHttp {
  ApiHttp._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:8080/api/v1',
      headers: {'Accept': 'application/json'},
    ));

    // Web: enviar cookies httpOnly
    final adapter = BrowserHttpClientAdapter()..withCredentials = true;
    _dio.httpClientAdapter = adapter;

    _setupInterceptors();
  }

  static final ApiHttp _instance = ApiHttp._internal();
  static Dio get instance => _instance._dio;

  late final Dio _dio;
  bool _refreshing = false;

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Atualiza tokens em TODA ação (toda request), exceto a própria /auth/refresh
          if (!_isRefreshPath(options.path)) {
            await _refreshToken();
          }

          // CSRF para verbos mutantes
          final m = options.method.toUpperCase();
          if (m == 'POST' || m == 'PUT' || m == 'PATCH' || m == 'DELETE') {
            final xsrf = readCookie('XSRF-TOKEN');
            if (xsrf != null && xsrf.isNotEmpty) {
              options.headers['X-XSRF-TOKEN'] = xsrf;
            }
          }

          handler.next(options);
        },
        onError: (err, handler) async {
          // Se ainda deu 401, tenta um refresh forçado e refaz a request 1x
          if (err.response?.statusCode == 401 && !_isAuthPath(err.requestOptions.path)) {
            try {
              await _refreshToken(force: true);
              final retry = await _dio.fetch(err.requestOptions);
              return handler.resolve(retry);
            } catch (_) {
              // cai no handler.next abaixo
            }
          }
          return handler.next(err);
        },
      ),
    );
  }

  bool _isAuthPath(String p) =>
      p.startsWith('/auth/login') ||
      p.startsWith('/auth/logout') ||
      p.startsWith('/auth/refresh');

  bool _isRefreshPath(String p) => p.startsWith('/auth/refresh');

  Future<void> _refreshToken({bool force = false}) async {
    if (_refreshing && !force) return;

    _refreshing = true;
    try {
      final refreshDio = Dio(BaseOptions(baseUrl: _dio.options.baseUrl));
      refreshDio.httpClientAdapter = BrowserHttpClientAdapter()..withCredentials = true;

      // A API usa cookies httpOnly; normalmente não precisa body
      await refreshDio.post('/auth/refresh');
    } catch (_) {
      // MUITO IMPORTANTE: não propagar erro aqui
      // para não quebrar login/logout e outras primeiras ações.
    } finally {
      _refreshing = false;
    }
  }
}