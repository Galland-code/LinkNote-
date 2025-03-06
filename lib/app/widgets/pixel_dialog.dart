import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import 'pixel_button.dart';

/// 像素风格的对话框
class PixelDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color backgroundColor;
  final Widget? icon;

  const PixelDialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmText = '确认',
    this.cancelText = '取消',
    this.onConfirm,
    this.onCancel,
    this.backgroundColor = Colors.white,
    this.icon,
  }) : super(key: key);

  /// 显示对话框的静态方法
  static Future<bool?> show({
    required String title,
    required String message,
    String confirmText = '确认',
    String cancelText = '取消',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Color backgroundColor = Colors.white,
    Widget? icon,
  }) {
    return Get.dialog<bool>(
      PixelDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        backgroundColor: backgroundColor,
        icon: icon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 300,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题
            Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // 内容
            Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    SizedBox(height: 16),
                  ],
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // 按钮
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  if (onCancel != null) ...[
                    Expanded(
                      child: PixelButton(
                        text: cancelText,
                        onPressed: () {
                          Get.back(result: false);
                          if (onCancel != null) onCancel!();
                        },
                        backgroundColor: Colors.grey,
                      ),
                    ),
                    SizedBox(width: 16),
                  ],
                  Expanded(
                    child: PixelButton(
                      text: confirmText,
                      onPressed: () {
                        Get.back(result: true);
                        if (onConfirm != null) onConfirm!();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}