import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        child: Container(
          // Graph paper background pattern
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
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Text(
            'Quiz',
            style: AppTheme.titleStyle,
          ),
        ),
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
            child: Image.asset(
              'assets/images/pencil.png',
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
            onPressed: () {
              // Navigate to answering questions
            },
            backgroundColor: AppTheme.primaryColor,
          ),
          SizedBox(height: 16),
          PixelButton(
            text: '新的挑战',
            onPressed: () {
              // Start new quiz
            },
            backgroundColor: AppTheme.primaryColor,
          ),
          SizedBox(height: 16),
          PixelButton(
            text: '历史记录',
            onPressed: () {
              // View history
            },
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



