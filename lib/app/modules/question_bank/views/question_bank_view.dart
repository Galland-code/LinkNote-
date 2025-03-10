import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linknote/core/extensions/context_extensions.dart';
import '../controllers/question_bank_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/pixel_card.dart';

class QuestionBankView extends GetView<QuestionBankController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: context.withGridBackground(
          // Graph paper background pattern

          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuestionsList(),
                      _buildAnalysisSection(),
                    ],
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
            height: 80, // 根据需要调整高度
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/pixel-title.png'), // 替换为你的图片路径
                fit: BoxFit.contain,
              ),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 8),
                  Text(
                    '错题集',
                    style: AppTheme.titleStyle,
                  ),
                  SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsList() {
    return Obx(() => Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: controller.questions.map((question) => Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: PixelCard(
            backgroundColor: AppTheme.blueCardColor,
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset('assets/images/pencil.png', width: 24, height: 24),
                    SizedBox(width: 8),
                    Text(
                      '来源: ${question.source}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Q: ${question.content}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        )).toList(),
      ),
    ));
  }

  Widget _buildAnalysisSection() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Image.asset(
              'assets/images/study_character.png',
              height: 100,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Obx(() => PixelCard(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bar_chart),
                      SizedBox(width: 8),
                      Text(
                        '错题分析:',
                        style: AppTheme.subtitleStyle,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text('1. 待复习错题数: ${controller.questions.length}'),
                  SizedBox(height: 4),
                  ...controller.questionCounts.entries.map((entry) => Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text('2. "${entry.key}" 错题分析报告待查看'),
                  )).toList(),
                ],
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Obx(() => BottomNavBar(
      currentIndex: controller.currentNavIndex.value,
      onTap: (index) {
        controller.currentNavIndex.value = index;

        // Navigate based on index
        switch (index) {
          case 0:
            Get.offAllNamed(Routes.LINK_NOTE);
            break;
          case 1:
            Get.offAllNamed(Routes.QUIZ);
            break;
          case 2:
          // Already on question bank
            break;
          case 3:
            Get.offAllNamed(Routes.ACHIEVEMENTS);
            break;
        }
      },
    ));
  }
}

