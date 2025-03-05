import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/profile_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/pixel_card.dart';
import '../../../widgets/pixel_button.dart';
import '../../../data/models/achievement.dart';

class AchievementDetailView extends GetView<ProfileController> {
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
          // 成就图标和基本信息
          PixelCard(
            backgroundColor: achievement.isUnlocked ? AppTheme.pinkCardColor : Colors.grey[200],
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                // 图标
                Image.asset(
                  achievement.iconPath,
                  width: 80,
                  height: 80,
                  color: achievement.isUnlocked ? null : Colors.grey[400],
                ),
                SizedBox(height: 16),

                // 标题
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: achievement.isUnlocked ? Colors.black : Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),

                // 解锁状态
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

                // 解锁时间
                if (achievement.isUnlocked && achievement.unlockedAt != null) ...[
                  SizedBox(height: 8),
                  Text(
                    '解锁于 ${DateFormat('yyyy年MM月dd日 HH:mm').format(achievement.unlockedAt!)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],

                // 进度值
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
                  achievement.description ?? '暂无描述',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // 解锁条件
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

          if (!achievement.isUnlocked) ...[
            SizedBox(height: 24),

            // 进度条
            PixelCard(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '进度',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: _getAchievementProgress(achievement),
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      achievement.value,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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

    return Text(
      condition,
      style: TextStyle(
        fontSize: 16,
        height: 1.5,
      ),
    );
  }

  // 获取成就进度
  double _getAchievementProgress(Achievement achievement) {
    if (achievement.value.isEmpty) return 0.0;

    try {
      if (achievement.value.contains('/')) {
        final parts = achievement.value.split('/');
        final current = double.parse(parts[0