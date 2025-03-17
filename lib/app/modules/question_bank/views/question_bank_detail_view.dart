import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:linknote/core/extensions/context_extensions.dart';
import '../controllers/question_bank_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/pixel_card.dart';
import '../../../widgets/pixel_button.dart';
import '../../../data/models/question.dart';

class QuestionBankDetailView extends GetView<QuestionBankController> {
  @override
  Widget build(BuildContext context) {
    final String questionId = Get.arguments['id'];
    final Question question = controller.questions.firstWhere(
      (q) => q.id == questionId,
      orElse: () => throw Exception('问题未找到'),
    );

    return Scaffold(
      body: SafeArea(
        child: context.withGridBackground(
          child: Column(
            children: [
              _buildHeader(),
              _buildQuestionCard(question),
              Expanded(child: _buildOptions(question)),
              _buildExplanation(question),
              _buildBackButton(),
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
        alignment: Alignment.centerRight,
        children: [
          Container(
            width: double.infinity,
            height: 60,
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
                  Text('问题详情', style: AppTheme.titleStyle),
                  SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Question question) {
    return Container(
      margin: EdgeInsets.all(16),
      child: PixelCard(
        backgroundColor: AppTheme.blueCardColor,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/coin.svg',
                  width: 24,
                  height: 24,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '来源: ${question.source}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Wrap(
              children: [
                Text(
                  question.content,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptions(Question question) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Column(
          children: List.generate(
            question.options?.length ?? 0,
            (index) =>
                _buildOptionItem(index, question.options![index], question),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionItem(int index, String option, Question question) {
    final isCorrect = question.correctOptionIndex == index.toString();

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: PixelCard(
        backgroundColor: isCorrect ? Colors.green.shade100 : Colors.white,
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCorrect ? Colors.green : Colors.grey[200],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1),
              ),
              alignment: Alignment.center,
              child: Text(
                '${String.fromCharCode(65 + index)}',
                style: TextStyle(
                  color: isCorrect ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            isCorrect
                ? Icon(Icons.check_circle, color: Colors.green)
                : Icon(Icons.cancel_outlined, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanation(Question question) {
    final String explanation =
        '解释: ${question.correctOptionIndex} 是正确答案，'
        '因为这是计算机科学中基础的知识点。在${question.source}中有详细讲解。';

    return Container(
      margin: EdgeInsets.all(16),
      child: PixelCard(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '解析',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(explanation, style: TextStyle(fontSize: 14, height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: PixelButton(
        text: '返回',
        onPressed: () {
          Get.back();
        },
        backgroundColor: Colors.grey,
      ),
    );
  }
}
