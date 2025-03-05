import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../network/api_provider.dart';

/// 用户仓库，处理用户数据的获取和存储
class UserRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final Box<User> _userBox = Hive.box<User>('userBox');
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // 获取当前用户
  Future<User?> getCurrentUser() async {
    final userId = await _secureStorage.read(key: 'current_user_id');
    if (userId == null) {
      return null;
    }

    return _userBox.get(userId);
  }

  // 获取用户信息
  Future<User?> getUser(String userId, {bool forceRefresh = false}) async {
    // 如果不强制刷新且本地有数据，则返回本地数据
    if (!forceRefresh) {
      final localUser = _userBox.get(userId);
      if (localUser != null) {
        return localUser;
      }
    }

    try {
      // TODO: 从服务器获取用户信息
      // final user = await _apiProvider.getUser(userId);
      // await _userBox.put(userId, user);
      // return user;

      // 模拟从服务器获取用户
      final mockUser = _userBox.get(userId);
      return mockUser;
    } catch (e) {
      // 如果网络请求失败但本地有数据，返回本地数据
      return _userBox.get(userId);
    }
  }

  // 更新用户统计信息
  Future<User?> updateUserStatistics(String userId, int correctAnswers, int totalQuestions) async {
    try {
      // 从服务器更新
      final user = await _apiProvider.updateUserStatistics(userId, correctAnswers, totalQuestions);

      // 更新本地
      await _userBox.put(userId, user);

      return user;
    } catch (e) {
      // 如果网络请求失败，尝试本地更新
      final user = _userBox.get(userId);
      if (user != null) {
        final updatedUser = User(
          id: user.id,
          username: user.username,
          email: user.email,
          perfectStreak: correctAnswers == totalQuestions ? user.perfectStreak + 1 : 0,
          loginStreak: user.loginStreak,
          unlockedAchievementIds: user.unlockedAchievementIds,
          totalQuizzesTaken: user.totalQuizzesTaken + 1,
          totalCorrectAnswers: user.totalCorrectAnswers + correctAnswers,
          averageScore: (user.totalCorrectAnswers + correctAnswers) /
              ((user.totalQuizzesTaken + 1) * totalQuestions) * 100,
        );

        await _userBox.put(userId, updatedUser);
        return updatedUser;
      }

      rethrow;
    }
  }

  // 更新登录天数
  Future<User?> updateLoginStreak(String userId) async {
    final user = _userBox.get(userId);
    if (user != null) {
      final updatedUser = User(
        id: user.id,
        username: user.username,
        email: user.email,
        perfectStreak: user.perfectStreak,
        loginStreak: user.loginStreak + 1,
        unlockedAchievementIds: user.unlockedAchievementIds,
        totalQuizzesTaken: user.totalQuizzesTaken,
        totalCorrectAnswers: user.totalCorrectAnswers,
        averageScore: user.averageScore,
      );

      await _userBox.put(userId, updatedUser);

      // TODO: 同步到服务器

      return updatedUser;
    }
    return null;
  }

  // 保存用户设置
  Future<void> saveUserSettings(String userId, Map<String, dynamic> settings) async {
    final settingsBox = Hive.box('settingsBox');
    await settingsBox.put(userId, settings);
  }

  // 获取用户设置
  Map<String, dynamic>? getUserSettings(String userId) {
    final settingsBox = Hive.box('settingsBox');
    return settingsBox.get(userId);
  }

  // 登录
  Future<User?> login(String username, String password) async {
    try {
      // TODO: 调用登录API
      // 模拟登录成功
      final mockUser = User(
        id: '1',
        username: username,
        email: '$username@example.com',
        perfectStreak: 3,
        loginStreak: 3,
        unlockedAchievementIds: ['1', '2'],
        totalQuizzesTaken: 10,
        totalCorrectAnswers: 45,
        averageScore: 90.0,
      );

      await _userBox.put(mockUser.id, mockUser);
      await _secureStorage.write(key: 'current_user_id', value: mockUser.id);
      await _secureStorage.write(key: 'auth_token', value: 'mock_token');

      return mockUser;
    } catch (e) {
      rethrow;
    }
  }

  // 登出
  Future<void> logout() async {
    await _secureStorage.delete(key: 'current_user_id');
    await _secureStorage.delete(key: 'auth_token');
  }
}