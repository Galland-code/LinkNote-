import 'package:flutter/material.dart';

/// A container with pixel art style borders
class PixelContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const PixelContainer({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.width,
    this.height,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: borderRadius ?? BorderRadius.circular(20),
      ),
      padding: padding,
      child: child,
    );
  }
}
