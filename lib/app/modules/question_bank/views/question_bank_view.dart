import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:linknote/core/extensions/context_extensions.dart';
import '../../../widgets/pixel_button.dart';
import '../controllers/question_bank_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/pixel_card.dart';
import '../../../data/models/revenge_challenge.dart';

class QuestionBankView extends GetView<QuestionBankController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: context.withGridBackground(
          // Graph paper background pattern
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuestionsList(),
                      _buildAnalysisSection(),
                      _buildRevengeSection(),
                    ],
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
        alignment: Alignment.centerRight, // 右对齐
        children: [
          Container(
            width: double.infinity,
            height: 60, // 根据需要调整高度
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
                  Text('错题集', style: AppTheme.titleStyle),
                  SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsList() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 400, // 设置固定高度以启用溢出效果
        decoration: BoxDecoration(
          color: Color(0xFFD4DEE3),
          borderRadius: BorderRadius.circular(12),
        ),
        // 使用嵌套容器创建内阴影效果
        child: Stack(
          children: [
            // 顶部内阴影
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 10,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.3), Colors.transparent],
                  ),
                ),
              ),
            ),
            // 左侧内阴影
            Positioned(
              top: 0,
              left: 0,
              bottom: 0,
              width: 6,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.black.withOpacity(0.3), Colors.transparent],
                  ),
                ),
              ),
            ),

            // 带裁剪的内容
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Obx(
                    () => Column(
                      children:
                          controller.questions
                              .map(
                                (question) => GestureDetector(
                                  onTap: () {
                                    // 点击卡片时导航到详细视图
                                    Get.toNamed(
                                      Routes.QUESTION_BANK_DETAIL,
                                      arguments: {'id': question.id},
                                    );
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: 12),
                                    child: PixelCard(
                                      backgroundColor: AppTheme.blueCardColor,
                                      padding: EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              SvgPicture.asset(
                                                'assets/icons/coin.svg',
                                                width: 40,
                                                height: 40,
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  '来源: ${question.source}',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            physics: BouncingScrollPhysics(),
                                            child: Text(
                                              'Q: ${question.content}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                              overflow:
                                                  TextOverflow.fade, // 溢出渐变效果
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisSection() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: SvgPicture.asset(
              'assets/icons/content-files.svg',
              height: 120,
              width: 120,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => _showAnalysisReport(),
              child: Obx(
                () => PixelCard(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.bar_chart),
                          SizedBox(width: 8),
                          Text('错题分析:', style: AppTheme.subtitleStyle),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text('1. 待复习错题数: ${controller.questions.length}'),
                      SizedBox(height: 4),
                      ...controller.questionCounts.entries
                          .map(
                            (entry) => Padding(
                              padding: EdgeInsets.only(bottom: 4),
                              child: Text('2. "${entry.key}" 错题分析报告待查看'),
                            ),
                          )
                          .toList(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevengeSection() {
    return Obx(() {
      if (!controller.showRevengeSection.value) {
        return SizedBox.shrink();
      }

      return Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shield, color: Colors.deepOrange),
                SizedBox(width: 8),
                Text('复仇关卡', style: AppTheme.titleStyle.copyWith(fontSize: 20)),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () => controller.loadRevengeChallenges(),
                  tooltip: '刷新',
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              '针对你的薄弱知识点定制的特训关卡，挑战并征服它们！',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            SizedBox(height: 16),
            if (controller.isLoadingRevengeChallenges.value)
              Center(child: CircularProgressIndicator())
            else if (controller.revengeChallenges.isEmpty)
              _buildEmptyRevengeView()
            else
              _buildRevengeChallengesList(),
          ],
        ),
      );
    });
  }

  Widget _buildEmptyRevengeView() {
    return PixelCard(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(Icons.emoji_events, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            '暂无复仇关卡',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            '完成更多题目后，系统将根据你的弱点生成定制关卡',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[700]),
          ),
          SizedBox(height: 16),
          PixelButton(
            text: '生成新关卡',
            onPressed: () => controller.generateNewRevengeChallenge(),
            width: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildRevengeChallengesList() {
    return Container(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount:
            controller.revengeChallenges.length + 1, // +1 for "create new" card
        itemBuilder: (context, index) {
          if (index == controller.revengeChallenges.length) {
            // "Create new" card
            return _buildCreateNewChallengeCard();
          }

          final challenge = controller.revengeChallenges[index];
          return _buildChallengeCard(challenge);
        },
      ),
    );
  }

  Widget _buildChallengeCard(RevengeChallenge challenge) {
    final completionPercentage =
        challenge.questions.isEmpty
            ? 0.0
            : challenge.completedCount / challenge.questions.length;

    return Container(
      width: 180,
      margin: EdgeInsets.only(right: 16),
      child: PixelCard(
        backgroundColor: AppTheme.secondaryColor.withOpacity(0.2),
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              challenge.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),
            Text(
              '${challenge.questions.length}道题目',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              '难度: ${_getDifficultyText(challenge.difficultyLevel)}',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: completionPercentage,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                challenge.isCompleted ? Colors.green : AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '完成度: ${(completionPercentage * 100).toInt()}%',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
            Spacer(),
            PixelButton(
              text: challenge.isCompleted ? '重新挑战' : '开始挑战',
              onPressed: () => controller.startRevengeChallenge(challenge),
              height: 36,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateNewChallengeCard() {
    return Container(
      width: 180,
      margin: EdgeInsets.only(right: 16),
      child: PixelCard(
        backgroundColor: Colors.grey.shade200,
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 48,
              color: AppTheme.primaryColor,
            ),
            SizedBox(height: 16),
            Text(
              '生成新关卡',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '基于你的错题生成新的挑战',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
            Spacer(),
            PixelButton(
              text: '创建',
              onPressed: () => controller.generateNewRevengeChallenge(),
              height: 36,
            ),
          ],
        ),
      ),
    );
  }

  String _getDifficultyText(int level) {
    switch (level) {
      case 1:
        return '简单';
      case 2:
        return '中等';
      case 3:
        return '困难';
      default:
        return '未知';
    }
  }

  void _showAnalysisReport() async {
    await controller.fetchWrongAnalysis();

    if (controller.wrongAnalysis.value != null) {
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: PixelCard(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('错题分析报告', style: AppTheme.subtitleStyle),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                Divider(),
                SizedBox(height: 12),
                Text(
                  controller.wrongAnalysis.value!.analysis,
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
                SizedBox(height: 20),
                Center(
                  child: PixelButton(
                    text: '我知道了',
                    onPressed: () => Get.back(),
                    width: 120,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildBottomNavBar() {
    return Obx(
      () => BottomNavBar(
        currentIndex: controller.currentNavIndex.value,
        onTap: (index) {
          controller.currentNavIndex.value = index;

          // Navigate based on index
          switch (index) {
            case 0:
              Get.offAllNamed(Routes.LINK_NOTE);
              break;
            case 1:
              Get.offAllNamed(Routes.QUIZ);
              break;
            case 2:
              // Already on question bank
              break;
            case 3:
              Get.offAllNamed(Routes.PROFILE_ACHIEVEMENTS);
              break;
          }
        },
      ),
    );
  }
}
