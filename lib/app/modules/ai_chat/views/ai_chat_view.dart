// lib/app/modules/ai_chat/views/ai_chat_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:linknote/core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/pixel_card.dart';
import '../controllers/ai_chat_controller.dart';

class AIChatView extends GetView<AIChatController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: context.withGridBackground(
          pixelStyle: true,
          enhanced: true,
          child: Column(
            children: [
              _buildHeader(context),
              _buildChatArea(),
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.9),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          SizedBox(width: 8),
          SvgPicture.asset('assets/icons/robot.svg', height: 36, width: 36),
          SizedBox(width: 12),
          Text(
            'AI 助手',
            style: AppTheme.titleStyle.copyWith(color: Colors.white),
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: Text('关于AI助手'),
                  content: Text('AI助手可以帮助你整理笔记、回答问题、提供学习建议等。尝试问一个问题吧！'),
                  actions: [
                    TextButton(onPressed: () => Get.back(), child: Text('了解了')),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    return Expanded(
      child: Obx(
        () => ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          reverse: true,
          itemCount: controller.chatMessages.length,
          itemBuilder: (context, index) {
            final reversedIndex = controller.chatMessages.length - 1 - index;
            final message = controller.chatMessages[reversedIndex];
            return _buildChatBubble(message);
          },
        ),
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    final isUserMessage = message.isUser;

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUserMessage) ...[
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SvgPicture.asset(
                'assets/icons/robot.svg',
                height: 40,
                width: 40,
              ),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isUserMessage
                        ? AppTheme.primaryColor.withOpacity(0.2)
                        : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isUserMessage ? '你' : 'AI助手',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              isUserMessage
                                  ? AppTheme.primaryColor
                                  : AppTheme.secondaryColor,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        DateFormat('HH:mm').format(message.timestamp),
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(message.text, style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
          if (isUserMessage) ...[
            SizedBox(width: 8),
            // 移除用户头像
            // Container(
            //   padding: EdgeInsets.all(8),
            //   decoration: BoxDecoration(
            //     color: Colors.transparent,
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: Icon(Icons.person, size: 40, color: AppTheme.primaryColor),
            // ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.textController,
              decoration: InputDecoration(
                hintText: '输入问题...',
                border: InputBorder.none,
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (text) {
                if (text.isNotEmpty) {
                  controller.sendMessage(text);
                }
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.mic, color: AppTheme.primaryColor),
            onPressed: () {
              controller.startVoiceInput();
            },
          ),
          IconButton(
            icon: Icon(Icons.send, color: AppTheme.primaryColor),
            onPressed: () {
              if (controller.textController.text.isNotEmpty) {
                controller.sendMessage(controller.textController.text);
              }
            },
          ),
        ],
      ),
    );
  }
}
