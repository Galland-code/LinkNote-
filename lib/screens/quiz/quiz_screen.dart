import 'package:flutter/material.dart';
import '../../widgets/pixel_button.dart';
import '../../widgets/pixel_container.dart';
import '../../widgets/pixel_navbar.dart';
import '../../widgets/pixel_text.dart';
import '../../themes/colors.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({Key? key}) : super(key: key);

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
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                child: const PixelText.heading(
                  'Quiz',
                  textAlign: TextAlign.center,
                ),
              ),

              // Book with pencil image
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Image.asset(
                      'assets/images/book_pencil.png',
                      width: 220,
                      height: 220,
                    ),
                  ),
                ),
              ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    PixelButton(
                      text: '继续答题',
                      onPressed: () {},
                      backgroundColor: AppColors.buttonBackground,
                    ),
                    const SizedBox(height: 16),
                    PixelButton(
                      text: '新的挑战',
                      onPressed: () {},
                      backgroundColor: AppColors.buttonBackground,
                    ),
                    const SizedBox(height: 16),
                    PixelButton(
                      text: '历史记录',
                      onPressed: () {},
                      backgroundColor: AppColors.buttonBackground,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Bottom navigation
              const PixelNavbar(currentIndex: 1),
            ],
          ),
        ),
      ),
    );
  }
}