import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../data/models/question.dart';
import '../../../data/repositories/question_repository.dart';
import '../../../routes/app_routes.dart';
import '../../auth/controllers/userController.dart';
import '../../link_note/controllers/link_note_controller.dart';
import '../../../data/models/wrong_analysis.dart';

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
  late RxBool isLoadingAnalysis = false.obs;
  final Rx<WrongAnalysis?> wrongAnalysis = Rx<WrongAnalysis?>(null);

  // 定义userid
  final RxString userId = ''.obs;
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
      questions.value = await _questionRepository.getWrongQuestionsFromApi(
        userId,
      );
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

  // 获取分析
  Future<void> fetchWrongAnalysis() async {
    isLoadingAnalysis = true.obs;
    this.userId.value =
        Get.find<UserController>().userId.value.toString(); // 设置 userId

    try {
    isLoadingAnalysis.value = true;
    final response = await http.get(
      Uri.parse('http://82.157.18.189:8080/linknote/api/wrong-answers/wrong/analyse/$userId'),
    );
    isLoadingAnalysis = false.obs;

    if (response.statusCode == 200) {
      // 使用 utf8 解码响应数据
      final data = json.decode(utf8.decode(response.bodyBytes));
      wrongAnalysis.value = WrongAnalysis.fromJson(data);
    } else {
      Get.snackbar('错误', '获取分析报告失败');
    }
  } catch (e) {
    Get.snackbar('错误', '网络请求失败');
  } finally {
    isLoadingAnalysis.value = false;
  }
  }
}
