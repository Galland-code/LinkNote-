import 'package:flutter/material.dart';
import '../../core/models/quiz_model.dart';

/// A card that displays quiz information
class PixelQuizCard extends StatelessWidget {
  final Quiz quiz;
  final VoidCallback? onTap;

  const PixelQuizCard({
    Key? key,
    required this.quiz,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF7AA2E0),
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/icons/pencil.png',
                  width: 16,
                  height: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '来源: ${quiz.source}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Q: ${quiz.question}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
