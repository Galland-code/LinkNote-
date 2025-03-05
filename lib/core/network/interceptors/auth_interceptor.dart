import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 认证拦截器，为请求添加认证Token
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 尝试获取认证Token
    final token = await _secureStorage.read(key: 'auth_token');

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return super.onRequest(options, handler);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // 如果响应是401（未授权），可能是Token过期
    if (err.response?.statusCode == 401) {
      // 这里可以添加自动刷新Token的逻辑
      // 如果刷新成功，可以重试原始请求
    }

    return super.onError(err, handler);
  }
}