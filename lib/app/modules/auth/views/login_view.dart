// lib/app/modules/auth/views/login_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linknote/core/extensions/context_extensions.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/pixel_button.dart';
import '../../../widgets/pixel_card.dart';
import '../../../routes/app_routes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // 用于处理 JSON

class LoginView extends GetView<AuthController> {
  final TextEditingController accountController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool isPasswordVisible = false.obs;
  final RxBool rememberMe = false.obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: context.withGridBackground(
          pixelStyle: true,
          enhanced: true,
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
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
          width: 200,
          height: 200,
          // decoration: BoxDecoration(
          //   color: Colors.white,
          //   borderRadius: BorderRadius.circular(24),
          //   border: Border.all(color: Colors.black, width: 3),
          //   boxShadow: [
          //     BoxShadow(
          //       color: Colors.black.withOpacity(0.2),
          //       blurRadius: 10,
          //       offset: Offset(0, 4),
          //     ),
          //   ],
          // ),
          // padding: EdgeInsets.all(16),
          child: Image.asset('assets/images/app_icon.png', fit: BoxFit.contain),
        ),
        SizedBox(height: 16),

        // 应用名称
        Text(
          'LinkNote',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        SizedBox(height: 8),

        // 标语
        Text(
          '我玩游戏的时候都在学习！',
          style: TextStyle(fontSize: 20, color: Colors.grey[700]),
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
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24),

          // 邮箱输入
          TextFormField(
            controller: accountController,
            decoration: InputDecoration(
              labelText: '账号',
              hintText: '请输入账号',
              prefixIcon: Icon(Icons.account_box),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入账号';
              }
              return null;
            },
          ),
          SizedBox(height: 16),

          // 密码输入
          Obx(
            () => TextFormField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: '密码',
                hintText: '请输入密码',
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed:
                      () => isPasswordVisible.value = !isPasswordVisible.value,
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
            ),
          ),
          SizedBox(height: 16),

          // 记住我和忘记密码
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 记住我
              Obx(
                () => Row(
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
                ),
              ),

              // 忘记密码
              TextButton(
                onPressed: () {
                  // 跳转到忘记密码页面，没写
                },
                child: Text(
                  '忘记密码?',
                  style: TextStyle(color: AppTheme.primaryColor),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // 登录按钮
          PixelButton(text: '登录', onPressed: _login, width: double.infinity),
        ],
      ),
    );
  }

  void _login() async {
    if (formKey.currentState?.validate() ?? false) {
      // 获取用户输入的账号和密码
      String account = accountController.text;
      String password = passwordController.text;

      // 构建请求的 URL
      const String url = 'http://82.157.18.189:8080/linknote/api/auth/login';

      // 发送 POST 请求
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json', // 设置请求头
        },
        body: json.encode({'username': account, 'password': password}),
      );

      // 检查响应状态
      if (response.statusCode == 200) {
        // 登录成功，跳转到主页
        Get.offAllNamed(Routes.LINK_NOTE);
      } else {
        // 处理登录失败的情况
        // 你可以显示错误消息
        print('登录失败: ${response.statusCode} -  ${response.body}');
        Get.offAllNamed(Routes.LINK_NOTE);

      }
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
