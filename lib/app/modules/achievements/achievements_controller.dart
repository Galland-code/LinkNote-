import 'package:get/get.dart';
import '../../data/models/achievement.dart';
import '../../data/repositories/achievement_repository.dart';

class AchievementsController extends GetxController {
  // 依赖注入
  final AchievementRepository _achievementRepository = Get.find<AchievementRepository>();

  // 可观察变量
  final RxInt currentNavIndex = 3.obs;
  final RxList<Achievement> achievements = <Achievement>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAchievements();
  }

  // 加载成就
  Future<void> loadAchievements() async {
    try {
      isLoading.value = true;
      achievements.value = await _achievementRepository.getAchievements();
      isLoading.value = false;
      errorMessage.value = '';
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = '加载成就失败: $e';
    }
  }

  // 获取已解锁成就
  List<Achievement> getUnlockedAchievements() {
    return achievements.where((a) => a.isUnlocked).toList();
  }

  // 获取未解锁成就
  List<Achievement> getLockedAchievements() {
    return achievements.where((a) => !a.isUnlocked).toList();
  }

  // 获取个人最高记录
  List<Achievement> getPersonalRecords() {
    return getUnlockedAchievements().where((a) {
      return a.title == '连续完美无错' || a.title == '连续登录';
    }).toList();
  }
}
