import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/quiz_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/pixel_card.dart';
import '../../../widgets/pixel_button.dart';
import '../../../widgets/pixel_loading.dart';

class HistoryChallengeView extends GetView<QuizController> {
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
          child: Obx(() {
            if (controller.isLoading.value) {
              return Center(child: PixelLoading());
            }

            return Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _buildChallengesList(),
                ),
                _buildBottomButtons(),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
            ),
          ),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Text(
                '历史挑战',
                style: AppTheme.titleStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengesList() {
    if (controller.challengeHistory.isEmpty) {
      return Center(
        child: Text(
          '暂无历史挑战',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: controller.challengeHistory.length,
      itemBuilder: (context, index) {
        final challenge = controller.challengeHistory[index];

        // 通过 Map 键来访问对应的值
        String challengeTitle = challenge['title'] ?? '无标题';
        String challengeSource = challenge['source'] ?? '未知来源';
        DateTime challengeCreatedAt = challenge['createdAt'] ?? DateTime.now();

        // 计算完成关卡数
        int completedLevels = 0;
        for (var level in challenge['levels']) {
          if (level['isCompleted'] == true) completedLevels++;
        }

        return GestureDetector(
          onTap: () => controller.continueChallenge(challenge),
          child: Container(
            margin: EdgeInsets.only(bottom: 16),
            child: PixelCard(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.military_tech,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              challengeTitle,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '来源: $challengeSource',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right),
                    ],
                  ),
                  SizedBox(height: 12),
                  // 关卡进度
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '创建于: ${_formatDate(challengeCreatedAt)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: completedLevels / challenge['levels'].length,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryColor,
                              ),
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '已完成 $completedLevels / ${challenge['levels'].length} 关卡',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: PixelButton(
        text: '返回',
        onPressed: () => Get.back(),
        backgroundColor: Colors.grey,
      ),
    );
  }
}

extension on Map<String, dynamic> {
  get levels => null;
}