import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:linknote/core/extensions/context_extensions.dart';
import '../controllers/quiz_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/pixel_button.dart';
import '../../../widgets/pixel_card.dart';

class QuizView extends GetView<QuizController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: context.withGridBackground(
          pixelStyle: true,
          enhanced: true,
          child: Column(
            children: [
              _buildHeader(),
              _buildBookImage(),
              Expanded(child: _buildButtons()),
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
    height: 80, // 根据需要调整高度
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
    Text(
    'Quiz',
    style: AppTheme.titleStyle,
    ),
    SizedBox(width: 8),
    ],
    ),
    ),
    ),
    Positioned(
    // 使用 Positioned 来放置 FloatingActionButton
    right: 0, // 右侧对齐
    child: FloatingActionButton(
    onPressed:
    () => Get.toNamed(Routes.LINK_NOTE_EDIT), // 点击按钮时导航到编辑页面
    backgroundColor: AppTheme.primaryColor, // 按钮背景颜色
    child: Icon(Icons.add, color: Colors.white), // 按钮图标
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16), // 圆角边框
    side: BorderSide(color: Colors.black, width: 2), // 边框样式
    ),
    ),
    ),
    ],
    ),
    );
  }

  Widget _buildBookImage() {
    return Container(
      height: 200,
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Open book
          Image.asset(
            'assets/images/open_book.png',
            fit: BoxFit.contain,
          ),

          // Pencil overlay
          Positioned(
            bottom: 20,
            right: 50,
            child: SvgPicture.asset(
              'assets/images/pencil.svg',
              width: 100,
              height: 100,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PixelButton(
            text: '继续答题',
            onPressed: () =>
              Get.toNamed(Routes.QUIZ_QUESTION),

            backgroundColor: AppTheme.primaryColor,
          ),
          SizedBox(height: 16),
          PixelButton(
            text: '新的挑战',
            onPressed: () =>
              Get.toNamed(Routes.QUIZ_QUESTION)
            ,
            backgroundColor: AppTheme.primaryColor,
          ),
          SizedBox(height: 16),
          PixelButton(
            text: '历史记录',
            onPressed: () =>
              Get.toNamed(Routes.QUIZ_HISTORY),
            backgroundColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Obx(() => BottomNavBar(
      currentIndex: controller.currentNavIndex.value,
      onTap: (index) {
        controller.currentNavIndex.value = index;

        // Navigate based on index
        switch (index) {
          case 0:
            Get.offAllNamed(Routes.LINK_NOTE);
            break;
          case 1:
          // Already on quiz
            break;
          case 2:
            Get.offAllNamed(Routes.QUESTION_BANK);
            break;
          case 3:
            Get.offAllNamed(Routes.ACHIEVEMENTS);
            break;
        }
      },
    ));
  }
}



