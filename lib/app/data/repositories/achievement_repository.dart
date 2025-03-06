import 'package:get/get.dart';
import '../models/achievement.dart';
import '../providers/api_provider.dart';
import '../services/database_service.dart';
import '../../../core/values/app_constants.dart';

class AchievementRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final DatabaseService _databaseService = Get.find<DatabaseService>();

  // 从API获取所有成就
  Future<List<Achievement>> getAchievementsFromApi() async {
    try {
      final response = await _apiProvider.get(AppConstants.GETIEVEMENTS_ACH);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final List<Achievement> achievements = data.map((item) => Achievement(
          id: item['id'],
          title: item['title'],
          description: item['description'],
          iconPath: item['iconPath'],
          isUnlocked: item['isUnlocked'],
          unlockedAt: item['unlockedAt'] != null ? DateTime.parse(item['unlockedAt']) : null,
          value: item['value'] ?? '',
        )).toList();

        // 保存到本地数据库
        await _databaseService.saveAchievements(achievements);

        return achievements;
      } else {
        throw Exception('Failed to load achievements');
      }
    } catch (e) {
      // 如果API请求失败，使用本地数据
      return _databaseService.getAllAchievements();
    }
  }

  // 从本地数据库获取所有成就
  List<Achievement> getAchievementsFromLocal() {
    return _databaseService.getAllAchievements();
  }

  // 获取成就（先尝试API，失败则用本地）
  Future<List<Achievement>> getAchievements() async {
    try {
      return await getAchievementsFromApi();
    } catch (e) {
      return getAchievementsFromLocal();
    }
  }

  // 解锁成就
  Future<void> unlockAchievement(String id) async {
    final achievement = _databaseService.getAchievement(id);
    if (achievement != null && !achievement.isUnlocked) {
      final updatedAchievement = Achievement(
        id: achievement.id,
        title: achievement.title,
        description: achievement.description,
        iconPath: achievement.iconPath,
        isUnlocked: true,
        unlockedAt: DateTime.now(),
        value: achievement.value,
      );

      await _databaseService.updateAchievement(updatedAchievement);

      // 可选：同步到服务器
      try {
        await _apiProvider.post('/achievements/$id/unlock');
      } catch (_) {
        // 忽略API错误，至少本地已更新
      }
    }
  }

  // 更新成就值
  Future<void> updateAchievementValue(String id, String value) async {
    final achievement = _databaseService.getAchievement(id);
    if (achievement != null) {
      final updatedAchievement = Achievement(
        id: achievement.id,
        title: achievement.title,
        description: achievement.description,
        iconPath: achievement.iconPath,
        isUnlocked: achievement.isUnlocked,
        unlockedAt: achievement.unlockedAt,
        value: value,
      );

      await _databaseService.updateAchievement(updatedAchievement);

      // 可选：同步到服务器
      try {
        await _apiProvider.post('/achievements/$id/value', data: {'value': value});
      } catch (_) {
        // 忽略API错误，至少本地已更新
      }
    }
  }
}