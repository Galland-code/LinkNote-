import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:linknote/core/extensions/context_extensions.dart';
import '../controllers/question_bank_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/pixel_card.dart';

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
                    children: [_buildQuestionsList(), _buildAnalysisSection()],
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
        ],
      ),
    );
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
              Get.offAllNamed(Routes.ACHIEVEMENTS);
              break;
          }
        },
      ),
    );
  }
}
