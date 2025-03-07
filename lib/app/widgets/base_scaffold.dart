import 'package:flutter/material.dart';
import '../../core/widgets/grid_background.dart';
import '../../core/theme/app_theme.dart';

/// 基础页面脚手架，提供一致的页面结构和背景
class BaseScaffold extends StatelessWidget {
  final Widget? header;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Color backgroundColor;
  final Color gridColor;
  final double gridSize;
  final bool usePixelGrid;
  final bool enhanced;
  final bool useNoise;

  const BaseScaffold({
    Key? key,
    this.header,
    required this.body,
    this.bottomNavigationBar,
    this.backgroundColor = const Color(0xFFF5F5DC),
    this.gridColor = const Color(0xFFE6E6C8),
    this.gridSize = 20.0,
    this.usePixelGrid = true,
    this.enhanced = true,
    this.useNoise = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      children: [
        if (header != null) header!,
        Expanded(child: body),
      ],
    );

    // 选择适当的网格背景
    if (enhanced && usePixelGrid && useNoise) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: EnhancedPixelGridBackground(
            backgroundColor: backgroundColor,
            gridColor: gridColor,
            gridSize: gridSize,
            child: content,
          ),
        ),
        bottomNavigationBar: bottomNavigationBar,
      );
    } else if (usePixelGrid) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: PixelGridBackground(
            backgroundColor: backgroundColor,
            gridColor: gridColor,
            gridSize: gridSize,
            child: content,
          ),
        ),
        bottomNavigationBar: bottomNavigationBar,
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: CachedGridBackground(
            backgroundColor: backgroundColor,
            gridColor: gridColor,
            gridSize: gridSize,
            child: content,
          ),
        ),
        bottomNavigationBar: bottomNavigationBar,
      );
    }
  }
}
