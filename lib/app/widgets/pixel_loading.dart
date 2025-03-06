import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// 像素风格的加载指示器
class PixelLoading extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const PixelLoading({
    Key? key,
    this.size = 50.0,
    this.color = const Color(0xFFB33856),
    this.duration = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  _PixelLoadingState createState() => _PixelLoadingState();
}

class _PixelLoadingState extends State<PixelLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _PixelLoadingPainter(
                progress: _controller.value,
                color: widget.color,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PixelLoadingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _PixelLoadingPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 创建像素化的方块作为加载动画
    final double blockSize = size.width / 5;
    final List<Offset> positions = [
      Offset(0, 0),
      Offset(blockSize * 2, 0),
      Offset(blockSize * 4, 0),
      Offset(blockSize * 4, blockSize * 2),
      Offset(blockSize * 4, blockSize * 4),
      Offset(blockSize * 2, blockSize * 4),
      Offset(0, blockSize * 4),
      Offset(0, blockSize * 2),
    ];

    final int targetIndex = (progress * positions.length).floor();

    for (int i = 0; i < positions.length; i++) {
      final opacity = i <= targetIndex ? 1.0 : 0.3;
      paint.color = color.withOpacity(opacity);
      canvas.drawRect(
        Rect.fromLTWH(
            positions[i].dx,
            positions[i].dy,
            blockSize,
            blockSize
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_PixelLoadingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
