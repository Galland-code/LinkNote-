import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linknote/core/extensions/context_extensions.dart';
import '../../../routes/app_routes.dart';
import '../controllers/quiz_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/pixel_button.dart';
import '../../../widgets/pixel_card.dart';

class QuizGenerateView extends GetView<QuizController> {
  final noteId = Get.arguments["documentId"];

  @override
  Widget build(BuildContext context) {
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
                      _buildInstruction(),
                      SizedBox(height: 16),
                      _buildInputField(),
                      SizedBox(height: 24),
                      _buildButtons(),
                    ],
                  ),
                ),
              ),
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
                  Text('生成题目', style: AppTheme.titleStyle),
                  SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstruction() {
    return Text(
      '请输入您希望生成的题目数量，系统将自动为您生成题目。',
      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: TextField(
        controller: TextEditingController(),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: '题目数量',
          hintText: '请输入题目数量',
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (value) {
          // 更新控制器中的题目数量
          controller.questionCount.value = int.tryParse(value) ?? 5;
        },
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        PixelButton(
          text: '生成题目',
          onPressed: () {
            // 提交请求生成题目
            controller.generateQuestionsForNote(
              noteId,
              controller.questionCount.value,
            );
            // 跳转到题目挑战界面
            Get.toNamed(Routes.QUIZ_CHALLENGE_SELECT);
          },
          backgroundColor: AppTheme.primaryColor,
        ),
        SizedBox(height: 16),
        PixelButton(
          text: '取消',
          onPressed: () {
            // 返回上一页
            Get.back();
          },
          backgroundColor: AppTheme.primaryColor,
        ),
      ],
    );
  }
}
