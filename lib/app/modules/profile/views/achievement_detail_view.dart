// lib/app/modules/achievements/views/achievement_detail_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/achievements_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/pixel_card.dart';
import '../../../widgets/pixel_button.dart';
import '../../../data/models/achievement.dart';

class AchievementDetailView extends GetView<AchievementsController> {
  @override
  Widget build(BuildContext context) {
    final Achievement achievement = Get.arguments['achievement'];

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
                child: _buildAchievementDetails(achievement),
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
            '成就详情',
            style: AppTheme.titleStyle,
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementDetails(Achievement achievement) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // 成就图标和状态
          PixelCard(
            backgroundColor: AppTheme.pinkCardColor,
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                Image.asset(
                  achievement.iconPath,
                  width: 80,
                  height: 80,
                  color: achievement.isUnlocked ? null : Colors.black26,
                ),
                SizedBox(height: 16),
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: achievement.isUnlocked ? Colors.black : Colors.black45,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: achievement.isUnlocked ? Colors.green[100] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: achievement.isUnlocked ? Colors.green : Colors.grey,
                    ),
                  ),
                  child: Text(
                    achievement.isUnlocked ? '已解锁' : '未解锁',
                    style: TextStyle(
                      color: achievement.isUnlocked ? Colors.green[800] : Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (achievement.isUnlocked && achievement.unlockedAt != null) ...[
                  SizedBox(height: 8),
                  Text(
                    '解锁于 ${DateFormat('yyyy年MM月dd日').format(achievement.unlockedAt!)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
                if (achievement.value.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text(
                    achievement.value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: achievement.isUnlocked ? AppTheme.primaryColor : Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: 24),

          // 成就描述
          PixelCard(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '描述',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // 如何获取
          PixelCard(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '解锁条件',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                _buildUnlockConditions(achievement),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockConditions(Achievement achievement) {
    // 根据不同成就显示解锁条件
    String condition = '';

    switch (achievement.title) {
      case '连续完美无错':
        condition = '连续答对3组或更多题目，无错误。';
        break;
      case '连续登录':
        condition = '连续3天或更多登录应用。';
        break;
      case '答题王':
        condition = '累计回答100道题目。';
        break;
      case '关卡错误率':
        condition = '在答题过程中保持低于5%的错误率。';
        break;
      case 'NoGameNo Notebook':
        condition = '完成所有游戏化笔记任务。';
        break;
      default:
        condition = '完成特定任务以解锁此成就。';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          condition,
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
        SizedBox(height: 16),
        if (!achievement.isUnlocked && achievement.title == '答题王') ...[
          LinearProgressIndicator(
            value: 0.45, // 模拟进度
            backgroundColor: Colors.grey[300],
            color: AppTheme.primaryColor,
            minHeight: 10,
          ),
          SizedBox(height: 8),
          Text(
            '已完成: 45/100题',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
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