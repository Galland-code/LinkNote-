import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            image: DecorationImage(
              image: AssetImage('assets/images/grid_background.png'),
              repeat: ImageRepeat.repeat,
            ),
          ),
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
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Text('问题详情', style: AppTheme.titleStyle),
        ),
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
            SizedBox(height: 16),
            Text(
              question.content,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
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
            question.options?.length ?? 0, // 确保安全访问
            (index) =>
                _buildOptionItem(index, question.options![index], question),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionItem(int index, String option, Question question) {
    final isCorrect = question.correctOptionIndex == index.toString(); // 确保正确比较

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
    // 实际项目中，问题应该包含解释字段
    // 这里使用模拟数据
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
