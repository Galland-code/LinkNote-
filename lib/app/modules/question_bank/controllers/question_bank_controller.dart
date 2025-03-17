import 'package:get/get.dart';
import '../../../data/models/question.dart';
import '../../../data/repositories/question_repository.dart';
import '../../../routes/app_routes.dart';
import '../../auth/controllers/userController.dart';
import '../../link_note/controllers/link_note_controller.dart';

class QuestionBankController extends GetxController {
  // 依赖注入
  final QuestionRepository _questionRepository = Get.find<QuestionRepository>();
  // 可观察变量
  final RxInt currentNavIndex = 2.obs;
  final RxList<Question> questions = <Question>[].obs;
  final RxMap<String, int> questionCounts = <String, int>{}.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedSource = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadQuestions();
  }

  // 加载问题
  Future<void> loadQuestions() async {
    try {
      isLoading.value = true;
      int userId = Get.find<UserController>().userId.value;
      questions.value = await _questionRepository.getWrongQuestionsFromApi(userId);
      print(questions);
      isLoading.value = false;
      errorMessage.value = '';

      // 计算统计信息
      calculateStats();
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = '加载问题失败: $e';
    }
  }

  // 计算统计信息
  void calculateStats() {
    // 创建来源到数量的映射
    Map<String, int> counts = {};

    for (var question in questions) {
      if (counts.containsKey(question.source)) {
        counts[question.source] = counts[question.source]! + 1;
      } else {
        counts[question.source] = 1;
      }
    }

    questionCounts.value = counts;
  }

  // 按来源筛选问题
  List<Question> getQuestionsBySource(String source) {
    if (source.isEmpty) {
      return questions;
    }
    return questions.where((q) => q.source == source).toList();
  }

  // 查看来源的问题
  void viewSourceQuestions(String source) {
    selectedSource.value = source;
    Get.toNamed(Routes.QUESTION_BANK_SOURCE);
  }

  // 查看问题详情
  void viewQuestionDetail(String id) {
    Get.toNamed(Routes.QUESTION_BANK_DETAIL, arguments: {'id': id});
  }
}
