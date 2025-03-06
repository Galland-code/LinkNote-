import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// A reusable card widget with pixelated border style
class PixelCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderWidth;
  final BorderRadius borderRadius;

  const PixelCard({
    Key? key,
    required this.child,
    this.backgroundColor = Colors.white,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    this.borderWidth = 2,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        border: Border.all(
          color: Colors.black,
          width: borderWidth,
        ),
      ),
      padding: padding,
      child: child,
    );
  }
}
