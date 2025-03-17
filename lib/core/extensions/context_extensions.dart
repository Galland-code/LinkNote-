import 'package:flutter/material.dart';
import '../widgets/grid_background.dart';

extension ContextExtensions on BuildContext {
  // 添加网格背景的便捷方法
  Widget withGridBackground({
    required Widget child,
    Color backgroundColor = const Color(0xFFF5F5DC),
    Color gridColor = const Color(0xFFE6E6C8),
    double gridSize = 20.0,
    bool pixelStyle = true,
    bool enhanced = true,
  }) {
    if (enhanced && pixelStyle) {
      return EnhancedPixelGridBackground(
        backgroundColor: backgroundColor,
        gridColor: gridColor,
        gridSize: gridSize,
        child: child,
      );
    } else if (pixelStyle) {
      return PixelGridBackground(
        backgroundColor: backgroundColor,
        gridColor: gridColor,
        gridSize: gridSize,
        child: child,
      );
    } else {
      return CachedGridBackground(
        backgroundColor: backgroundColor,
        gridColor: gridColor,
        gridSize: gridSize,
        child: child,
      );
    }
  }
}
