import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // 导入 flutter_svg 包
import '../../core/theme/app_theme.dart';

/// A reusable card widget with pixelated border style
class PixelCard extends StatelessWidget {
  final Widget child; // 卡片内部的子组件
  final Color backgroundColor; // 卡片的背景颜色
  final EdgeInsetsGeometry padding; // 卡片的内边距
  final EdgeInsetsGeometry margin; // 卡片的外边距
  final double borderWidth; // 边框的宽度
  final BorderRadius borderRadius; // 边框的圆角

  const PixelCard({
    Key? key,
    required this.child,
    this.backgroundColor = Colors.white, // 背景颜色为白色
    this.padding = const EdgeInsets.all(16), // 内边距
    this.margin = const EdgeInsets.symmetric(
      vertical: 8,
      horizontal: 16,
    ), // 默认外边距
    this.borderWidth = 5, // 默认边框宽度为2
    this.borderRadius = const BorderRadius.all(Radius.circular(12)), // 圆角
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin, // 设置外边距
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.6), // 设置略透明的白色背景
        borderRadius: borderRadius, // 设置圆角
        border: Border.all(
          color: Colors.black, // 边框颜色为黑色
          width: borderWidth, // 设置边框宽度
        ),
      ),
      padding: padding, // 设置内边距
      child: child, // 显示子组件
    );
  }
}
