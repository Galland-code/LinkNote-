import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linknote/core/extensions/context_extensions.dart';
import '../../../widgets/animated_toast.dart';
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

            final currentQuestion =
                controller.questions[controller.currentQuestionIndex.value];

            return SingleChildScrollView(
              // Add scrollable functionality
              child: Column(
                children: [
                  _buildHeader(),
                  _buildProgressBar(),
                  _buildQuestionCard(currentQuestion),
                  _buildQuestionBasedOnType(currentQuestion), // 根据题目类型渲染不同内容
                  _buildNavigationButtons(),
                ],
              ),
            );
          }),
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
                  Text('答题中', style: AppTheme.titleStyle),
                  SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress =
        (controller.currentQuestionIndex.value + 1) /
        controller.questions.length;

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
                Text(
                  '来源: ${question.source}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
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

  // 根据题目类型渲染不同内容
  Widget _buildQuestionBasedOnType(question) {
    switch (question.type) {
      case '选择题':
        return _buildOptions(question); // 选择题渲染
      case '填空题':
        return _buildFillInBlank(question); // 填空题渲染
      case '简答题':
        return _buildShortAnswer(question); // 简答题渲染
      default:
        return SizedBox.shrink(); // 如果没有匹配到的类型，返回空
    }
  }

  // 渲染选择题
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

  // 渲染填空题
  Widget _buildFillInBlank(question) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: '请输入答案',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              controller.answer.value = value;
            },
          ),
          SizedBox(height: 16),
          if (controller.answer.value.isNotEmpty &&
              !controller.isAnswered.value)
            PixelButton(
              text: '确认提交',
              onPressed: () async {
                final result = await controller.answerFillInQuestion(
                  controller.answer.value,
                );
                _showResultDialog(result);
              },
            ),
        ],
      ),
    );
  }

  // 渲染简答题
  Widget _buildShortAnswer(question) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: '请输入简答题答案',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
            onChanged: (value) {
              controller.answer.value = value;
            },
          ),
          SizedBox(height: 16),
          if (controller.answer.value.isNotEmpty &&
              !controller.isAnswered.value)
            PixelButton(
              text: '确认提交',
              onPressed: () async {
                final result = await controller.answerShortQuestion(
                  controller.answer.value,
                );
                _showResultDialog(result);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTimer() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        '剩余时间: ${controller.timer.value}s',
        style: TextStyle(
          fontSize: 20,
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOptionItem(int index, String option, var question) {
    final isSelected = controller.answer.value == index.toString();
    final isAnswered = controller.isAnswered.value;
    print("选择选项：$option");
    // Remove correctOptionIndex check since we get correctness from backend
    final isCorrect =
        isAnswered && isSelected && controller.isAnswerCorrect.value;
    final isWrong = isAnswered && isSelected && !isCorrect;

    Color backgroundColor = Colors.white;
    if (isSelected) {
      backgroundColor =
          isCorrect
              ? Colors.green.shade200
              : isWrong
              ? Colors.red.shade200
              : Colors.blue.shade200;
    }

    return GestureDetector(
      onTap: () async {
        if (!controller.isAnswered.value) {
          controller.answer.value = index.toString();
          final result = await controller.answerQuestion(option);
          _showResultDialog(result);
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        child: PixelCard(
          backgroundColor: backgroundColor,
          padding: EdgeInsets.all(12),
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
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              if (isAnswered)
                Icon(
                  isCorrect
                      ? Icons.check_circle
                      : isWrong
                      ? Icons.cancel
                      : Icons.circle_outlined,
                  color:
                      isCorrect
                          ? Colors.green
                          : isWrong
                          ? Colors.red
                          : Colors.grey,
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

  void _showResultDialog(bool isCorrect) {
    // 简单用法
    if (!isCorrect ) {
      ResultDialog.show(isCorrect: true);
    }else{
    ResultDialog.show(
        isCorrect: false
    );}
  }
}
