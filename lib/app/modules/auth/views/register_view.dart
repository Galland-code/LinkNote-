import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/pixel_button.dart';
import '../../../widgets/pixel_card.dart';
import '../../../data/models/avatar_data.dart';

class RegisterView extends GetView<AuthController> {
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
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Form(
                key: controller.formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHeader(),
                    SizedBox(height: 24),
                    _buildAvatarSelection(),
                    SizedBox(height: 24),
                    _buildRegisterForm(),
                    SizedBox(height: 16),
                    _buildLoginLink(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Text(
            'LinkNote',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          '创建您的学习账号',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarSelection() {
    return Column(
      children: [
        Text(
          '选择您的头像',
          style: AppTheme.subtitleStyle,
        ),
        SizedBox(height: 16),
        Obx(() => Container(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: AvatarData.avatars.length,
            itemBuilder: (context, index) {
              final isSelected = controller.selectedAvatarIndex.value == index;
              return GestureDetector(
                onTap: () => controller.selectAvatar(index),
                child: Container(
                  width: 80,
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryColor : Colors.transparent,
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
              );
            },
          ),
        )),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return PixelCard(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // 用户名
          TextFormField(
            controller: controller.usernameController,
            decoration: InputDecoration(
              labelText: '用户名',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入用户名';
              }
              return null;
            },
          ),
          SizedBox(height: 16),

          // 邮箱
          TextFormField(
            controller: controller.emailController,
            decoration: InputDecoration(
              labelText: '邮箱',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入邮箱';
              }
              if (!GetUtils.isEmail(value)) {
                return '请输入有效的邮箱地址';
              }
              return null;
            },
          ),
          SizedBox(height: 16),

          // 密码
          Obx(() => TextFormField(
            controller: controller.passwordController,
            decoration: InputDecoration(
              labelText: '密码',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.isPasswordVisible.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: controller.togglePasswordVisibility,
              ),
            ),
            obscureText: !controller.isPasswordVisible.value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入密码';
              }
              if (value.length < 6) {
                return '密码长度至少为6位';
              }
              return null;
            },
          )),
          SizedBox(height: 16),

          // 确认密码
          Obx(() => TextFormField(
            controller: controller.confirmPasswordController,
            decoration: InputDecoration(
              labelText: '确认密码',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.isConfirmPasswordVisible.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: controller.toggleConfirmPasswordVisibility,
              ),
            ),
            obscureText: !controller.isConfirmPasswordVisible.value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请再次输入密码';
              }
              if (value != controller.passwordController.text) {
                return '两次输入的密码不一致';
              }
              return null;
            },
          )),
          SizedBox(height: 24),

          // 错误消息
          Obx(() => controller.errorMessage.value.isNotEmpty
              ? Container(
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.errorMessage.value,
                    style: TextStyle(color: Colors.red[800]),
                  ),
                ),
              ],
            ),
          )
              : SizedBox.shrink()),

          // 注册按钮
          Obx(() => PixelButton(
            text: controller.isLoading.value ? '注册中...' : '注册',
            onPressed: controller.isLoading.value
                ? () {}
                : controller.register,
            width: double.infinity,
          )),
        ],
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('已有账号？'),
        TextButton(
          onPressed: controller.goToLogin,
          child: Text(
            '立即登录',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
