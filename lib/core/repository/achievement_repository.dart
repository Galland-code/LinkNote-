import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/achievement_model.dart';
import '../network/api_provider.dart';

/// 成就仓库，处理成就数据的获取和存储
class AchievementRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final Box<Achievement> _achievementBox = Hive.box<Achievement>('achievementBox');

  // 获取所有成就
  List<Achievement> getAllAchievements() {
    return _achievementBox.values.toList();
  }

  // 获取用户成就
  Future<List<Achievement>> getUserAchievements(String userId, {bool forceRefresh = false}) async {
    // 如果不强制刷新且本地有数据，则返回本地数据
    if (!forceRefresh) {
      final localAchievements = getAllAchievements();
      if (localAchievements.isNotEmpty) {
        return localAchievements;
      }
    }

    try {
      // 从服务器获取数据
      final achievements = await _apiProvider.getUserAchievements(userId);

      // 存储新数据
      for (var achievement in achievements) {
        await _achievementBox.put(achievement.id, achievement);
      }

      return achievements;
    } catch (e) {
      // 如果网络请求失败但本地有数据，返回本地数据
      if (_achievementBox.isNotEmpty) {
        return _achievementBox.values.toList();
      }
      rethrow;
    }
  }

  // 解锁成就
  Future<bool> unlockAchievement(String userId, String achievementId) async {
    try {
      // 从服务器解锁成就
      final unlocked = await _apiProvider.unlockAchievement(userId, achievementId);

      if (unlocked) {
        // 更新本地成就状态
        await getUserAchievements(userId, forceRefresh: true);
      }

      return unlocked;
    } catch (e) {
      rethrow;
    }
  }

  // 保存成就
  Future<void> saveAchievement(Achievement achievement) async {
    await _achievementBox.put(achievement.id, achievement);
  }
}
