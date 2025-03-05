import 'package:flutter/material.dart';

/// A card with pixel art style
class PixelCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final double? width;
  final BorderRadius? borderRadius;

  const PixelCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor = Colors.white,
    this.onTap,
    this.width,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        margin: margin ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: borderRadius ?? BorderRadius.circular(10),
        ),
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}