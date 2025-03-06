import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';

/// 像素风格的消息提示
class PixelToast {
  /// 显示成功消息
  static void showSuccess(String message) {
    _show(
      message: message,
      backgroundColor: Colors.green.shade100,
      borderColor: Colors.green,
      icon: Icon(Icons.check_circle, color: Colors.green),
    );
  }

  /// 显示错误消息
  static void showError(String message) {
    _show(
      message: message,
      backgroundColor: Colors.red.shade100,
      borderColor: Colors.red,
      icon: Icon(Icons.error, color: Colors.red),
    );
  }

  /// 显示信息消息
  static void showInfo(String message) {
    _show(
      message: message,
      backgroundColor: Colors.blue.shade100,
      borderColor: Colors.blue,
      icon: Icon(Icons.info, color: Colors.blue),
    );
  }

  /// 显示警告消息
  static void showWarning(String message) {
    _show(
      message: message,
      backgroundColor: Colors.orange.shade100,
      borderColor: Colors.orange,
      icon: Icon(Icons.warning, color: Colors.orange),
    );
  }

  /// 内部显示方法
  static void _show({
    required String message,
    required Color backgroundColor,
    required Color borderColor,
    required Widget icon,
    Duration duration = const Duration(seconds: 2),
  }) {
    // 移除之前的消息
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }

    Get.rawSnackbar(
      messageText: Row(
        children: [
          icon,
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      borderRadius: 12,
      borderColor: borderColor,
      borderWidth: 2,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: EdgeInsets.all(16),
      duration: duration,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      snackPosition: SnackPosition.BOTTOM,
      barBlur: 0,
      overlayBlur: 0,
    );
  }
}
