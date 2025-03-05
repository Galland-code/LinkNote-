import 'package:get/get.dart';
import '../../core/models/achievement_model.dart';
import '../../core/repository/achievement_repository.dart';
import '../../core/repository/user_repository.dart';

/// 成就控制器，管理成就相关状态和逻辑
class AchievementController extends GetxController {
  final AchievementRepository _achievementRepository = Get.find<AchievementRepository>();
  final UserRepository _userRepository = Get.find<UserRepository>();

  // 响应式状态变量
  final RxList<Achievement> achievements = <Achievement>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserAchievements();
  }

  // 加载用户成就
  Future<void> loadUserAchievements({bool forceRefresh = false}) async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final user = await _userRepository.getCurrentUser();
      if (user != null) {
        final userAchievements = await _achievementRepository.getUserAchievements(
          user.id,
          forceRefresh: forceRefresh,
        );
        achievements.assignAll(userAchievements);
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // 解锁成就
  Future<bool> unlockAchievement(String achievementId) async {
    try {
      final user = await _userRepository.getCurrentUser();
      if (user != null) {
        final unlocked = await _achievementRepository.unlockAchievement(
          user.id,
          achievementId,
        );

        if (unlocked) {
          // 刷新成就列表
          await loadUserAchievements(forceRefresh: true);
        }

        return unlocked;
      }
      return false;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      return false;
    }
  }

  // 获取特定成就
  Achievement? getAchievement(String achievementId) {
    return achievements.firstWhereOrNull((achievement) => achievement.id == achievementId);
  }

  // 检查是否已解锁成就
  bool isAchievementUnlocked(String achievementId) {
    return achievements.any((achievement) => achievement.id == achievementId);
  }
}
