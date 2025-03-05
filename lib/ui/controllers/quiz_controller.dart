import 'package:get/get.dart';
import '../../core/models/quiz_model.dart';
import '../../core/repository/quiz_repository.dart';
import '../../core/repository/user_repository.dart';

/// 测验控制器，管理测验相关状态和逻辑
class QuizController extends GetxController {
  final QuizRepository _quizRepository = Get.find<QuizRepository>();
  final UserRepository _userRepository = Get.find<UserRepository>();

  // 响应式状态变量
  final RxList<Quiz> quizzes = <Quiz>[].obs;
  final RxList<Quiz> currentQuiz = <Quiz>[].obs;
  final RxInt currentQuizIndex = 0.obs;
  final RxInt correctAnswers = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // 加载所有测验
  Future<void> loadQuizzes({bool forceRefresh = false}) async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final loadedQuizzes = await _quizRepository.getQuizzes(forceRefresh: forceRefresh);
      quizzes.assignAll(loadedQuizzes);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // 开始新的测验
  Future<void> startNewQuiz(int count) async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';
    currentQuizIndex.value = 0;
    correctAnswers.value = 0;

    try {
      final randomQuizzes = await _quizRepository.getRandomQuizzes(count);
      currentQuiz.assignAll(randomQuizzes);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // 检查答案
  Future<bool> checkAnswer(int answerIndex) async {
    if (currentQuizIndex.value >= currentQuiz.length) {
      return false;
    }

    final quiz = currentQuiz[currentQuizIndex.value];
    final isCorrect = await _quizRepository.checkAnswer(quiz.id, answerIndex);

    if (isCorrect) {
      correctAnswers.value++;
    }

    return isCorrect;
  }

  // 移动到下一题
  void nextQuestion() {
    if (currentQuizIndex.value < currentQuiz.length - 1) {
      currentQuizIndex.value++;
    } else {
      // 测验结束，更新用户统计
      _updateUserStatistics();
    }
  }

  // 更新用户统计
  Future<void> _updateUserStatistics() async {
    final user = await _userRepository.getCurrentUser();
    if (user != null) {
      await _userRepository.updateUserStatistics(
        user.id,
        correctAnswers.value,
        currentQuiz.length,
      );
    }
  }

  // 获取当前问题
  Quiz? get currentQuestion {
    if (currentQuiz.isEmpty || currentQuizIndex.value >= currentQuiz.length) {
      return null;
    }
    return currentQuiz[currentQuizIndex.value];
  }

  // 获取进度百分比
  double get progress {
    if (currentQuiz.isEmpty) return 0.0;
    return (currentQuizIndex.value + 1) / currentQuiz.length;
  }

  // 获取来源分布
  Map<String, int> getSourceDistribution() {
    return _quizRepository.getSourceDistribution();
  }

  // 按来源获取测验
  List<Quiz> getQuizzesBySource(String source) {
    return _quizRepository.getQuizzesBySource(source);
  }
}
