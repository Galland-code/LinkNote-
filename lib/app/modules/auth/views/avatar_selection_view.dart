import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/pixel_button.dart';
import '../../../widgets/pixel_card.dart';
import '../../../data/models/avatar_data.dart';

class AvatarSelectionView extends GetView<AuthController> {
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
              Expanded(child: _buildAvatarGrid()),
              _buildButtons(),
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
          child: Text('选择头像', style: AppTheme.titleStyle),
        ),
      ),
    );
  }

  Widget _buildAvatarGrid() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        itemCount: AvatarData.avatars.length,
        itemBuilder: (context, index) {
          return Obx(
            () => GestureDetector(
              onTap: () => controller.selectAvatar(index),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        controller.selectedAvatarIndex.value == index
                            ? AppTheme.primaryColor
                            : Colors.transparent,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Image.asset(
                    AvatarData.avatars[index],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: PixelButton(
              text: '返回',
              onPressed: () => Get.back(),
              backgroundColor: Colors.grey,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: PixelButton(
              text: '确认',
              onPressed:
                  () => Get.back(result: controller.selectedAvatarIndex.value),
            ),
          ),
        ],
      ),
    );
  }
}
