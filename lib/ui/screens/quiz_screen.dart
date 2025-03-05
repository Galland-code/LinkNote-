import 'package:flutter/material.dart';
import '../../core/models/mock_data.dart';
import '../../core/models/quiz_model.dart';
import '../widgets/pixel_button.dart';
import '../widgets/pixel_container.dart';
import '../widgets/pixel_title.dart';
import '../widgets/navigation_bar.dart';

/// Quiz screen that shows the main quiz interface
class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final int _currentIndex = 1; // Current navigation index for quiz screen

  @override
  Widget build(BuildContext context) {
    // Get screen width to avoid fixed widths
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // Background color to match design
      backgroundColor: const Color(0xFFFDF9ED),
      // App bar with title
      appBar: AppBar(
        title: const Text('问关'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      // Main content
      body: SafeArea(
        child: Column(
          children: [
            // Title section
            Padding(
              padding: const EdgeInsets.all(16),
              child: PixelTitle(
                text: 'Quiz',
                backgroundColor: Colors.white,
              ),
            ),

            // Main content - grows to fill available space
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Book and pencil image
                      Center(
                        child: Image.asset(
                          'assets/images/book_pencil.png',
                          width: screenWidth * 0.6, // Responsive width
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Continue quiz button
                      PixelButton(
                        text: '继续答题',
                        onPressed: () {
                          // Navigate to continue quiz
                          Navigator.pushNamed(context, '/continue_quiz');
                        },
                      ),

                      const SizedBox(height: 16),

                      // New challenge button
                      PixelButton(
                        text: '新的挑战',
                        onPressed: () {
                          // Navigate to new challenge
                          Navigator.pushNamed(context, '/new_challenge');
                        },
                      ),

                      const SizedBox(height: 16),

                      // History records button
                      PixelButton(
                        text: '历史记录',
                        onPressed: () {
                          // Navigate to history records
                          Navigator.pushNamed(context, '/history_records');
                        },
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom navigation bar - floating
      bottomNavigationBar: PixelBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          // Handle navigation
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
            // Already on quiz screen
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/question_bank');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/achievements');
              break;
          }
        },
      ),
    );
  }
}
