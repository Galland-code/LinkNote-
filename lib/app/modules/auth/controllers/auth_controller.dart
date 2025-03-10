import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  // 依赖注入
  final UserRepository _userRepository = Get.find<UserRepository>();

  // 表单控制器
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  // 可观察变量
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt selectedAvatarIndex = 0.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;

  // 表单key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    usernameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // 选择头像
  void selectAvatar(int index) {
    selectedAvatarIndex.value = index;
  }

  // 切换密码可见性
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // 切换确认密码可见性
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  // 表单验证
  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  // 注册
  Future<void> register() async {
    if (!validateForm()) {
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

// 检查密码匹配
      if (passwordController.text != confirmPasswordController.text) {
        errorMessage.value = '两次输入的密码不一致';
        isLoading.value = false;
        return;
      }

      // 调用注册API
      final result = await _userRepository.registerUser(
        usernameController.text,
        emailController.text,
        passwordController.text,
        selectedAvatarIndex.value,
      );

      isLoading.value = false;

      // 注册成功，跳转到登录页面
      Get.offAllNamed(Routes.AUTH_LOGIN);
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = '注册失败: $e';
    }
  }

  // 跳转到登录页面
  void goToLogin() {
    Get.toNamed(Routes.AUTH_LOGIN);
  }

  void login(String text, String text2) {}
}
