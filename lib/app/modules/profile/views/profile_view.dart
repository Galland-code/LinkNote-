import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:linknote/core/extensions/context_extensions.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../data/models/achievement.dart';
import '../controllers/profile_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/pixel_card.dart';
import '../../../widgets/pixel_button.dart';
import '../../../widgets/pixel_loading.dart';
import '../../../data/models/avatar_data.dart';

class ProfileView extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: context.withGridBackground(
          child: Obx(() {
            if (controller.isLoading.value) {
              return Center(child: PixelLoading());
            }

            return Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildProfileSection(),
                        _buildDailyTasksSection(),
                        _buildAchievementSection(),
                      ],
                    ),
                  ),
                ),
                _buildBottomNavBar(),
              ],
            );
          }),
        ),
      ),
    );
  }

  // 标题
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Stack(
        alignment: Alignment.centerRight, // 右对齐
        children: [
          Container(
            width: double.infinity,
            height: 80,
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
                  Text('个人中心', style: AppTheme.titleStyle),
                  SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: PixelCard(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // 头像 - Updated to match RegisterView implementation
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryColor, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  AvatarData.avatars[controller.selectedAvatarIndex.value],
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 16),
            // Rest of the section remains the same...
          ],
        ),
      ),
    );
  }
  // 每日任务
  Widget _buildDailyTasksSection() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 8, bottom: 8),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 30),
                SizedBox(width: 4),
                Text('今日任务', style: AppTheme.subtitleStyle),
                Spacer(),
                Text(
                  controller.getFormattedDate(),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          PixelCard(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // 任务进度
                Row(
                  children: [
                    CircularPercentIndicator(
                      radius: 30.0,
                      lineWidth: 8.0,
                      percent: controller.getTaskCompletionPercentage() / 100,
                      center: Text(
                        "${controller.completedTasksCount}/${controller.dailyTasks.length}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      progressColor: AppTheme.primaryColor,
                      backgroundColor: Colors.grey[300]!,
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '今日获得 ${controller.getTodayExperiencePoints()} 经验',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '完成更多任务提升等级',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // 任务列表
                ...controller.dailyTasks
                    .map((task) => _buildTaskItem(task))
                    .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(task) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // 复选框
          GestureDetector(
            onTap: () => controller.toggleTaskCompletion(task.id),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color:
                    task.isCompleted
                        ? AppTheme.primaryColor
                        : Colors.transparent,
                border: Border.all(
                  color: task.isCompleted ? AppTheme.primaryColor : Colors.grey,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child:
                  task.isCompleted
                      ? Icon(Icons.check, color: Colors.white, size: 30)
                      : null,
            ),
          ),
          SizedBox(width: 12),
          // 任务内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    decoration:
                        task.isCompleted ? TextDecoration.lineThrough : null,
                    color: task.isCompleted ? Colors.grey : Colors.black,
                  ),
                ),
                if (task.description != null && task.description!.isNotEmpty)
                  Text(
                    task.description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      decoration:
                          task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
              ],
            ),
          ),
          // 经验点数
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: task.isCompleted ? Colors.green[100] : Colors.amber[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: task.isCompleted ? Colors.green : Colors.amber,
                width: 1,
              ),
            ),
            child: Text(
              '+${task.points}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: task.isCompleted ? Colors.green[800] : Colors.amber[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementSection() {
    final unlockedAchievements = controller.getUnlockedAchievements();
    print(unlockedAchievements);
    final inProgressAchievements =
        controller.getInProgressAchievements().take(3).toList(); // 只显示3个进行中成就
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 8, bottom: 8),
            child: Row(
              children: [
                Icon(Icons.emoji_events, size: 28),
                SizedBox(width: 8),
                Text('成就', style: AppTheme.subtitleStyle),
                Spacer(),
                GestureDetector(
                  onTap: () => Get.toNamed(Routes.PROFILE_ACHIEVEMENTS),
                  child: Text(
                    '查看全部 >',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 最近解锁的成就
          if (unlockedAchievements.isNotEmpty) ...[
            PixelCard(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('最近解锁', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Row(
                    children:
                        unlockedAchievements
                            .take(3)
                            .map(
                              (achievement) => Expanded(
                                child: GestureDetector(
                                  onTap:
                                      () => controller
                                          .navigateToAchievementDetail(
                                            achievement,
                                          ),
                                  child: Column(
                                    children: [
                                      SvgPicture.asset(
                                        achievement.iconPath,
                                        width: 40,
                                        height: 40,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        achievement.title,
                                        style: TextStyle(fontSize: 12),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],
          // 进行中的成就
          if (inProgressAchievements.isNotEmpty)
            PixelCard(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('进行中', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  ...inProgressAchievements
                      .map(
                        (achievement) => Container(
                          margin: EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap:
                                () => controller.navigateToAchievementDetail(
                                  achievement,
                                ),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  achievement.iconPath,
                                  width: 32,
                                  height: 32,
                                  colorFilter: ColorFilter.mode(
                                    Colors.grey[400]!,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        achievement.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      LinearProgressIndicator(
                                        value: _getAchievementProgress(
                                          achievement,
                                        ),
                                        backgroundColor: Colors.grey[300],
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppTheme.primaryColor,
                                            ),
                                        minHeight: 6,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  achievement.value,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // 获取成就进度
  double _getAchievementProgress(Achievement achievement) {
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

  Widget _buildBottomNavBar() {
    return Obx(
      () => BottomNavBar(
        currentIndex: controller.currentNavIndex.value,
        onTap: (index) {
          controller.currentNavIndex.value = index;

          // 导航
          switch (index) {
            case 0:
              Get.offAllNamed(Routes.LINK_NOTE);
              break;
            case 1:
              Get.offAllNamed(Routes.QUIZ);
              break;
            case 2:
              Get.offAllNamed(Routes.QUESTION_BANK);
              break;
            case 3:
              // 已经在个人中心页面
              break;
          }
        },
      ),
    );
  }
}
