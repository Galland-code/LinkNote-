// lib/app/modules/quiz/views/quiz_qna_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linknote/core/extensions/context_extensions.dart';
import '../../../widgets/pixel_card.dart';
import '../controllers/quiz_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/pixel_button.dart';

class QuizQnaView extends StatefulWidget {
  @override
  _QuizQnaViewState createState() => _QuizQnaViewState();
}

class _QuizQnaViewState extends State<QuizQnaView> {
  final QuizController controller = Get.find<QuizController>();
  final TextEditingController answerController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    answerController.dispose(); // 清理 TextEditingController
    _focusNode.dispose(); // 清理 FocusNode
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // 确保键盘弹出时调整布局
      body: SafeArea(
        child: context.withGridBackground(
          child: Obx(() => Column(
            children: [
              _buildHeader(),
              _buildQuestionCard(), // 这里调用修改后的方法
              Expanded(child: _buildConversation()),
              _buildInputArea(),
            ],
          )),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child:           Container(
          width: double.infinity,
          height: 80,
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
                Text('试炼场PM', style: AppTheme.titleStyle),
                SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black, // 深色背景增强对比
        border: Border.all(
          color: AppTheme.primaryColor, // 使用主题主色
          width: 4, // 粗边框
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.5), // 光晕效果
            blurRadius: 8,
            spreadRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 挑战图标
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              border: Border.all(color: Colors.white, width: 2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_fire_department, // 火炬图标
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 12),
          // 问题文本
          Expanded(
            child: Text(
              controller.currentQnaQuestion.value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'PixelFont',
                letterSpacing: 1.2, // 增加字符间距
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversation() {
    return ListView.builder(
      physics: ClampingScrollPhysics(), // 减少焦点干扰
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: controller.qnaConversation.length,
      itemBuilder: (context, index) {
        final message = controller.qnaConversation[index];
        final isUser = message['isUser'] as bool;
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.only(bottom: 8),
            constraints: BoxConstraints(maxWidth: Get.width * 0.75),
            child: PixelCard(
              backgroundColor: isUser ? AppTheme.primaryColor : Colors.white,
              padding: EdgeInsets.all(12),
              child: Text(
                message['text'] as String,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: answerController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: '输入你的回答...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            maxLines: 3,
            onTap: () {
              _focusNode.requestFocus(); // 点击时保持焦点
            },
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: PixelButton(
                  text: '提交回答',
                  onPressed: () {
                    if (answerController.text.trim().isNotEmpty) {
                      controller.submitQnaAnswer(answerController.text);
                      answerController.clear();
                    }
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: PixelButton(
                  text: '返回',
                  backgroundColor: Colors.grey,
                  onPressed: () {
                    FocusScope.of(context).unfocus(); // 返回时收起键盘
                    Get.back();
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(child: PixelButton(
                text: '收起键盘',
                onPressed: () => FocusScope.of(Get.context!).unfocus(),
              ))
            ],
          ),
        ],
      ),
    );
  }
}