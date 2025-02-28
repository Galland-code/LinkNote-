import 'package:flutter/material.dart';
import '../../models/achievement_model.dart';
import '../../widgets/pixel_card.dart';
import '../../widgets/pixel_container.dart';
import '../../widgets/pixel_navbar.dart';
import '../../widgets/pixel_text.dart';
import '../../themes/colors.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/grid_paper.png'),
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                child: const PixelText.heading(
                  '成就等级',
                  textAlign: TextAlign.center,
                ),
              ),

              // Personal best records
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PixelText.subheading('个人最高记录'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildAchievementCard(
                            icon: 'assets/icons/trophy.png',
                            title: '连续完美无错',
                            value: '3组',
                            date: '2024年12月10日',
                            color: AppColors.trophyGold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildAchievementCard(
                            icon: 'assets/icons/cup.png',
                            title: '连续登录',
                            value: '3天',
                            date: '2024年12月1日',
                            color: AppColors.trophyGold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Rewards section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PixelText.subheading('奖项'),
                      const SizedBox(height: 16),
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          children: [
                            _buildRewardCard(
                              icon: 'assets/icons/smile.png',
                              title: '关卡错误率',
                              color: AppColors.trophyGreen,
                            ),
                            _buildRewardCard(
                              icon: 'assets/icons/gameboy.png',
                              title: 'NoGameNo Notebook',
                              color: AppColors.trophyGold,
                            ),
                            _buildRewardCard(
                              icon: 'assets/icons/heart.png',
                              title: '笔记达人',
                              color: Colors.red.shade200,
                            ),
                            _buildRewardCard(
                              icon: 'assets/icons/star.png',
                              title: '知识收藏家',
                              color: Colors.purple.shade200,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom navigation
              const PixelNavbar(currentIndex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementCard({
    required String icon,
    required String title,
    required String value,
    required String date,
    required Color color,
  }) {
    return PixelCard(
      backgroundColor: Colors.white.withOpacity(0.9),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Image.asset(
            icon,
            width: 40,
            height: 40,
            color: color,
          ),
          const SizedBox(height: 8),
          PixelText.body(
            title,
            textAlign: TextAlign.center,
          ),
          PixelText.subheading(
            value,
            textAlign: TextAlign.center,
          ),
          PixelText.caption(
            date,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard({
    required String icon,
    required String title,
    required Color color,
  }) {
    return PixelCard(
      backgroundColor: Colors.white.withOpacity(0.9),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            icon,
            width: 48,
            height: 48,
            color: color,
          ),
          const SizedBox(height: 12),
          PixelText.body(
            title,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}