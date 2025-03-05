import 'package:flutter/material.dart';

/// A custom bottom navigation bar with pixel art style
class PixelBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  /// List of navigation items
  final List<BottomNavigationBarItem> items = [
    const BottomNavigationBarItem(
      icon: ImageIcon(AssetImage('assets/icons/book.png')),
      label: '笔记库',
    ),
    const BottomNavigationBarItem(
      icon: ImageIcon(AssetImage('assets/icons/sword.png')),
      label: '问关',
    ),
    const BottomNavigationBarItem(
      icon: ImageIcon(AssetImage('assets/icons/note.png')),
      label: '错题集',
    ),
    const BottomNavigationBarItem(
      icon: ImageIcon(AssetImage('assets/icons/trophy.png')),
      label: '成就',
    ),
  ];

  PixelBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        items: items,
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
      ),
    );
  }
}
