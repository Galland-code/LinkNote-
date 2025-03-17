// lib/app/modules/quiz/views/quiz_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linknote/core/extensions/context_extensions.dart';
import '../controllers/quiz_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/pixel_button.dart';
import '../../../widgets/pixel_card.dart';

class QuizView extends GetView<QuizController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: context.withGridBackground(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
               children: [ _buildBookImage(),
                _buildButtons(),]
    ),
                ),
                ),
                _buildBottomNavBar(),
              ],
            ),
          ),

      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Stack(
        alignment: Alignment.centerRight, // 右对齐
        children: [
          Container(
            width: double.infinity,
            height: 70,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/pixel-title.png'),
                fit: BoxFit.contain,
              ),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 8),
                  Text('知识闯关', style: AppTheme.titleStyle),
                  SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookImage() {
    return Container(
      height: 200,
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Open book
          Image.asset('assets/images/pageWith.jpg', fit: BoxFit.contain),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PixelButton(
            text: '继续挑战',
            onPressed: () {
              // Navigate to challenge history to continue
              Get.toNamed(Routes.QUIZ_HISTORY);
            },
            backgroundColor: AppTheme.primaryColor,
          ),
          SizedBox(height: 16),
          PixelButton(
            text: '新的挑战',
            onPressed: () {
              // Navigate to challenge selection
              Get.toNamed(Routes.QUIZ_CHALLENGE_SELECT);
            },
            backgroundColor: AppTheme.primaryColor,
          ),
          SizedBox(height: 16),
          PixelButton(
            text: '试炼场ProMax',
            onPressed: () {
              // View history
              Get.toNamed(Routes.QUIZ_CHALLENGE);
            },
            backgroundColor: AppTheme.primaryColor,
          ),

          // Stats card
          SizedBox(height: 24),
          Obx(
            () => PixelCard(
              padding: EdgeInsets.all(16),
              backgroundColor: AppTheme.yellowCardColor,
              child: Column(
                children: [
                  Text(
                    '统计数据',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        '总答题数',
                        controller.quizStats['totalAnswered']?.toString() ??
                            '0',
                      ),
                      _buildStatItem(
                        '正确率',
                        '${controller.quizStats['accuracy'] ?? '0'}%',
                      ),
                      _buildStatItem(
                        '连续正确',
                        controller.quizStats['consecutiveCorrect']
                                ?.toString() ??
                            '0',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return Obx(
      () => BottomNavBar(
        currentIndex: controller.currentNavIndex.value,
        onTap: (index) {
          controller.currentNavIndex.value = index;

          // Navigate based on index
          switch (index) {
            case 0:
              Get.offAllNamed(Routes.LINK_NOTE);
              break;
            case 1:
              // Already on quiz
              break;
            case 2:
              Get.offAllNamed(Routes.QUESTION_BANK);
              break;
            case 3:
              Get.offAllNamed(Routes.PROFILE);
              break;
          }
        },
      ),
    );
  }
}
