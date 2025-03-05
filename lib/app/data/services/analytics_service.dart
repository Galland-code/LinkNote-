import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';

/// 用户行为分析服务，记录用户操作和事件
class AnalyticsService extends GetxService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // 记录页面访问
  Future<void> logScreen(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  // 记录登录事件
  Future<void> logLogin(String loginMethod) async {
    await _analytics.logLogin(loginMethod: loginMethod);
  }

  // 记录注册事件
  Future<void> logSignUp(String signUpMethod) async {
    await _analytics.logSignUp(signUpMethod: signUpMethod);
  }

  // 记录自定义事件
  Future<void> logEvent(String name, Map<String, dynamic> parameters) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  // 记录搜索事件
  Future<void> logSearch(String searchTerm) async {
    await _analytics.logSearch(searchTerm: searchTerm);
  }

  // 记录内容查看事件
  Future<void> logViewContent({
    required String contentType,
    required String itemId,
  }) async {
    await _analytics.logViewItem(
      items: [AnalyticsEventItem(itemId: itemId)],
      itemListId: contentType,
    );
  }

  // 记录成就解锁事件
  Future<void> logAchievementUnlocked(String achievementId) async {
    await _analytics.logEvent(
      name: 'achievement_unlocked',
      parameters: {
        'achievement_id': achievementId,
      },
    );
  }

  // 记录测验完成事件
  Future<void> logQuizCompleted({
    required String quizId,
    required int score,
    required int questionCount,
  }) async {
    await _analytics.logEvent(
      name: 'quiz_completed',
      parameters: {
        'quiz_id': quizId,
        'score': score,
        'question_count': questionCount,
        'completion_rate': score / questionCount,
      },
    );
  }
}