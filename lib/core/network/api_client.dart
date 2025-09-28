import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/jwt_token_manager.dart';

class ApiClient {
  ApiClient(this._dio, this._tokenManager);

  final Dio _dio;
  final JwtTokenManager _tokenManager;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _request<T>(
      () => _dio.get(
        path,
        queryParameters: queryParameters,
        options: await _authorizedOptions(),
      ),
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
  }) async {
    return _request<T>(
      () => _dio.post(
        path,
        data: data,
        options: await _authorizedOptions(),
      ),
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
  }) async {
    return _request<T>(
      () => _dio.put(
        path,
        data: data,
        options: await _authorizedOptions(),
      ),
    );
  }

  Future<Response<T>> _request<T>(Future<Response<T>> Function() handler) async {
    try {
      final response = await handler();
      return response;
    } on DioException catch (error) {
      final requestOptions = error.requestOptions;
      final prefs = await SharedPreferences.getInstance();
      final offlineKey = 'offline_${requestOptions.method}_${requestOptions.path}';
      await prefs.setString(
        offlineKey,
        jsonEncode(
          <String, dynamic>{
            'data': requestOptions.data,
            'headers': requestOptions.headers,
            'timestamp': DateTime.now().toIso8601String(),
          },
        ),
      );
      rethrow;
    }
  }

  Future<Options> _authorizedOptions() async {
    final token = await _tokenManager.getToken();
    return Options(
      headers: <String, dynamic>{
        if (token != null) 'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }
}
