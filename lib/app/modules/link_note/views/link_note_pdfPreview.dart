import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/pixel_card.dart';

class PdfPreviewView extends StatefulWidget {
  final String filePath;
  final String fileName;

  const PdfPreviewView({required this.filePath, required this.fileName});

  @override
  _PdfPreviewViewState createState() => _PdfPreviewViewState();
}

class _PdfPreviewViewState extends State<PdfPreviewView> {
  final TextEditingController _chatController = TextEditingController();
  final RxBool _isChatOpen = false.obs;
  final RxInt _currentPage = 1.obs;
  final RxInt _totalPages = 0.obs;
  final RxList<ChatMessage> _messages = <ChatMessage>[].obs;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 添加欢迎消息
    _messages.add(
      ChatMessage(
        text: "来和文档对话吧 ٩(˃̶͈̀௰˂̶͈́)و！我可以帮你理解这份PDF文档的内容，有什么问题请随时提问！",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
    });

    _chatController.clear();
    _scrollToBottom();

    // 模拟AI回复
    Future.delayed(Duration(milliseconds: 800), () {
      final aiResponse = _generateAIResponse(text);
      setState(() {
        _messages.add(
          ChatMessage(
            text: aiResponse,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
      _scrollToBottom();
    });
  }

  String _generateAIResponse(String userMessage) {
    // 这是一个简单的模拟回复，实际应用中应该调用AI API
    if (userMessage.toLowerCase().contains('页') ||
        userMessage.toLowerCase().contains('page')) {
      return "您正在查看第${_currentPage.value}页，PDF总共有${_totalPages.value}页。需要我为您解释这一页的内容吗？";
    } else if (userMessage.toLowerCase().contains('总结') ||
        userMessage.toLowerCase().contains('summary')) {
      return "这份PDF文档主要讨论了${widget.fileName.split('.').first}相关的内容。如果您需要特定章节的摘要，请告诉我具体的页码或章节名称。";
    } else if (userMessage.toLowerCase().contains('如何') ||
        userMessage.toLowerCase().contains('how')) {
      return "关于\"${userMessage}\"，基于文档内容，我建议您可以查看第${(_currentPage.value + 1 <= _totalPages.value) ? _currentPage.value + 1 : _currentPage.value}页，那里有相关说明。此外，您也可以尝试...";
    } else if (userMessage.contains('?') || userMessage.contains('？')) {
      return "很好的问题！根据我对文档的分析，${widget.fileName.split('.').first}相关的答案应该在第${_currentPage.value}页提到。如果没有找到您需要的信息，可以尝试告诉我更具体的问题。";
    } else {
      return "我已经理解您关于\"${userMessage}\"的意思了。如果您想了解文档的特定部分，可以告诉我页码或章节名称，我会提供更精确的解答。";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                _isChatOpen.value
                    ? Icons.chat_bubble
                    : Icons.chat_bubble_outline,
              ),
              onPressed: () => _isChatOpen.toggle(),
              tooltip: 'AI 对话',
            ),
          ),
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: Text('PDF信息'),
                  content: Obx(
                    () => Text(
                      '文件名: ${widget.fileName}\n总页数: ${_totalPages.value}\n当前页: ${_currentPage.value}',
                    ),
                  ),
                  actions: [
                    TextButton(child: Text('关闭'), onPressed: () => Get.back()),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // PDF视图
          PDFView(
            filePath: widget.filePath,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
            onError: (error) {
              Get.snackbar('错误', '无法打开 PDF: $error');
            },
            onPageError: (page, error) {
              Get.snackbar('错误', '第 $page 页加载失败: $error');
            },
            onPageChanged: (page, total) {
              _currentPage.value = page! + 1;
              _totalPages.value = total!;
            },
            onViewCreated: (controller) {
              // PDF视图创建完成的回调
            },
          ),

          // 页码指示器
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Obx(
                () => Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentPage.value} / ${_totalPages.value}',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),

          // AI聊天面板
          Obx(
            () => AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom:
                  _isChatOpen.value
                      ? 0
                      : -MediaQuery.of(context).size.height * 0.5 + 20,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.5,
              child: Container(
                margin: EdgeInsets.all(8),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: PixelCard(
                  margin: EdgeInsets.all(8),
                  padding: EdgeInsets.all(8),

                  child: Column(
                    children: [
                      // 聊天标题
                      Row(
                        children: [
                          Icon(Icons.smart_toy, color: AppTheme.primaryColor),
                          SizedBox(width: 8),
                          Text(
                            'AI 文档助手',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => _isChatOpen.value = false,
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        ],
                      ),

                      Divider(),

                      // 聊天消息区域
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(vertical: 8),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            return _buildChatBubble(message);
                          },
                        ),
                      ),

                      // 输入区域
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _chatController,
                                decoration: InputDecoration(
                                  hintText: '询问关于PDF内容的问题...',
                                  border: InputBorder.none,
                                ),
                                onSubmitted: _sendMessage,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.send,
                                color: AppTheme.primaryColor,
                              ),
                              onPressed:
                                  () => _sendMessage(_chatController.text),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    return Padding(
      padding: EdgeInsets.only(
        left: message.isUser ? 40 : 8,
        right: message.isUser ? 8 : 40,
        bottom: 8,
      ),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser)
            CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              radius: 16,
              child: Icon(Icons.smart_toy, size: 16, color: Colors.white),
            ),
          SizedBox(width: !message.isUser ? 8 : 0),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:
                    message.isUser
                        ? AppTheme.primaryColor.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      message.isUser
                          ? AppTheme.primaryColor.withOpacity(0.5)
                          : Colors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message.text, style: TextStyle(fontSize: 14)),
                  SizedBox(height: 4),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: message.isUser ? 8 : 0),
          if (message.isUser)
            CircleAvatar(
              backgroundColor: AppTheme.secondaryColor,
              radius: 16,
              child: Icon(Icons.person, size: 16, color: Colors.white),
            ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
