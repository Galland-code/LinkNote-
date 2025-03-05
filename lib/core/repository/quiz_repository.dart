import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/quiz_model.dart';
import '../network/api_provider.dart';

/// 测验仓库，处理测验数据的获取和存储
class QuizRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final Box<Quiz> _quizBox = Hive.box<Quiz>('quizBox');

  // 获取所有测验题
  Future<List<Quiz>> getQuizzes({bool forceRefresh = false}) async {
    // 如果不强制刷新且本地有数据，则返回本地数据
    if (!forceRefresh && _quizBox.isNotEmpty) {
      return _quizBox.values.toList();
    }

    try {
      // 从服务器获取数据
      final quizzes = await _apiProvider.getQuizzes();

      // 清空本地数据并存储新数据
      await _quizBox.clear();
      for (var quiz in quizzes) {
        await _quizBox.put(quiz.id, quiz);
      }

      return quizzes;
    } catch (e) {
      // 如果网络请求失败但本地有数据，返回本地数据
      if (_quizBox.isNotEmpty) {
        return _quizBox.values.toList();
      }
      rethrow;
    }
  }

  // 获取随机测验题
  Future<List<Quiz>> getRandomQuizzes(int count) async {
    try {
      // 优先从服务器获取随机测验题
      return await _apiProvider.getRandomQuizzes(count);
    } catch (e) {
      // 如果网络请求失败，尝试从本地随机选择
      if (_quizBox.isNotEmpty) {
        final allQuizzes = _quizBox.values.toList();
        allQuizzes.shuffle();
        return allQuizzes.take(count).toList();
      }
      rethrow;
    }
  }

  // 获取特定来源的测验题
  List<Quiz> getQuizzesBySource(String source) {
    return _quizBox.values
        .where((quiz) => quiz.source == source)
        .toList();
  }

  // 检查答案
  Future<bool> checkAnswer(String quizId, int answerIndex) async {
    try {
      // 优先使用在线检查
      return await _apiProvider.checkAnswer(quizId, answerIndex);
    } catch (e) {
      // 如果网络请求失败，使用本地检查
      final quiz = _quizBox.get(quizId);
      if (quiz != null) {
        return quiz.correctAnswer == answerIndex;
      }
      rethrow;
    }
  }

  // 获取来源分布统计
  Map<String, int> getSourceDistribution() {
    final distribution = <String, int>{};
    for (var quiz in _quizBox.values) {
      distribution[quiz.source] = (distribution[quiz.source] ?? 0) + 1;
    }
    return distribution;
  }
}
