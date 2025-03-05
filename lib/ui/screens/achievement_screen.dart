import 'package:flutter/material.dart';
import '../../core/models/mock_data.dart';
import '../../core/models/achievement_model.dart';
import '../../core/models/user_model.dart';
import '../widgets/pixel_achievement_card.dart';
import '../widgets/pixel_container.dart';
import '../widgets/pixel_title.dart';
import '../widgets/navigation_bar.dart';

/// Achievement screen that shows user achievements
class AchievementScreen extends StatefulWidget {
  const AchievementScreen({Key? key}) : super(key: key);

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  final int _currentIndex = 3; // Current navigation index for achievement screen

  // Mock data for achievements and user
  late List<Achievement> _achievements;
  late User _user;

  @override
  void initState() {
    super.initState();
    // Load mock data
    _achievements = MockData.getMockAchievements();
    _user = MockData.getMockUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background color to match design
      backgroundColor: const Color(0xFFFDF9ED),
      // App bar with title
      appBar: AppBar(
        title: const Text('成就'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      // Main content
      body: SafeArea(
        child: Column(
          children: [
            // Title section
            Padding(
              padding: const EdgeInsets.all(16),
              child: PixelTitle(
                text: '成就等级',
                backgroundColor: Colors.white,
              ),
            ),

            // Main content - grows to fill available space
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Personal best records
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          '个人最高记录',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),

                      // Achievement grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: _achievements.length > 4 ? 4 : _achievements.length,
                        itemBuilder: (context, index) {
                          return PixelAchievementCard(
                            achievement: _achievements[index],
                            onTap: () {
                              // Show achievement details
                              _showAchievementDetails(_achievements[index]);
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Awards section
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          '奖项',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),

                      // Awards grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: 4, // Show 4 awards
                        itemBuilder: (context, index) {
                          return PixelContainer(
                            padding: const EdgeInsets.all(16),
                            backgroundColor: const Color(0xFFFCD8D4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (index == 0) // Emotion icon
                                  Image.asset(
                                    'assets/icons/smiley.png',
                                    width: 32,
                                    height: 32,
                                  ),
                                if (index == 1) // Game console icon
                                  Image.asset(
                                    'assets/icons/gameboy.png',
                                    width: 32,
                                    height: 32,
                                  ),
                                if (index == 2) // Heart icon
                                  Image.asset(
                                    'assets/icons/heart.png',
                                    width: 32,
                                    height: 32,
                                  ),
                                if (index == 3) // Star icon
                                  Image.asset(
                                    'assets/icons/star.png',
                                    width: 32,
                                    height: 32,
                                  ),
                                const SizedBox(height: 8),
                                if (index == 0)
                                  const Text('关卡错误率'),
                                if (index == 1)
                                  const Text('NoGameNo Notebook'),
                                if (index == 2)
                                  const Text('爱心'),
                                if (index == 3)
                                  const Text('明星徽章'),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom navigation bar - floating
      bottomNavigationBar: PixelBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          // Handle navigation
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/quiz');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/question_bank');
              break;
            case 3:
            // Already on achievements screen
              break;
          }
        },
      ),
    );
  }

  // Show achievement details in a dialog
  void _showAchievementDetails(Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(achievement.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              achievement.icon,
              width: 48,
              height: 48,
            ),
            const SizedBox(height: 16),
            Text('获得于: ${achievement.date}'),
            const SizedBox(height: 8),
            Text('详情: ${achievement.description}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}