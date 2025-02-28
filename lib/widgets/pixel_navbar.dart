import 'package:flutter/material.dart';
import '../routes.dart';
import '../themes/colors.dart';

class PixelNavbar extends StatelessWidget {
  final int currentIndex;

  const PixelNavbar({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.black, width: 2),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
              context,
              'assets/icons/notebooks.svg',
              '笔记库',
              0,
                  () => Navigator.pushReplacementNamed(context, AppRoutes.notes)
          ),
          _buildNavItem(
              context,
              'assets/icons/sword.svg',
              '问关',
              1,
                  () => Navigator.pushReplacementNamed(context, AppRoutes.quiz)
          ),
          _buildNavItem(
              context,
              'assets/icons/note.svg',
              '错题集',
              2,
                  () => Navigator.pushReplacementNamed(context, AppRoutes.quizCollection)
          ),
          _buildNavItem(
              context,
              'assets/icons/trophy.svg',
              '成就',
              3,
                  () => Navigator.pushReplacementNamed(context, AppRoutes.achievements)
          ),
        ],
      ),
    );
  }
  Widget _buildNavItem(
      BuildContext context,
      String iconPath,
      String label,
      int index,
      VoidCallback onTap
      ) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black, width: 1),
        )
            : null,
        child: Row(
          children: [
            Image.asset(
              iconPath,
              width: 24,
              height: 24,
              color: isSelected ? Colors.black : Colors.grey,
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}