import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/question_bank_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/pixel_card.dart';
import '../../../widgets/pixel_button.dart';
import '../../../routes/app_routes.dart';

class QuestionBankSourceView extends GetView<QuestionBankController> {
  @override
  Widget build(BuildContext context) {
    final String source = controller.selectedSource.value;

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
              _buildHeader(source),
              _buildStatistics(source),
              Expanded(
                child: _buildQuestionsList(source),
              ),
              _buildBackButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String source) {
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
          child: Text(
            source,
            style: AppTheme.titleStyle,
          ),
        ),
      ),
    );
  }

  Widget _buildStatistics(String source) {
    final questions = controller.getQuestionsBySource(source);
    final count = questions.length;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: PixelCard(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '错题数量',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '$count题',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            PixelButton(
              text: '开始练习',
              onPressed: () {
                // 启动针对该来源的练习
                Get.toNamed(Routes.QUIZ, arguments: {'source': source});
              },
              width: 120,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsList(String source) {
    final questions = controller.getQuestionsBySource(source);

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final question = questions[index];
        return _buildQuestionItem(question);
      },
    );
  }

  Widget _buildQuestionItem(question) {
    return GestureDetector(
      onTap: () {
        controller.viewQuestionDetail(question.id);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        child: PixelCard(
          backgroundColor: AppTheme.blueCardColor,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question.content,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Text(
                '正确答案: ${question.options[question.correctOptionIndex]}',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
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