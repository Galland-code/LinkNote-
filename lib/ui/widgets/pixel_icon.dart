import 'package:flutter/material.dart';

class PixelIcon extends StatelessWidget {
  final String assetPath;
  final double size;
  final Color? color;

  const PixelIcon({
    Key? key,
    required this.assetPath,
    this.size = 24,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      color: color,
    );
  }
}

class PixelIconData {
  static const String notebook = 'assets/icons/notebook.png';
  static const String sword = 'assets/icons/sword.png';
  static const String trophy = 'assets/icons/trophy.png';
  static const String pencil = 'assets/icons/pencil.png';
  static const String book = 'assets/icons/book.png';

  // Prevent instantiation
  PixelIconData._();
}