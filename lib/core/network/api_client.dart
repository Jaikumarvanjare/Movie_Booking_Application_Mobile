import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';
import 'api_response.dart';

class ApiClient {
  ApiClient({required AppConfig config, required TokenStorage tokenStorage})
    : _config = config,
      _tokenStorage = tokenStorage,
      _dio = Dio(
        BaseOptions(
          baseUrl: config.apiBaseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
          headers: const {'Content-Type': 'application/json'},
        ),
      ) {
    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.readToken();
          if (token != null && token.trim().isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final AppConfig _config;
  final TokenStorage _tokenStorage;
  final Dio _dio;

  Future<ApiResponse> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _send(
      () => _dio.get<dynamic>(path, queryParameters: queryParameters),
    );
  }

  Future<ApiResponse> post(String path, {Object? data}) {
    return _send(() => _dio.post<dynamic>(path, data: data));
  }

  Future<ApiResponse> patch(String path, {Object? data}) {
    return _send(() => _dio.patch<dynamic>(path, data: data));
  }

  Future<ApiResponse> delete(String path, {Object? data}) {
    return _send(() => _dio.delete<dynamic>(path, data: data));
  }

  Future<ApiResponse> _send(
    Future<Response<dynamic>> Function() request,
  ) async {
    if (!_config.isConfigured) {
      throw ApiException.configuration(
        'API_BASE_URL is missing. Add it to .env or pass --dart-define=API_BASE_URL=http://<host>:3000/mba/api/v1.',
      );
    }

    try {
      final response = await request();
      final responseBody = response.data;
      if (responseBody is! Map) {
        throw const ApiException(
          message: 'The server returned an unexpected response.',
        );
      }

      final apiResponse = ApiResponse.fromJson(
        Map<String, dynamic>.from(responseBody),
      );

      if (!apiResponse.success) {
        throw ApiException(
          message: buildApiErrorMessage(
            primaryMessage: apiResponse.message,
            errorDetails: apiResponse.error,
            defaultMessage: 'The request could not be completed.',
          ),
          statusCode: response.statusCode,
        );
      }

      return apiResponse;
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }
}
