import 'package:flutter/material.dart';
import '../../models/quiz_model.dart';
import '../../widgets/pixel_button.dart';
import '../../widgets/pixel_card.dart';
import '../../widgets/pixel_container.dart';
import '../../widgets/pixel_text.dart';
import '../../themes/colors.dart';

class QuizDetailScreen extends StatefulWidget {
  final QuizQuestion question;

  const QuizDetailScreen({
    Key? key,
    required this.question,
  }) : super(key: key);

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  int? selectedOptionIndex;
  bool hasSubmitted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/grid_paper.png'),
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: const Icon(Icons.arrow_back),
                      ),
                    ),
                    const Expanded(
                      child: PixelText.heading(
                        'Quiz',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              // Question card
              Padding(
                padding: const EdgeInsets.all(16),
                child: PixelCard(
                  backgroundColor: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PixelText.subheading('Question:'),
                      const SizedBox(height: 8),
                      PixelText.body(widget.question.question),
                      const SizedBox(height: 16),
                      const PixelText.subheading('Options:'),
                      const SizedBox(height: 8),
                      ...List.generate(
                        widget.question.options.length,
                            (index) => _buildOptionItem(index),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Submit button
              Padding(
                padding: const EdgeInsets.all(16),
                child: PixelButton(
                  text: hasSubmitted ? 'Next Question' : 'Submit Answer',
                  onPressed: () {
                    if (!hasSubmitted && selectedOptionIndex != null) {
                      setState(() {
                        hasSubmitted = true;
                      });
                    } else if (hasSubmitted) {
                      Navigator.pop(context);
                    }
                  },
                  backgroundColor: hasSubmitted
                      ? AppColors.primary
                      : selectedOptionIndex == null
                      ? Colors.grey
                      : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionItem(int index) {
    final bool isSelected = selectedOptionIndex == index;
    final bool isCorrect = widget.question.correctOptionIndex == index;

    Color backgroundColor = Colors.white;
    Color borderColor = Colors.black;

    if (hasSubmitted) {
      if (isCorrect) {
        backgroundColor = Colors.green.shade100;
        borderColor = Colors.green;
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red.shade100;
        borderColor = Colors.red;
      }
    } else if (isSelected) {
      backgroundColor = AppColors.secondary.withOpacity(0.2);
      borderColor = AppColors.secondary;
    }

    return GestureDetector(
      onTap: hasSubmitted
          ? null
          : () {
        setState(() {
          selectedOptionIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            PixelText.body('${String.fromCharCode(65 + index)}. '),
            Expanded(
              child: PixelText.body(widget.question.options[index]),
            ),
            if (hasSubmitted && isCorrect)
              const Icon(Icons.check_circle, color: Colors.green),
            if (hasSubmitted && isSelected && !isCorrect)
              const Icon(Icons.cancel, color: Colors.red),
          ],
        ),
      ),
    );
  }
}