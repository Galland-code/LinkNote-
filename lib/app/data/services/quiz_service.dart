import 'package:get/get.dart';
import '../models/question.dart';
import '../repositories/question_repository.dart';
import '../repositories/achievement_repository.dart';

class QuizService extends GetxService {
  final QuestionRepository _questionRepository = Get.find<QuestionRepository>();
  final AchievementRepository _achievementRepository = Get.find<AchievementRepository>();

  // 跟踪正确答题数
  final RxInt correctAnswers = 0.obs;
  final RxInt totalAnswered = 0.obs;
  final RxInt consecutiveCorrect = 0.obs;

  // 记录答题
  Future<bool> recordAnswer(String questionId, int selectedIndex) async {
    final question = _questionRepository.getQuestionsFromLocal()
        .firstWhere((q) => q.id == questionId, orElse: () => throw Exception('Question not found'));

    final isCorrect = question.correctOptionIndex == selectedIndex;

    totalAnswered.value++;

    if (isCorrect) {
      correctAnswers.value++;
      consecutiveCorrect.value++;

      // 检查连续答对成就
      if (consecutiveCorrect.value >= 3) {
        await _achievementRepository.unlockAchievement('1'); // 连续完美无错
        await _achievementRepository.updateAchievementValue('1', '${consecutiveCorrect.value}组');
      }
    } else {
      consecutiveCorrect.value = 0;
    }

    // 检查答题总数成就
    if (totalAnswered.value >= 100) {
      await _achievementRepository.unlockAchievement('3'); // 答题王
    } else {
      await _achievementRepository.updateAchievementValue('3', '${totalAnswered.value}/100');
    }

    // 计算错误率
    final errorRate = totalAnswered.value > 0
        ? (totalAnswered.value - correctAnswers.value) / totalAnswered.value * 100
        : 0.0;

    // 错误率低于5%，解锁成就
    if (totalAnswered.value >= 20 && errorRate <= 5.0) {
      await _achievementRepository.unlockAchievement('4'); // 关卡错误率
      await _achievementRepository.updateAchievementValue('4', '${errorRate.toStringAsFixed(1)}%');
    }

    return isCorrect;
  }

  // 获取当前的答题统计
  Map<String, dynamic> getQuizStats() {
    final errorRate = totalAnswered.value > 0
        ? (totalAnswered.value - correctAnswers.value) / totalAnswered.value * 100
        : 0.0;

    return {
      'totalAnswered': totalAnswered.value,
      'correctAnswers': correctAnswers.value,
      'consecutiveCorrect': consecutiveCorrect.value,
      'errorRate': errorRate.toStringAsFixed(1),
      'accuracy': totalAnswered.value > 0
          ? (correctAnswers.value / totalAnswered.value * 100).toStringAsFixed(1)
          : '0.0',
    };
  }

  // 重置统计
  void resetStats() {
    correctAnswers.value = 0;
    totalAnswered.value = 0;
    consecutiveCorrect.value = 0;
  }
}