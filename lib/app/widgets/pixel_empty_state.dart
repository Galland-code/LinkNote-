import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'pixel_button.dart';

/// 空状态组件，当没有数据时显示
class PixelEmptyState extends StatelessWidget {
  final String message;
  final String? imagePath;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const PixelEmptyState({
    Key? key,
    required this.message,
    this.imagePath,
    this.buttonText,
    this.onButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (imagePath != null) ...[
            Image.asset(
              imagePath!,
              width: 120,
              height: 120,
            ),
            SizedBox(height: 24),
          ],
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (buttonText != null && onButtonPressed != null) ...[
            SizedBox(height: 24),
            PixelButton(
              text: buttonText!,
              onPressed: onButtonPressed!,
              width: 200,
            ),
          ],
        ],
      ),
    );
  }
}
