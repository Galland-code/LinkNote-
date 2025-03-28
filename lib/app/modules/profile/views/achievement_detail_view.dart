// lib/app/modules/achievements/views/achievement_detail_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:linknote/core/extensions/context_extensions.dart';
import '../../achievements/achievements_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/pixel_card.dart';
import '../../../widgets/pixel_button.dart';
import '../../../data/models/achievement.dart';

class AchievementDetailView extends GetView<AchievementsController> {
  @override
  Widget build(BuildContext context) {
    final Achievement achievement = Get.arguments['achievements'];

    return Scaffold(
      body: SafeArea(
        child: context.withGridBackground(
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
                  Text('成就详情', style: AppTheme.titleStyle),
                  SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
Widget _buildAchievementDetails(Achievement achievement) {
  return SingleChildScrollView(
    padding: EdgeInsets.all(20),
    child: Column(
      children: [
        // 成就图标和状态卡片
        PixelCard(
          backgroundColor: AppTheme.pinkCardColor,
          padding: EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: SvgPicture.asset(
                  achievement.iconPath,
                  width: 100,
                  height: 100,
                  colorFilter: achievement.isUnlocked
                      ? null
                      : ColorFilter.mode(Colors.grey.shade400, BlendMode.srcIn),
                ),
              ),
              SizedBox(height: 20),
              Text(
                achievement.title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: achievement.isUnlocked ? Colors.black : Colors.black45,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: achievement.isUnlocked 
                      ? Color(0xFFE8F5E9)  // 浅绿色背景
                      : Color(0xFFEEEEEE), // 浅灰色背景
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: achievement.isUnlocked 
                        ? Colors.green.shade300 
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: Text(
                  achievement.isUnlocked ? '已解锁' : '未解锁',
                  style: TextStyle(
                    color: achievement.isUnlocked 
                        ? Colors.green.shade700 
                        : Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (achievement.isUnlocked && achievement.unlockedAt != null) ...[
                SizedBox(height: 12),
                Text(
                  '解锁于 ${DateFormat('yyyy年MM月dd日').format(achievement.unlockedAt!)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),

        SizedBox(height: 24),

        // 描述和解锁条件合并卡片
        PixelCard(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 描述部分
              Row(
                children: [
                  Icon(Icons.description_outlined, 
                       color: AppTheme.primaryColor),
                  SizedBox(width: 8),
                  Text(
                    '成就描述',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),

              SizedBox(height: 24),
              Divider(color: Colors.grey.shade200),
              SizedBox(height: 24),

              // 解锁条件部分
              Row(
                children: [
                  Icon(Icons.lock_outline, 
                       color: AppTheme.primaryColor),
                  SizedBox(width: 8),
                  Text(
                    '解锁条件',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUnlockConditions(achievement),
                    if (!achievement.isUnlocked && 
                        achievement.title == '答题王') ...[
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '当前进度',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: 0.45,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.primaryColor),
                                minHeight: 12,
                              ),
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
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// 返回按钮美化
Widget _buildBackButton() {
  return Container(
    padding: EdgeInsets.all(16),
    child: PixelButton(
      text: '返回',
      onPressed: () => Get.back(),
      backgroundColor: AppTheme.primaryColor.withOpacity(0.8),
      width: 120,
      height: 45,
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

  // Widget _buildBackButton() {
  //   return Padding(
  //     padding: EdgeInsets.all(16),
  //     child: PixelButton(
  //       text: '返回',
  //       onPressed: () {
  //         Get.back();
  //       },
  //       backgroundColor: Colors.grey,
  //     ),
  //   );
  // }
}