// lib/app/modules/auth/views/login_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linknote/core/extensions/context_extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/pixel_button.dart';
import '../../../widgets/pixel_card.dart';
import '../../../routes/app_routes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../controllers/userController.dart';

class LoginView extends GetView<AuthController> {
  final TextEditingController accountController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool isPasswordVisible = false.obs;
  final RxBool rememberMe = false.obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Get screen size to make responsive decisions
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      body: SafeArea(
        child: context.withGridBackground(
          pixelStyle: true,
          enhanced: true,
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
              child: Form(
                key: formKey,
                child: ConstrainedBox(
                  // Constrain max width for larger screens
                  constraints: BoxConstraints(maxWidth: 600),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildHeader(context),
                      SizedBox(height: isSmallScreen ? 20 : 32),
                      _buildLoginForm(context),
                      SizedBox(height: 16),
                      _buildRegisterLink(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Column(
      children: [
        // App icon - responsive size
        Container(
          width: isSmallScreen ? 140 : 200,
          height: isSmallScreen ? 140 : 200,
          child: Image.asset('assets/images/app_icon.png', fit: BoxFit.contain),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),

        // App name - responsive font size
        Text(
          'LinkNote',
          style: TextStyle(
            fontSize: isSmallScreen ? 32 : 40,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),

        // Slogan - responsive font size
        Text(
          '我玩游戏的时候都在学习！',
          style: TextStyle(
              fontSize: isSmallScreen ? 16 : 20,
              color: Colors.grey[700]
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return PixelCard(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '登录账号',
            style: TextStyle(
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 24),

          // Account input
          TextFormField(
            controller: accountController,
            decoration: InputDecoration(
              labelText: '账号',
              hintText: '请输入账号',
              prefixIcon: Icon(Icons.account_box),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: isSmallScreen ? 12 : 16,
                horizontal: isSmallScreen ? 12 : 16,
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

          // Password input
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
                contentPadding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 12 : 16,
                  horizontal: isSmallScreen ? 12 : 16,
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

          // Remember me and forgot password - make this responsive for small screens
          isSmallScreen
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Remember me
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
              SizedBox(height: 8),
              // Forgot password
              TextButton(
                onPressed: () {
                  // Navigate to forgot password page
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  alignment: Alignment.centerLeft,
                ),
                child: Text(
                  '忘记密码?',
                  style: TextStyle(color: AppTheme.primaryColor),
                ),
              ),
            ],
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Remember me
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

              // Forgot password
              TextButton(
                onPressed: () {
                  // Navigate to forgot password page
                },
                child: Text(
                  '忘记密码?',
                  style: TextStyle(color: AppTheme.primaryColor),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          // Login button
          PixelButton(
            text: '登录',
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                // Get user input
                String account = accountController.text;
                String password = passwordController.text;

                // Build request URL
                const String url =
                    'http://82.157.18.189:8080/linknote/api/auth/login';

                try {
                  // Send POST request
                  final response = await http.post(
                    Uri.parse(url),
                    headers: {
                      'Content-Type': 'application/json',
                    },
                    body: json.encode({
                      'username': account,
                      'password': password,
                    }),
                  );

                  // Check response status
                  if (response.statusCode == 200) {
                    // Login successful, save user info and navigate
                    final user = json.decode(response.body);
                    print(user);
                    saveUser(user);
                    print(user['id']);
                    print("设置用户id");
                    // Set userId
                    Get.find<UserController>().setUserId(user['id']);

                    Get.offAllNamed(Routes.LINK_NOTE);
                  } else {
                    // Handle login failure
                    print('登录失败: ${response.statusCode} - ${response.body}');
                    // For testing, still navigate to main page
                    Get.offAllNamed(Routes.LINK_NOTE);
                  }
                } catch (e) {
                  // Handle network errors
                  print('网络错误: $e');
                  // Show error message to user
                  Get.snackbar('连接错误', '请检查网络连接后重试');
                }
              }
            },
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  // Save user information method
  void saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', user['id']);
    await prefs.setString('username', user['username']);
    await prefs.setString('email', user['email']);
    await prefs.setString('password', user['password']);
    await prefs.setString('createdAt', user['createdAt']);
    await prefs.setInt('avatarIndex', user['avatarIndex']);
    await prefs.setInt('level', user['level']);
    await prefs.setInt('experiencePoints', user['experiencePoints']);
    await prefs.setString('lastLogin', user['lastLogin']);
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