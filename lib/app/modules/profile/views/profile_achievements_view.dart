import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:linknote/core/extensions/context_extensions.dart';
import 'package:linknote/core/theme/app_theme.dart';
import '../../../data/services/achievement_service.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/pixel_button.dart';
import '../../../widgets/pixel_card.dart';

class ProfileAchievementsView extends StatelessWidget {
  final AchievementService achievementService = Get.find<AchievementService>();
  final RxInt currentNavIndex = 3.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: context.withGridBackground(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPlayerCard(context),
                        SizedBox(height: 24),
                        _buildLevelProgressSection(),
                        SizedBox(height: 24),
                        _buildStatsSection(),
                        SizedBox(height: 24),
                        _buildAchievementsSection(),
                        SizedBox(height: 24),
                        _buildTitlesSection(),
                        SizedBox(height: 24),
                        _buildFramesSection(),
                        SizedBox(height: 24),
                        _buildLeaderboardSection(),
                      ],
                    ),
                  ),
                ),
              ),
              _buildBottomNavBar(),
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
        alignment: Alignment.centerRight,
        children: [
          Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/pixel-title.png'),
                fit: BoxFit.contain,
              ),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 8),
                  Text('个人成就', style: AppTheme.titleStyle),
                  SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(BuildContext context) {
    return Obx(() {
      final userAchievement = achievementService.userAchievement.value;

      if (userAchievement == null) {
        return PixelCard(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      return PixelCard(
        backgroundColor: AppTheme.primaryColor.withOpacity(0.8),
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                _buildAvatarWithFrame(),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Lv.${userAchievement.level} ${userAchievement.currentTitle}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.emoji_events, color: Colors.amber),
                          SizedBox(width: 8),
                          Text(
                            '战力值: ${userAchievement.powerScore}',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '解锁成就: ${userAchievement.unlockedAchievements.length}/${achievementService.achievementDefinitions.length}',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildExpBar(
              userAchievement.experiencePoints,
              userAchievement.nextLevelExperience,
              userAchievement.level,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAvatarWithFrame() {
    return Obx(() {
      final userAchievement = achievementService.userAchievement.value;
      if (userAchievement == null) {
        return CircleAvatar(radius: 35);
      }

      // 获取当前头像框信息
      final frameId = userAchievement.currentFrame;
      final frameInfo = achievementService.frameDefinitions.firstWhere(
        (f) => f['id'] == frameId,
        orElse: () => achievementService.frameDefinitions.first,
      );

      final hasAnimation = frameInfo['hasAnimation'] == true;

      return Stack(
        children: [
          // 头像框
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(frameInfo['imageUrl']),
                fit: BoxFit.contain,
              ),
            ),
          ),

          // 用户头像
          Positioned(
            top: 15,
            left: 15,
            child: CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage('assets/avatars/1.png'),
            ),
          ),

          // 动画效果(如果有)
          if (hasAnimation)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildExpBar(int currentExp, int nextLevelExp, int level) {
    final progress = currentExp / nextLevelExp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '经验值: $currentExp / $nextLevelExp',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            Text(
              '下一级: ${level + 1}',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
        SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
          ),
        ),
      ],
    );
  }

  Widget _buildLevelProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '等级路线',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Container(
          height: 100,
          child: Obx(() {
            final userLevel =
                achievementService.userAchievement.value?.level ?? 1;

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 20,
              itemBuilder: (context, index) {
                final level = index + 1;
                final isUnlocked = level <= userLevel;

                return Container(
                  width: 70,
                  margin: EdgeInsets.only(right: 8),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color:
                              isUnlocked
                                  ? AppTheme.primaryColor
                                  : Colors.grey.shade300,
                          shape: BoxShape.circle,
                          boxShadow:
                              isUnlocked
                                  ? [
                                    BoxShadow(
                                      color: AppTheme.primaryColor.withOpacity(
                                        0.3,
                                      ),
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                  : null,
                        ),
                        child: Center(
                          child: Text(
                            '$level',
                            style: TextStyle(
                              color:
                                  isUnlocked
                                      ? Colors.white
                                      : Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        isUnlocked ? '已解锁' : '未解锁',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isUnlocked ? AppTheme.primaryColor : Colors.grey,
                        ),
                      ),
                      Text(
                        '经验值: ${_calculateExpForLevel(level)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  int _calculateExpForLevel(int level) {
    return (100 * math.pow(1.2, level - 1)).round();
  }

  Widget _buildStatsSection() {
    return Obx(() {
      final stats = achievementService.userAchievement.value;
      if (stats == null) {
        return SizedBox.shrink();
      }

      final correctRate =
          stats.totalQuestions > 0
              ? (stats.correctQuestions / stats.totalQuestions * 100)
                  .toStringAsFixed(1)
              : '0.0';

      return PixelCard(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '答题统计',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Divider(),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  '总题数',
                  '${stats.totalQuestions}',
                  Icons.question_answer,
                  AppTheme.primaryColor,
                ),
                _buildStatItem(
                  '正确数',
                  '${stats.correctQuestions}',
                  Icons.check_circle_outline,
                  Colors.green,
                ),
                _buildStatItem(
                  '正确率',
                  '$correctRate%',
                  Icons.equalizer,
                  Colors.orange,
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              '已掌握知识点',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _buildCategoriesProgress(stats.categoryProgress),
          ],
        ),
      );
    });
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildCategoriesProgress(Map<String, int> categories) {
    if (categories.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('暂无知识点记录', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Column(
      children:
          categories.entries.map((entry) {
            return Container(
              margin: EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${entry.value} 点',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: _normalizeProgress(entry.value),
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getCategoryColor(entry.key),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  double _normalizeProgress(int value) {
    // 将知识点进度归一化为0-1之间的值，100视为满进度
    return value > 100 ? 1.0 : value / 100.0;
  }

  Color _getCategoryColor(String category) {
    // 根据分类返回不同颜色
    if (category.contains('计算机网络')) return Colors.blue;
    if (category.contains('操作系统')) return Colors.red;
    if (category.contains('数据结构')) return Colors.green;
    if (category.contains('算法')) return Colors.purple;
    return AppTheme.primaryColor;
  }

  Widget _buildAchievementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '成就徽章',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Obx(() {
          final unlockedAchievements =
              achievementService.userAchievement.value?.unlockedAchievements ??
              [];

          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                achievementService.achievementDefinitions.map((achievement) {
                  final isUnlocked = unlockedAchievements.contains(
                    achievement['id'],
                  );
                  return _buildAchievementItem(achievement, isUnlocked);
                }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildAchievementItem(
    Map<String, dynamic> achievement,
    bool isUnlocked,
  ) {
    return Container(
      width: 100,
      height: 120,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isUnlocked ? Colors.amber.shade100 : Colors.grey.shade200,
              shape: BoxShape.circle,
              boxShadow:
                  isUnlocked
                      ? [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.5),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ]
                      : null,
            ),
            child: Center(
              child:
                  isUnlocked
                      ? SvgPicture.asset(
                        achievement['iconPath'],
                        width: 40,
                        height: 40,
                      )
                      : Icon(
                        Icons.lock_outline,
                        color: Colors.grey.shade400,
                        size: 30,
                      ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            achievement['title'],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isUnlocked ? Colors.black : Colors.grey,
            ),
          ),
          SizedBox(height: 4),
          Text(
            isUnlocked ? '已解锁' : '未解锁',
            style: TextStyle(
              fontSize: 10,
              color: isUnlocked ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitlesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('称号', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        Container(
          height: 90,
          child: Obx(() {
            final unlockedTitles =
                achievementService.userAchievement.value?.unlockedTitles ?? [];
            final currentTitle =
                achievementService.userAchievement.value?.currentTitle ?? '';

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: achievementService.titleDefinitions.length,
              itemBuilder: (context, index) {
                final title = achievementService.titleDefinitions[index];
                final isUnlocked = unlockedTitles.contains(title['id']);
                final isSelected = currentTitle == title['id'];

                return GestureDetector(
                  onTap:
                      isUnlocked
                          ? () => achievementService.setUserTitle(title['id'])
                          : null,
                  child: Container(
                    width: 110,
                    margin: EdgeInsets.only(right: 12),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppTheme.primaryColor.withOpacity(0.2)
                              : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            isSelected
                                ? AppTheme.primaryColor
                                : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title['title'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color:
                                isUnlocked
                                    ? Colors.black
                                    : Colors.grey.shade400,
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isUnlocked
                                  ? Icons.check_circle
                                  : Icons.lock_outline,
                              color:
                                  isUnlocked
                                      ? Colors.green
                                      : Colors.grey.shade400,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              isUnlocked ? '已解锁' : '未解锁',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    isUnlocked
                                        ? Colors.green
                                        : Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                        if (isSelected)
                          Text(
                            '使用中',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFramesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '头像框',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Container(
          height: 120,
          child: Obx(() {
            final unlockedFrames =
                achievementService.userAchievement.value?.unlockedFrames ?? [];
            final currentFrame =
                achievementService.userAchievement.value?.currentFrame ?? '';

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: achievementService.frameDefinitions.length,
              itemBuilder: (context, index) {
                final frame = achievementService.frameDefinitions[index];
                final isUnlocked = unlockedFrames.contains(frame['id']);
                final isSelected = currentFrame == frame['id'];

                return GestureDetector(
                  onTap:
                      isUnlocked
                          ? () => achievementService.setUserFrame(frame['id'])
                          : null,
                  child: Container(
                    width: 100,
                    margin: EdgeInsets.only(right: 12),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppTheme.primaryColor.withOpacity(0.2)
                              : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            isSelected
                                ? AppTheme.primaryColor
                                : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(frame['imageUrl']),
                              fit: BoxFit.contain,
                              colorFilter:
                                  isUnlocked
                                      ? null
                                      : ColorFilter.mode(
                                        Colors.grey.shade300,
                                        BlendMode.saturation,
                                      ),
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          frame['name'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color:
                                isUnlocked
                                    ? Colors.black
                                    : Colors.grey.shade400,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          isUnlocked ? '已解锁' : '未解锁',
                          style: TextStyle(
                            fontSize: 10,
                            color:
                                isUnlocked
                                    ? Colors.green
                                    : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildLeaderboardSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '排行榜',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                Get.toNamed(Routes.PROFILE_ACHIEVEMENTS);
              },
              child: Row(
                children: [
                  Text('查看更多'),
                  Icon(Icons.arrow_forward_ios, size: 12),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: achievementService.getFriendsLeaderboard(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('加载失败'));
            }

            final data = snapshot.data ?? [];
            if (data.isEmpty) {
              return Center(child: Text('暂无排行数据'));
            }

            return PixelCard(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '好友排行',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  ...data
                      .take(3)
                      .map((user) => _buildLeaderboardItem(user))
                      .toList(),
                  SizedBox(height: 12),
                  Center(
                    child: PixelButton(
                      text: '查看完整排行',
                      onPressed: () => Get.toNamed(Routes.PROFILE_ACHIEVEMENTS),
                      width: 200,
                      height: 40,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(Map<String, dynamic> user) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _getRankColor(user['powerScore']),
                width: 2,
              ),
              image: DecorationImage(
                image: AssetImage(user['avatar']),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['username'],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Lv.${user['level']} ${user['title']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(Icons.emoji_events, color: Colors.amber, size: 16),
                  SizedBox(width: 4),
                  Text(
                    '${user['powerScore']}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getRankColor(user['powerScore']),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                '完成挑战: ${user['completedChallenges']}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int score) {
    if (score >= 400) return Colors.purple;
    if (score >= 300) return Colors.amber;
    if (score >= 200) return Colors.blue;
    if (score >= 100) return Colors.green;
    return Colors.grey;
  }

  Widget _buildBottomNavBar() {
    return Obx(
      () => BottomNavBar(
        currentIndex: currentNavIndex.value,
        onTap: (index) {
          currentNavIndex.value = index;

          // Navigate based on index
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
              // Already on profile
              break;
          }
        },
      ),
    );
  }
}
