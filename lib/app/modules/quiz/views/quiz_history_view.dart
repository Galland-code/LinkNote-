import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/quiz_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/pixel_card.dart';
import '../../../widgets/pixel_button.dart';

class QuizHistoryView extends GetView<QuizController> {
  @override
  Widget build(BuildContext context) {
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
              Expanded(
                child: _buildHistoryList(),
              ),
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
          child: Text(
            '历史记录',
            style: AppTheme.titleStyle,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    // 这里应该从数据库获取历史记录
    // 暂时使用模拟数据
    List<Map<String, dynamic>> historyItems = [
      {
        'date': DateTime.now().subtract(Duration(days: 1)),
        'quizName': '计组复习测验',
        'score': 85.0,
        'questions': 20,
        'correctAnswers': 17,
      },
      {
        'date': DateTime.now().subtract(Duration(days: 3)),
        'quizName': 'RAG技术测验',
        'score': 90.0,
        'questions': 10,
        'correctAnswers': 9,
      },
      {
        'date': DateTime.now().subtract(Duration(days: 5)),
        'quizName': '测试理论测验',
        'score': 75.0,
        'questions': 12,
        'correctAnswers': 9,
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: historyItems.length,
      itemBuilder: (context, index) {
        final item = historyItems[index];
        return _buildHistoryItem(item);
      },
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    final Color scoreColor = item['score'] >= 80 ? Colors.green :
    item['score'] >= 60 ? Colors.orange :
    Colors.red;

    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: PixelCard(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['quizName'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: scoreColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: scoreColor),
                  ),
                  child: Text(
                    '${item['score']}分',
                    style: TextStyle(
                      color: scoreColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${DateFormat('yyyy年MM月dd日').format(item['date'])}',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '${item['correctAnswers']}/${item['questions']} 正确',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: item['correctAnswers'] / item['questions'],
              backgroundColor: Colors.grey[300],
              color: scoreColor,
              minHeight: 8,
            ),
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