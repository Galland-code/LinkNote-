import 'package:get/get.dart';
import '../../core/models/user_model.dart';
import '../../core/repository/user_repository.dart';

/// 用户控制器，管理用户相关状态和逻辑
class UserController extends GetxController {
  final UserRepository _userRepository = Get.find<UserRepository>();

  // 响应式状态变量
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkLogin();
  }

  // 检查登录状态
  Future<void> checkLogin() async {
    isLoading.value = true;

    try {
      final user = await _userRepository.getCurrentUser();
      currentUser.value = user;
      isLoggedIn.value = user != null;

      if (user != null) {
        // 更新登录天数
        await _userRepository.updateLoginStreak(user.id);
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // 登录
  Future<bool> login(String username, String password) async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final user = await _userRepository.login(username, password);
      currentUser.value = user;
      isLoggedIn.value = user != null;
      return user != null;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 登出
  Future<void> logout() async {
    isLoading.value = true;

    try {
      await _userRepository.logout();
      currentUser.value = null;
      isLoggedIn.value = false;
      Get.offAllNamed('/login'); // 导航到登录页面
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // 刷新用户信息
  Future<void> refreshUserInfo() async {
    isLoading.value = true;

    try {
      if (currentUser.value != null) {
        final user = await _userRepository.getUser(
          currentUser.value!.id,
          forceRefresh: true,
        );
        currentUser.value = user;
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
