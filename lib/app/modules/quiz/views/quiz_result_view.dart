import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/quiz_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/pixel_card.dart';
import '../../../widgets/pixel_button.dart';

class QuizResultView extends GetView<QuizController> {
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
              _buildResultCard(),
              _buildStatistics(),
              Spacer(),
              _buildButtons(),
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
            '挑战结果',
            style: AppTheme.titleStyle,
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final stats = controller.quizStats;
    final accuracy = double.parse(stats['accuracy'] ?? '0');

    String resultText = '太棒了！';
    String message = '你非常出色地完成了挑战！';

    if (accuracy < 60) {
      resultText = '继续努力！';
      message = '再多练习一下，你会做得更好！';
    } else if (accuracy < 80) {
      resultText = '做得不错！';
      message = '你已经掌握了大部分知识点！';
    }

    return Padding(
      padding: EdgeInsets.all(20),
      child: PixelCard(
        backgroundColor: AppTheme.primaryColor,
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Image.asset(
              accuracy >= 80 ? 'assets/images/trophy.png' :
              accuracy >= 60 ? 'assets/images/star.png' :
              'assets/images/thumbs_up.png',
              width: 64,
              height: 64,
            ),
            SizedBox(height: 16),
            Text(
              resultText,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    final stats = controller.quizStats;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '你的成绩',
            style: AppTheme.subtitleStyle,
          ),
          SizedBox(height: 12),
          PixelCard(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _buildStatItem('总题数', '${stats['totalAnswered']}题'),
                _buildStatItem('正确答题', '${stats['correctAnswers']}题'),
                _buildStatItem('正确率', '${stats['accuracy']}%'),
                _buildStatItem('连续正确', '${stats['consecutiveCorrect']}题'),
                _buildStatItem('错误率', '${stats['errorRate']}%'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          PixelButton(
            text: '再来一次',
            onPressed: () {
              controller.startNewChallenge();
            },
          ),
          SizedBox(height: 12),
          PixelButton(
            text: '返回首页',
            onPressed: () {
              Get.back();
            },
            backgroundColor: Colors.grey,
          ),
        ],
      ),
    );
  }
}