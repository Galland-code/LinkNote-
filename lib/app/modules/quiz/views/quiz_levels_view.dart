// lib/app/modules/quiz/views/quiz_levels_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:linknote/core/extensions/context_extensions.dart';
import '../../../data/models/chaQuestion.dart';
import '../../../data/models/question.dart';
import '../../../routes/app_routes.dart';
import '../controllers/quiz_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/pixel_card.dart';
import '../../../widgets/pixel_button.dart';

class QuizLevelsView extends GetView<QuizController> {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> challenge = Get.arguments['challenge'];
    print(challenge);

    return Scaffold(
      body: SafeArea(
        child: context.withGridBackground(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildChallengeInfo(challenge),
                      SizedBox(height: 24),
                      _buildLevelsList(challenge),
                    ],
                  ),
                ),
              ),
              _buildBottomButtons(challenge),
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
                image: AssetImage('assets/images/pixel-title.png'), // 替换为你的图片路径
                fit: BoxFit.contain,
              ),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 8),
                  Text('挑战关卡', style: AppTheme.titleStyle),
                  SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildChallengeInfo(Map<String, dynamic> challenge) {
    return PixelCard(
      padding: EdgeInsets.all(20),
      backgroundColor: AppTheme.secondaryColor.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: AppTheme.secondaryColor),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  challenge['title'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.secondaryColor),
                ),
                child: Text(
                  '${challenge['completedCount']}/${challenge['questionCount']}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            '来源: 类别-${challenge['source']}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 4),
          Text(
            '创建日期: ${DateFormat('yyyy年MM月dd日').format(challenge['date'])}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 12),
          LinearProgressIndicator(
            value: challenge['questionCount'] > 0
                ? challenge['completedCount'] / challenge['questionCount']
                : 0,
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondaryColor),
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
          SizedBox(height: 8),
          Text(
            challenge['completedCount'] == challenge['questionCount']
                ? '挑战已完成!'
                : '继续挑战',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: challenge['completedCount'] == challenge['questionCount']
                  ? Colors.green
                  : AppTheme.secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelsList(Map<String, dynamic> challenge) {
    final List<chaQuestion> questions = List<chaQuestion>.from(challenge['questions']);
    final completedCount = challenge['completedCount'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '关卡列表',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: questions.length,
          itemBuilder: (context, index) {
            bool isCompleted = index < completedCount;
            bool isNext = index == completedCount;

            return GestureDetector(
              onTap: isNext || isCompleted
    ? () {
        controller.currentQuestionIndex.value = index;
        controller.isAnswered.value = false;
        controller.answer.value = '';
        // 传递整个 questions 列表和当前题目索引
        Get.toNamed(
          Routes.QUIZ_QUESTION,
          arguments: {
            'questions': questions,
            'currentIndex': index,
          },
        );
      }
    : null,
              child: Container(
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.withOpacity(0.8)
                      : (isNext ? AppTheme.primaryColor : Colors.grey.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                  boxShadow: isNext
                      ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    )
                  ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    (index + 1).toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomButtons(Map<String, dynamic> challenge) {
  final List<chaQuestion> questions = List<chaQuestion>.from(challenge['questions']);

    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: PixelButton(
              text: '返回',
              onPressed: () => Get.back(),
              backgroundColor: Colors.grey,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: PixelButton(
              text: challenge['completedCount'] == challenge['questionCount']
                  ? '重新开始'
                  : '继续挑战',
              onPressed: () {
                              int startIndex = 0;

                if (challenge['completedCount'] == challenge['questionCount']) {
                  // Reset challenge
                  challenge['completedCount'] = 0;
                  controller.currentQuestionIndex.value = 0;
                } else {
                                  startIndex = challenge['completedCount'];

                  controller.currentQuestionIndex.value = challenge['completedCount'];
                }

                controller.isAnswered.value = false;
                controller.answer.value = '';
Get.toNamed(
                Routes.QUIZ_QUESTION,
                arguments: {
                  'questions':questions,
                  'currentIndex': startIndex,
                },
              );              },
            ),
          ),
        ],
      ),
    );
  }
}