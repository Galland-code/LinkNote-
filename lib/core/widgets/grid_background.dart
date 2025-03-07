// lib/core/widgets/grid_background.dart
import 'dart:math';

import 'package:flutter/material.dart';

class GridBackground extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color gridColor;
  final double gridSize;
  final double gridLineWidth;

  const GridBackground({
    Key? key,
    required this.child,
    this.backgroundColor = const Color(0xFFF5F5DC), // 米色背景
    this.gridColor = const Color(0xFFE6E6C8), // 浅色网格线
    this.gridSize = 20.0, // 网格大小
    this.gridLineWidth = 1.0, // 网格线宽度
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: CustomPaint(
        painter: GridPainter(
          gridColor: gridColor,
          gridSize: gridSize,
          gridLineWidth: gridLineWidth,
        ),
        child: child,
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final Color gridColor;
  final double gridSize;
  final double gridLineWidth;

  GridPainter({
    required this.gridColor,
    required this.gridSize,
    required this.gridLineWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = gridColor
      ..strokeWidth = gridLineWidth;

    // 绘制水平线
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // 绘制垂直线
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // 网格背景不需要重绘
  }
}

// 带缓存的网格背景（优化性能）
class CachedGridBackground extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color gridColor;
  final double gridSize;
  final double gridLineWidth;

  const CachedGridBackground({
    Key? key,
    required this.child,
    this.backgroundColor = const Color(0xFFF5F5DC),
    this.gridColor = const Color(0xFFE6E6C8),
    this.gridSize = 20.0,
    this.gridLineWidth = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: GridPainter(
            gridColor: gridColor,
            gridSize: gridSize,
            gridLineWidth: gridLineWidth,
          ),
          isComplex: true, // 标记为复杂绘制，提高性能
          willChange: false, // 标记为不会改变，提高性能
          child: child,
        ),
      ),
    );
  }
}

// 像素网格背景（更符合像素风格）
class PixelGridBackground extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color gridColor;
  final double gridSize;

  const PixelGridBackground({
    Key? key,
    required this.child,
    this.backgroundColor = const Color(0xFFF5F5DC),
    this.gridColor = const Color(0xFFE6E6C8),
    this.gridSize = 15.0, // 像素网格通常更小
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: PixelGridPainter(
            gridColor: gridColor,
            gridSize: gridSize,
          ),
          isComplex: true,
          willChange: false,
          child: child,
        ),
      ),
    );
  }
}

class PixelGridPainter extends CustomPainter {
  final Color gridColor;
  final double gridSize;

  PixelGridPainter({
    required this.gridColor,
    required this.gridSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // 绘制像素风格网格
    for (double y = 0; y <= size.height; y += gridSize) {
      for (double x = 0; x <= size.width; x += gridSize) {
        canvas.drawRect(
          Rect.fromLTWH(x, y, gridSize, gridSize),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// 更高级的像素风格网格背景（添加噪点效果）
class EnhancedPixelGridBackground extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color gridColor;
  final Color noiseColor;
  final double gridSize;
  final double noiseDensity;

  const EnhancedPixelGridBackground({
    Key? key,
    required this.child,
    this.backgroundColor = const Color(0xFFF5F5DC),
    this.gridColor = const Color(0xFFE6E6C8),
    this.noiseColor = const Color(0x11000000), // 半透明黑色噪点
    this.gridSize = 15.0,
    this.noiseDensity = 0.05, // 噪点密度（0-1）
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: EnhancedPixelGridPainter(
            gridColor: gridColor,
            noiseColor: noiseColor,
            gridSize: gridSize,
            noiseDensity: noiseDensity,
          ),
          isComplex: true,
          willChange: false,
          child: child,
        ),
      ),
    );
  }
}

class EnhancedPixelGridPainter extends CustomPainter {
  final Color gridColor;
  final Color noiseColor;
  final double gridSize;
  final double noiseDensity;
  final Random _random = Random(DateTime.now().millisecondsSinceEpoch);

  EnhancedPixelGridPainter({
    required this.gridColor,
    required this.noiseColor,
    required this.gridSize,
    required this.noiseDensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制网格线
    final Paint gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // 绘制网格
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // 绘制噪点
    final Paint noisePaint = Paint()
      ..color = noiseColor
      ..style = PaintingStyle.fill;

    final int horizontalPoints = (size.width / gridSize).ceil();
    final int verticalPoints = (size.height / gridSize).ceil();

    for (int y = 0; y < verticalPoints; y++) {
      for (int x = 0; x < horizontalPoints; x++) {
        // 根据噪点密度决定是否绘制噪点
        if (_random.nextDouble() < noiseDensity) {
          final double noiseX = x * gridSize + _random.nextDouble() * gridSize;
          final double noiseY = y * gridSize + _random.nextDouble() * gridSize;
          final double noiseSize = 1.0 + _random.nextDouble() * 1.0;

          canvas.drawCircle(
            Offset(noiseX, noiseY),
            noiseSize,
            noisePaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}