import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/pixel_card.dart';
import '../../../widgets/pixel_button.dart';

class AchievementsView extends GetView<ProfileController> {
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
                child: _buildAchievementsList(),
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
            '成就列表',
            style: AppTheme.titleStyle,
          ),
        ),
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
              PixelCard(
                padding: EdgeInsets.all(16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: unlockedAchievements.length,
                  itemBuilder: (context, index) {
                    final achievement = unlockedAchievements[index];
                    return GestureDetector(
                      onTap: () => controller.navigateToAchievementDetail(achievement),
                      child: Column(
                        children: [
                          Image.asset(
                            achievement.iconPath,
                            width: 40,
                            height: 40,
                          ),
                          SizedBox(height: 4),
                          Text(
                            achievement.title,
                            style: TextStyle(
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
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
              ...inProgressAchievements.map((achievement) =>
                  Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: PixelCard(
                      padding: EdgeInsets.all(16),
                      child: GestureDetector(
                        onTap: () => controller.navigateToAchievementDetail(achievement),
                        child: Row(
                          children: [
                            Image.asset(
                              achievement.iconPath,
                              width: 40,
                              height: 40,
                              color: Colors.grey[400],
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
                                      achievement.description!.isNotEmpty) ...[
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
                                    value: _getAchievementProgress(achievement),
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
                  )
              ).toList(),
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
