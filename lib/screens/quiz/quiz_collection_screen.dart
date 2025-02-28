import 'package:flutter/material.dart';
import '../../models/quiz_model.dart';
import '../../widgets/pixel_card.dart';
import '../../widgets/pixel_container.dart';
import '../../widgets/pixel_navbar.dart';
import '../../widgets/pixel_text.dart';
import '../../themes/colors.dart';

class QuizCollectionScreen extends StatelessWidget {
  const QuizCollectionScreen({Key? key}) : super(key: key);

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
                  '错题集',
                  textAlign: TextAlign.center,
                ),
              ),

              // Collections list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sampleQuizCollections.length + 1,
                  itemBuilder: (context, index) {
                    if (index == sampleQuizCollections.length) {
                      return _buildAnalysisCard();
                    }
                    final collection = sampleQuizCollections[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildCollectionCard(collection),
                    );
                  },
                ),
              ),

              // Bottom navigation
              const PixelNavbar(currentIndex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollectionCard(QuizCollection collection) {
    return PixelCard(
      backgroundColor: AppColors.secondary.withOpacity(0.8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/icons/pencil.png',
                width: 24,
                height: 24,
                color: Colors.yellow,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PixelText.body(
                  '来源: ${collection.source}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          PixelText.body(
            'Q: ${collection.questions.first.question}',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: PixelCard(
              backgroundColor: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/computer.png',
                    width: 80,
                    height: 80,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: PixelCard(
              backgroundColor: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/icons/chart.png',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 8),
                      const PixelText.subheading('错题分析:'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const PixelText.body('1. 待复习错题数: 5'),
                  const SizedBox(height: 4),
                  const PixelText.body('2. 《计组复习笔记》错题分析报告待查看'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}