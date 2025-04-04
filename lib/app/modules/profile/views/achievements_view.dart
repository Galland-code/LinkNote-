import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:linknote/core/extensions/context_extensions.dart';
import '../controllers/profile_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/pixel_card.dart';
import '../../../widgets/pixel_button.dart';

class AchievementsView extends GetView<ProfileController> {
  const AchievementsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: context.withGridBackground(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildAchievementsList()),
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
                  Text('成就列表', style: AppTheme.titleStyle),
                  SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsList() {
    return Obx(() {
      final unlockedAchievements = controller.getUnlockedAchievements();
      final inProgressAchievements = controller.getInProgressAchievements();

      return SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 已解锁成就
if (unlockedAchievements.isNotEmpty) ...[
  Padding(
    padding: EdgeInsets.only(left: 8, bottom: 8),
    child: Text(
      '已解锁 (${unlockedAchievements.length})',
      style: AppTheme.subtitleStyle,
    ),
  ),
  Wrap(
    spacing: 12, // 水平间距
    runSpacing: 16, // 垂直间距
    children: unlockedAchievements.map((achievement) {
      return GestureDetector(
        onTap: () => controller.navigateToAchievementDetail(achievement),
        child: Container(
          width: 70, // 固定宽度
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                child: SvgPicture.asset(
                  achievement.iconPath.endsWith('.svg')
                      ? achievement.iconPath
                      : '${achievement.iconPath}.svg',
                  width: 60,
                  height: 60,
                  colorFilter: achievement.isUnlocked
                      ? null
                      : ColorFilter.mode(
                          Colors.grey.shade400,
                          BlendMode.srcIn,
                        ),
                ),
              ),
              SizedBox(height: 4),
              Text(
                achievement.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }).toList(),
  ),
  SizedBox(height: 24),
],
            // 进行中成就
            if (inProgressAchievements.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.only(left: 8, bottom: 8),
                child: Text(
                  '进行中 (${inProgressAchievements.length})',
                  style: AppTheme.subtitleStyle,
                ),
              ),
              ...inProgressAchievements
                  .map(
                    (achievement) => Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: PixelCard(
                        padding: EdgeInsets.all(16),
                        child: GestureDetector(
                          onTap:
                              () => controller.navigateToAchievementDetail(
                                achievement,
                              ),
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                achievement.iconPath.endsWith('.svg')
                                    ? achievement.iconPath
                                    : '${achievement.iconPath}.svg',
                                width: 40,
                                height: 40,
                                colorFilter: ColorFilter.mode(
                                  Colors.grey[400]!,
                                  BlendMode.srcIn,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      achievement.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (achievement.description != null &&
                                        achievement
                                            .description!
                                            .isNotEmpty) ...[
                                      SizedBox(height: 4),
                                      Text(
                                        achievement.description!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                    SizedBox(height: 8),
                                    LinearProgressIndicator(
                                      value: _getAchievementProgress(
                                        achievement,
                                      ),
                                      backgroundColor: Colors.grey[300],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppTheme.primaryColor,
                                      ),
                                      minHeight: 6,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    SizedBox(height: 4),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        achievement.value,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ],
          ],
        ),
      );
    });
  }

  // 获取成就进度
  double _getAchievementProgress(achievement) {
    if (achievement.value.isEmpty) return 0.0;

    try {
      if (achievement.value.contains('/')) {
        final parts = achievement.value.split('/');
        final current = double.parse(parts[0]);
        final total = double.parse(parts[1]);
        return current / total;
      }

      // 百分比情况
      if (achievement.value.contains('%')) {
        final percentage = double.parse(achievement.value.replaceAll('%', ''));
        return percentage / 100;
      }

      return 0.5; // 默认进度
    } catch (e) {
      return 0.0;
    }
  }

  Widget _buildBackButton() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: PixelButton(
        text: '返回',
        onPressed: () => Get.back(),
        backgroundColor: Colors.grey,
        width: double.infinity,
      ),
    );
  }
}
