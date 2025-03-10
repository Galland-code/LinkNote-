import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/values/app_constants.dart';

class ApiProvider extends GetxService {
  final dio.Dio _dio = dio.Dio();

  // 初始化API提供者
  Future<ApiProvider> init() async {
    // 配置基础URL
    _dio.options.baseUrl =
        AppConstants.BASE_URL;
    _dio.options.connectTimeout = Duration(milliseconds: 10000);
    _dio.options.receiveTimeout = Duration(milliseconds: 10000);

    // 配置请求头
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // 添加请求拦截器 - 自动附加认证令牌
    _dio.interceptors.add(
      dio.InterceptorsWrapper(
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
      ),
    );

    // 添加日志拦截器
    _dio.interceptors.add(
      dio.LogInterceptor(requestBody: true, responseBody: true),
    );

    return this;
  }

  // 请求拦截器 - 添加认证Token
  void _requestInterceptor(
      dio.RequestOptions options,
      dio.RequestInterceptorHandler handler,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }


  // 错误拦截器 - 处理Token过期等错误
  void _errorInterceptor(
      dio.DioError error,
      dio.ErrorInterceptorHandler handler,
      ) async {
    // 处理401未授权错误 - 可能是Token过期
    if (error.response?.statusCode == 401) {
      // 尝试刷新Token
      final refreshSuccess = await _refreshToken();

      if (refreshSuccess) {
        // Token刷新成功，重试原始请求
        final opts = error.requestOptions;
        final prefs = await SharedPreferences.getInstance();
        final newToken = prefs.getString('token');

        opts.headers['Authorization'] = 'Bearer $newToken';

        try {
          final response = await _dio.fetch(opts);
          handler.resolve(response);
          return;
        } catch (e) {
          // 重试失败，继续抛出错误
        }
      }

      // Token刷新失败，清除登录状态并导航到登录页
      _clearAuthAndRedirectToLogin();
    }

    handler.next(error);
  }

  // 刷新Token
  Future<bool> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refreshToken');

      if (refreshToken == null) {
        return false;
      }

      // 创建一个新的Dio实例用于刷新Token请求
      final tokenDio = dio.Dio();
      tokenDio.options.baseUrl = AppConstants.BASE_URL;

      return false;
    } catch (e) {
      return false;
    }
  }

  // 清除认证状态并重定向到登录页
  void _clearAuthAndRedirectToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('refreshToken');

    Get.offAllNamed('/auth/login');
  }

  // GET请求
  Future<dio.Response> get(
    String path, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParams);
    } catch (e) {
      return _handleError(e);
    }
  }

  // POST请求
  Future<dio.Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } catch (e) {
      return _handleError(e);
    }
  }

  // PUT请求
  Future<dio.Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } catch (e) {
      return _handleError(e);
    }
  }

  // DELETE请求
  Future<dio.Response> delete(String path, {dynamic data}) async {
    try {
      return await _dio.delete(path, data: data);
    } catch (e) {
      return _handleError(e);
    }
  }

  // 错误处理
  dio.Response _handleError(dynamic error) {
    if (error is dio.DioException) {
      if (error.type == dio.DioExceptionType.connectionTimeout ||
          error.type == dio.DioExceptionType.receiveTimeout ||
          error.type == dio.DioExceptionType.sendTimeout) {
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

extension on Response {
  get data => null;
}
