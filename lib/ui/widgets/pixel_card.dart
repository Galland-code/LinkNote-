import 'package:flutter/material.dart';
import '../themes/colors.dart';

class PixelCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double? width;
  final double? height;

  const PixelCard({
    Key? key,
    required this.child,
    this.backgroundColor = AppColors.cardBackground,
    this.borderColor = AppColors.cardBorder,
    this.borderWidth = 2,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 8,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: padding,
      child: child,
    );
  }
}