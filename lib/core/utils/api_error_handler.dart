// lib/core/utils/api_error_handler.dart
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import '../../../app/widgets/pixel_toast.dart';

class ApiErrorHandler {
  // 处理API错误并返回用户友好消息
  static String handleError(dynamic error) {
    String errorMessage = "发生未知错误";

    if (error is dio.DioError) {
      switch (error.type) {
        case dio.DioErrorType.connectionTimeout:
        case dio.DioErrorType.sendTimeout:
        case dio.DioErrorType.receiveTimeout:
          errorMessage = "连接超时，请检查网络";
          break;
        case dio.DioErrorType.badResponse:
          errorMessage = _handleResponseError(error.response);
          break;
        case dio.DioErrorType.cancel:
          errorMessage = "请求被取消";
          break;
        case dio.DioErrorType.unknown:
          errorMessage = "网络错误，请检查网络连接";
          break;
        default:
          errorMessage = "网络异常，请稍后重试";
          break;
      }
    } else {
      errorMessage = error.toString();
    }

    return errorMessage;
  }

  // 处理响应错误
  static String _handleResponseError(dio.Response? response) {
    if (response == null) {
      return "服务器无响应";
    }

    switch (response.statusCode) {
      case 400:
        return _parseErrorMessage(response, "请求参数错误");
      case 401:
        return "登录已过期，请重新登录";
      case 403:
        return "没有操作权限";
      case 404:
        return "请求的资源不存在";
      case 500:
        return "服务器内部错误";
      default:
        return "服务器错误(${response.statusCode})";
    }
  }

  // 解析错误消息
  static String _parseErrorMessage(dio.Response response, String defaultMsg) {
    try {
      if (response.data is Map && response.data.containsKey('message')) {
        return response.data['message'];
      }
      return defaultMsg;
    } catch (e) {
      return defaultMsg;
    }
  }

  // 显示错误提示
  static void showError(dynamic error) {
    final message = handleError(error);
    PixelToast.showError(message);
  }
}
