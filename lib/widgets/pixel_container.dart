import 'package:flutter/material.dart';

class PixelContainer extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final BorderSide? borderSide;
  final double? width;
  final double? height;

  const PixelContainer({
    Key? key,
    required this.child,
    this.backgroundColor = Colors.transparent,
    this.padding = const EdgeInsets.all(0),
    this.margin = const EdgeInsets.all(0),
    this.borderRadius = 0,
    this.borderSide,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderSide != null
            ? Border.fromBorderSide(borderSide!)
            : null,
      ),
      child: child,
    );
  }
}