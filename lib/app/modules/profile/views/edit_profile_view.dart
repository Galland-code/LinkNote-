import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:linknote/core/extensions/context_extensions.dart';
import '../../../routes/app_routes.dart';
import '../controllers/profile_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/pixel_card.dart';
import '../../../widgets/pixel_button.dart';
import '../../../data/models/avatar_data.dart';

class EditProfileView extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: context.withGridBackground(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildEditForm(),
              ),
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
                  Text('编辑资料', style: AppTheme.titleStyle),
                  SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    final user = controller.currentUser.value;
    if (user == null) {
      return Center(child: Text('用户信息加载失败'));
    }

    // 创建本地文本控制器
    final usernameController = TextEditingController(text: user.username);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头像选择
          Padding(
            padding: EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              '头像',
              style: AppTheme.subtitleStyle,
            ),
          ),
          PixelCard(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Obx(() => Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primaryColor, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SvgPicture.asset(
                      AvatarData.avatars[controller.selectedAvatarIndex.value],
                      fit: BoxFit.cover,
                    ),
                  ),
                )),
                SizedBox(height: 16),
                PixelButton(
                  text: '更换头像',
                  onPressed: () async {
                    final result = await Get.toNamed(Routes.PROFILE_AVATAR_SELECTION);
                    if (result != null) {
                      controller.saveAvatarSelection(result);
                    }
                  },
                  width: 150,
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // 用户名
          Padding(
            padding: EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              '用户名',
              style: AppTheme.subtitleStyle,
            ),
          ),
          PixelCard(
            padding: EdgeInsets.all(16),
            child: TextFormField(
              controller: usernameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '输入用户名',
                prefixIcon: Icon(Icons.person),
              ),
            ),
          ),
          SizedBox(height: 16),

          // 用户等级和经验(只读)
          Padding(
            padding: EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              '等级与经验',
              style: AppTheme.subtitleStyle,
            ),
          ),
          PixelCard(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('当前等级'),
                    Text(
                      'Lv.${user.level}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('当前经验'),
                    Text(
                      '${user.experiencePoints} 点',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('下一等级需要'),
                    Text(
                      '${100 - (user.experiencePoints % 100)} 点',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                LinearProgressIndicator(
                  value: (user.experiencePoints % 100) / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // 账号信息(只读)
          Padding(
            padding: EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              '账号信息',
              style: AppTheme.subtitleStyle,
            ),
          ),
          PixelCard(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('邮箱'),
                    Text(
                      user.email,
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('注册时间'),
                    Text(
                      '${DateFormat('yyyy年MM月dd日').format(user.createdAt)}',
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
              text: '取消',
              onPressed: () => Get.back(),
              backgroundColor: Colors.grey,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: PixelButton(
              text: '保存',
              onPressed: () {
                // 保存用户信息
                Get.back();
              },
            ),
          ),
        ],
      ),
    );
  }
}
