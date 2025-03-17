import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();
}

class AIChatController extends GetxController {
  final TextEditingController textController = TextEditingController();
  final RxList<ChatMessage> chatMessages = <ChatMessage>[].obs;
  final RxBool isTyping = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 添加默认欢迎消息
    chatMessages.add(
      ChatMessage(
        text: '你好！我是LinkNote的AI助手🤖。我可以帮你整理笔记、回答问题或提供学习建议。请问有什么我可以帮助你的？',
        isUser: false,
      ),
    );
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    // 添加用户消息
    chatMessages.add(ChatMessage(text: text, isUser: true));

    // 清空输入框
    textController.clear();

    // 模拟AI正在输入
    isTyping.value = true;

    // 模拟AI响应（实际应用中这里会调用AI API）
    Future.delayed(Duration(milliseconds: 500), () {
      _generateAIResponse(text);
    });
  }

  void _generateAIResponse(String userMessage) {
    String aiResponse;

    if (userMessage.toLowerCase().contains('笔记') ||
        userMessage.toLowerCase().contains('note')) {
      aiResponse = '你可以点击主页右上角的+按钮创建新笔记📓，或者通过分类查看已有笔记📚。需要我帮你整理某个主题的笔记吗？😊';
    } else if (userMessage.toLowerCase().contains('pdf')) {
      aiResponse = '你可以在分类页面上传PDF文档📄，或者通过长按笔记将其导出为PDF。需要我帮你管理PDF文档吗？😄';
    } else if (userMessage.toLowerCase().contains('分类') ||
        userMessage.toLowerCase().contains('category')) {
      aiResponse =
          'LinkNote支持按分类整理你的笔记和PDF文档，便于查找和管理🗂️。你可以在创建笔记时设置分类，也可以后续修改哦！✨';
    } else if (userMessage.contains('?') || userMessage.contains('？')) {
      aiResponse =
          '这是一个很好的问题！🤔 基于我的理解，我认为可以这样解答：首先考虑问题的核心是什么，然后从不同角度分析。你可以尝试在笔记中记录下你的思考过程，这样有助于梳理思路。💡';
    } else if (userMessage.toLowerCase().contains('谢谢') ||
        userMessage.toLowerCase().contains('thank')) {
      aiResponse = '不客气 如果还有其他问题，随时可以问我哦！祝你使用LinkNote愉快！🎉';
    } else {
      aiResponse =
          '我理解你的意思了！作为LinkNote的AI助手，我可以帮你管理笔记、回答问题或提供学习建议。你可以尝试问我关于笔记管理、PDF文档或学习方法的问题哦！😊';
    }

    // 添加AI响应
    Future.delayed(Duration(seconds: 1), () {
      isTyping.value = false;
      chatMessages.add(ChatMessage(text: aiResponse, isUser: false));
    });
  }

  void startVoiceInput() {
    // 这里实现语音输入功能
    Get.snackbar('语音输入', '语音输入功能正在开发中...', snackPosition: SnackPosition.BOTTOM);
  }
}
