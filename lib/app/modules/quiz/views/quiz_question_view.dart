import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linknote/core/extensions/context_extensions.dart';
import '../controllers/quiz_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/pixel_card.dart';
import '../../../widgets/pixel_button.dart';

class QuizQuestionView extends GetView<QuizController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: context.withGridBackground(
          pixelStyle: true,
          enhanced: true,
          child: Obx(() {
            if (controller.questions.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }

            final currentQuestion = controller.questions[controller.currentQuestionIndex.value];

            return Column(
              children: [
                _buildHeader(),
                _buildProgressBar(),
                _buildQuestionCard(currentQuestion),
                _buildOptions(currentQuestion),
                Spacer(),
                _buildNavigationButtons(),
              ],
            );
          }),
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
          child: Text(
            '答题中...',
            style: AppTheme.titleStyle,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (controller.currentQuestionIndex.value + 1) / controller.questions.length;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '问题 ${controller.currentQuestionIndex.value + 1}/${controller.questions.length}',
            style: AppTheme.subtitleStyle,
          ),
          SizedBox(height: 4),
          Container(
            height: 10,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: FractionallySizedBox(
              widthFactor: progress,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(question) {
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

  Widget _buildOptions(question) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(
          question.options.length,
              (index) => _buildOptionItem(index, question.options[index], question),
        ),
      ),
    );
  }

  Widget _buildOptionItem(int index, String option, var question) {
    final isSelected = controller.selectedAnswerIndex.value == index;
    final isAnswered = controller.isAnswered.value;
    final isCorrect = isAnswered && question.correctOptionIndex == index;
    final isWrong = isAnswered && isSelected && !isCorrect;

    Color backgroundColor = Colors.white;
    if (isSelected) {
      backgroundColor = isCorrect ? Colors.green.shade200 :
      isWrong ? Colors.red.shade200 :
      Colors.blue.shade200;
    }

    return GestureDetector(
      onTap: () {
        if (!controller.isAnswered.value) {
          controller.answerQuestion(index);
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        child: PixelCard(
          backgroundColor: backgroundColor,
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.grey[200],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 1),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${String.fromCharCode(65 + index)}',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
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
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              if (isAnswered) Icon(
                isCorrect ? Icons.check_circle :
                isWrong ? Icons.cancel :
                Icons.circle_outlined,
                color: isCorrect ? Colors.green :
                isWrong ? Colors.red :
                Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PixelButton(
            text: '退出',
            onPressed: () {
              Get.back();
            },
            backgroundColor: Colors.grey,
            width: 100,
          ),
          if (controller.isAnswered.value)
            PixelButton(
              text: '下一题',
              onPressed: () {
                controller.nextQuestion();
              },
              width: 100,
            ),
        ],
      ),
    );
  }
}