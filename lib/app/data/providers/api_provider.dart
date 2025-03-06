import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/values/app_constants.dart';

class ApiProvider extends GetxService {
  final Dio _dio = Dio();

  // 初始化API提供者
  Future<ApiProvider> init() async {
    // 配置基础URL
    _dio.options.baseUrl = AppConstants.BASE_URL; // 如: 'http://your-backend.com/api'
    _dio.options.connectTimeout = Duration(milliseconds: 10000);
    _dio.options.receiveTimeout = Duration(milliseconds: 10000);

    // 添加请求拦截器 - 自动附加认证令牌
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        // 处理401未授权错误 - 可能需要刷新令牌或重新登录
        if (error.response?.statusCode == 401) {
          // 处理令牌过期逻辑
        }
        return handler.next(error);
      },
    ));

    // 添加日志拦截器
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));

    return this;
  }

  // GET请求
  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) async {
    try {
      return await _dio.get(path, queryParameters: queryParams);
    } catch (e) {
      return _handleError(e);
    }
  }

  // POST请求
  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } catch (e) {
      return _handleError(e);
    }
  }

  // PUT请求
  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } catch (e) {
      return _handleError(e);
    }
  }

  // DELETE请求
  Future<Response> delete(String path, {dynamic data}) async {
    try {
      return await _dio.delete(path, data: data);
    } catch (e) {
      return _handleError(e);
    }
  }

  // 错误处理
  Response _handleError(dynamic error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        // 处理超时错误
        throw Exception('连接超时，请检查网络');
      }

      if (error.response != null) {
        // 返回服务器响应的错误
        return error.response!;
      }
    }

    throw Exception('发生网络错误: ${error.toString()}');
  }
}