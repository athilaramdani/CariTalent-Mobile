import 'package:caritalent_mobile/core/network/api_exception.dart';
import 'package:caritalent_mobile/core/storage/secure_storage_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(storage);
});

class ApiClient {
  ApiClient(this._storage)
    : _dio = Dio(
        BaseOptions(
          baseUrl: const String.fromEnvironment(
            'API_BASE_URL',
            defaultValue: '',
          ),
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {'Accept': 'application/json'},
        ),
      ) {
    if (_dio.options.baseUrl.isEmpty) {
      _dio.options.baseUrl = _defaultBaseUrl();
    }

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

    // Debug: log all HTTP traffic to find FCM token 404
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: false,
      logPrint: (o) => debugPrint('[DIO] $o'),
    ));
  }

  final Dio _dio;
  final SecureStorageService _storage;

  String _defaultBaseUrl() {
    // Jika di Web, gunakan localhost agar lebih stabil
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api/v1';
    }
    // Jika di HP Fisik/Emulator, gunakan IP lokal laptop
    return 'http://10.154.41.15:8000/api/v1';
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(Object? json) parser,
  }) async {
    return _request(
      () => _dio.get(path, queryParameters: queryParameters),
      parser,
    );
  }

  Future<T> getRaw<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(Object? json) parser,
  }) async {
    return _request(
      () => _dio.get(path, queryParameters: queryParameters),
      parser,
      unwrapData: false,
    );
  }

  Future<T> post<T>(
    String path, {
    Object? data,
    required T Function(Object? json) parser,
  }) async {
    return _request(() => _dio.post(path, data: data), parser);
  }

  Future<T> put<T>(
    String path, {
    Object? data,
    required T Function(Object? json) parser,
  }) async {
    return _request(() => _dio.put(path, data: data), parser);
  }

  Future<T> delete<T>(
    String path, {
    required T Function(Object? json) parser,
  }) async {
    return _request(() => _dio.delete(path), parser);
  }

  Future<T> _request<T>(
    Future<Response<dynamic>> Function() request,
    T Function(Object? json) parser,
    {
    bool unwrapData = true,
  }) async {
    try {
      final response = await request();
      final body = response.data;
      if (body is Map<String, dynamic> && body['success'] == false) {
        throw ApiException(
          (body['message'] ?? 'Request gagal').toString(),
          statusCode: response.statusCode,
          errors: body['errors'],
        );
      }
      final payload =
          unwrapData && body is Map<String, dynamic> ? body['data'] : body;
      return parser(payload);
    } on DioException catch (error) {
      final body = error.response?.data;
      if (body is Map<String, dynamic>) {
        throw ApiException(
          (body['message'] ?? 'Request gagal').toString(),
          statusCode: error.response?.statusCode,
          errors: body['errors'],
        );
      }
      throw ApiException(
        error.message ?? 'Tidak bisa terhubung ke server',
        statusCode: error.response?.statusCode,
      );
    }
  }
}
