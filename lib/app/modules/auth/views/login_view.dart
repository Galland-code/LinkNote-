// lib/app/modules/auth/views/login_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/pixel_button.dart';
import '../../../widgets/pixel_card.dart';
import '../../../routes/app_routes.dart';

class LoginView extends GetView<AuthController> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool isPasswordVisible = false.obs;
  final RxBool rememberMe = false.obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHeader(),
                    SizedBox(height: 32),
                    _buildLoginForm(),
                    SizedBox(height: 16),
                    _buildRegisterLink(),
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
        // 应用图标
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(16),
          child: Image.asset(
            'assets/images/app_icon.png',
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: 16),

        // 应用名称
        Text(
          'LinkNote',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        SizedBox(height: 8),

        // 标语
        Text(
          '学习路上的游戏化助手',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return PixelCard(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '登录账号',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24),

          // 邮箱输入
          TextFormField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: '邮箱',
              hintText: '请输入邮箱地址',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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

          // 密码输入
          Obx(() => TextFormField(
            controller: passwordController,
            decoration: InputDecoration(
              labelText: '密码',
              hintText: '请输入密码',
              prefixIcon: Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  isPasswordVisible.value ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => isPasswordVisible.value = !isPasswordVisible.value,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            obscureText: !isPasswordVisible.value,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入密码';
              }
              return null;
            },
          )),
          SizedBox(height: 16),

          // 记住我和忘记密码
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 记住我
              Obx(() => Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: rememberMe.value,
                      onChanged: (value) => rememberMe.value = value ?? false,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      activeColor: AppTheme.primaryColor,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('记住我'),
                ],
              )),

              // 忘记密码
              TextButton(
                onPressed: () {
                  // 跳转到忘记密码页面
                },
                child: Text(
                  '忘记密码?',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // 登录按钮
          PixelButton(
            text: '登录',
            onPressed: _login,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  void _login() {
    if (formKey.currentState?.validate() ?? false) {
      // 在实际应用中，这里应该调用控制器的登录方法
      // controller.login(emailController.text, passwordController.text);

      // 模拟登录成功，跳转到主页
      Get.offAllNamed(Routes.QUIZ);
    }
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('还没有账号？'),
        TextButton(
          onPressed: () => Get.toNamed(Routes.AUTH_REGISTER),
          child: Text(
            '立即注册',
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