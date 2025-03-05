import 'package:flutter/material.dart';
import '../../core/models/mock_data.dart';
import '../../core/models/quiz_model.dart';
import '../widgets/pixel_container.dart';
import '../widgets/pixel_quiz_card.dart';
import '../widgets/pixel_title.dart';
import '../widgets/navigation_bar.dart';

/// Question bank screen that shows collection of quiz questions
class QuestionBankScreen extends StatefulWidget {
  const QuestionBankScreen({Key? key}) : super(key: key);

  @override
  State<QuestionBankScreen> createState() => _QuestionBankScreenState();
}

class _QuestionBankScreenState extends State<QuestionBankScreen> {
  final int _currentIndex = 2; // Current navigation index for question bank screen

  // Mock data for quiz questions
  late List<Quiz> _quizzes;
  late Map<String, dynamic> _analysis;

  @override
  void initState() {
    super.initState();
    // Load mock data
    _quizzes = MockData.getMockQuizzes();
    _analysis = MockData.getMockQuestionBankAnalysis();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background color to match design
      backgroundColor: const Color(0xFFFDF9ED),
      // App bar with title
      appBar: AppBar(
        title: const Text('错题集'),
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
                text: '错题集',
                backgroundColor: Colors.white,
              ),
            ),

            // Main content - grows to fill available space
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Question list - scrollable
                    Expanded(
                      child: PixelContainer(
                        backgroundColor: const Color(0xFFEBEFF5),
                        padding: const EdgeInsets.all(12),
                        child: ListView.builder(
                          itemCount: _quizzes.length,
                          itemBuilder: (context, index) {
                            return PixelQuizCard(
                              quiz: _quizzes[index],
                              onTap: () {
                                // Navigate to question detail
                                _showQuestionDetail(_quizzes[index]);
                              },
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Analysis section
                    Row(
                      children: [
                        // Person studying image
                        Expanded(
                          flex: 1,
                          child: Image.asset(
                            'assets/images/person_studying.png',
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        ),

                        // Analysis data
                        Expanded(
                          flex: 2,
                          child: PixelContainer(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Image.asset(
                                      'assets/icons/chart.png',
                                      width: 16,
                                      height: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      '错题分析:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('1. 待复习错题数: ${_analysis['totalQuestions']}'),
                                const SizedBox(height: 4),
                                Text(
                                  '2. 《计计组复习笔记》错题分析报告待查看',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                  ],
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
              Navigator.pushReplacementNamed(context, '/quiz');
              break;
            case 2:
            // Already on question bank screen
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/achievements');
              break;
          }
        },
      ),
    );
  }

  // Show question detail in a dialog
  void _showQuestionDetail(Quiz quiz) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('问题详情'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('来源: ${quiz.source}'),
            const SizedBox(height: 16),
            Text('问题: ${quiz.question}'),
            const SizedBox(height: 16),
            const Text('选项:'),
            ...List.generate(
              quiz.options.length,
                  (index) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Text('${String.fromCharCode(65 + index)}. '),
                    Expanded(child: Text(quiz.options[index])),
                    if (index == quiz.correctAnswer)
                      const Icon(Icons.check_circle, color: Colors.green),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
