import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 日志拦截器，打印请求和响应日志
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('┌── 🌐 Request: ${options.method} ${options.uri}');
    debugPrint('│ Headers: ${options.headers}');
    debugPrint('│ Data: ${options.data}');
    debugPrint('└─────────────────────────────');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('┌── ✅ Response: ${response.statusCode} ${response.requestOptions.uri}');
    debugPrint('│ Data: ${response.data}');
    debugPrint('└─────────────────────────────');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('┌── ❌ Error: ${err.type} ${err.requestOptions.uri}');
    debugPrint('│ Message: ${err.message}');
    if (err.response != null) {
      debugPrint('│ Response: ${err.response?.data}');
    }
    debugPrint('└─────────────────────────────');
    super.onError(err, handler);
  }
}