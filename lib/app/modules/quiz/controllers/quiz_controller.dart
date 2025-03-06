import 'package:get/get.dart';
import '../../../data/models/question.dart';
import '../../../data/repositories/question_repository.dart';
import '../../../data/services/quiz_service.dart';
import '../../../routes/app_routes.dart';

class QuizController extends GetxController {
  // 依赖注入
  final QuestionRepository _questionRepository = Get.find<QuestionRepository>();
  final QuizService _quizService = Get.find<QuizService>();

  // 可观察变量
  final RxInt currentNavIndex = 1.obs;
  final RxList<Question> questions = <Question>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // 当前问题状态
  final RxInt currentQuestionIndex = 0.obs;
  final RxBool isAnswered = false.obs;
  final RxInt selectedAnswerIndex = (-1).obs;

  // 统计信息
  final RxMap<String, dynamic> quizStats = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadQuestions();
    updateQuizStats();
  }

  // 加载问题
  Future<void> loadQuestions() async {
    try {
      isLoading.value = true;
      questions.value = await _questionRepository.getQuestions();
      isLoading.value = false;
      errorMessage.value = '';
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = '加载问题失败: $e';
    }
  }

  // 更新答题统计
  void updateQuizStats() {
    quizStats.value = _quizService.getQuizStats();
  }

  // 开始新挑战
  void startNewChallenge() {
    // 重置统计
    _quizService.resetStats();
    updateQuizStats();

    // 重置当前问题
    currentQuestionIndex.value = 0;
    isAnswered.value = false;
    selectedAnswerIndex.value = -1;

    // 导航到问题页面
    Get.toNamed(Routes.QUIZ_QUESTION);
  }

  // 继续答题
  void continueQuiz() {
    // 从上次中断的地方继续
    Get.toNamed(Routes.QUIZ_QUESTION);
  }

  // 查看历史记录
  void viewHistory() {
    Get.toNamed(Routes.QUIZ_HISTORY);
  }

  // 回答问题
  Future<void> answerQuestion(int index) async {
    if (isAnswered.value) return;

    isAnswered.value = true;
    selectedAnswerIndex.value = index;

    // 记录答题
    final currentQuestion = questions[currentQuestionIndex.value];
    final isCorrect = await _quizService.recordAnswer(
        currentQuestion.id,
        index
    );

    updateQuizStats();

    // 延迟后进入下一题
    await Future.delayed(Duration(seconds: 1));
    nextQuestion();
  }

  // 下一题
  void nextQuestion() {
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      isAnswered.value = false;
      selectedAnswerIndex.value = -1;
    } else {
      // 已完成所有问题
      Get.toNamed(Routes.QUIZ_RESULT);
    }
  }
}
