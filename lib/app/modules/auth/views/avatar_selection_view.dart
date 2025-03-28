import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linknote/core/extensions/context_extensions.dart';
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
        child: context.withGridBackground(
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
      child: Stack(
        alignment: Alignment.centerRight, // 右对齐
        children: [
          Container(
            width: double.infinity,
            height: 70,
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
                  Text('更换头像', style: AppTheme.titleStyle),
                  SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ],
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
