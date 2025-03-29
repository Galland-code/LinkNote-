import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../data/models/question.dart';
import '../../../data/models/chaQuestion.dart';
import '../../../data/models/revenge_challenge.dart';
import '../../../data/repositories/question_repository.dart';
import '../../../routes/app_routes.dart';
import '../../auth/controllers/userController.dart';
import '../../link_note/controllers/link_note_controller.dart';
import '../../../data/models/wrong_analysis.dart';
import '../../quiz/controllers/quiz_controller.dart';

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

  // 复仇关卡相关变量
  final RxList<RevengeChallenge> revengeChallenges = <RevengeChallenge>[].obs;
  final RxBool isLoadingRevengeChallenges = false.obs;
  final RxBool showRevengeSection = true.obs; // 是否显示复仇关卡部分

  // 定义userid
  final RxString userId = ''.obs;
  @override
  void onInit() {
    super.onInit();
    loadQuestions();
    loadRevengeChallenges();
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
        Uri.parse(
          'http://82.157.18.189:8080/linknote/api/wrong-answers/wrong/analyse/$userId',
        ),
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

  // 加载复仇关卡
  Future<void> loadRevengeChallenges() async {
    try {
      isLoadingRevengeChallenges.value = true;

      // 首先尝试从QuizController获取复仇关卡数据
      if (Get.isRegistered<QuizController>()) {
        final quizController = Get.find<QuizController>();
        if (quizController.revengeChallenges.isNotEmpty) {
          revengeChallenges.value = quizController.revengeChallenges;
          showRevengeSection.value = true; // 确保这里设置为true
        } else {
          // 如果没有，则从API获取
          await _loadRevengeChallengesFromApi();
        }
      } else {
        await _loadRevengeChallengesFromApi();
      }

      // 如果加载到了复仇关卡，确保显示复仇区域
      if (revengeChallenges.isNotEmpty) {
        showRevengeSection.value = true;
      }
    } catch (e) {
      print('加载复仇关卡失败: $e');
    } finally {
      isLoadingRevengeChallenges.value = false;
    }
  }

  // 从API加载复仇关卡
  Future<void> _loadRevengeChallengesFromApi() async {
    try {
      int userId = Get.find<UserController>().userId.value;
      final response = await http.get(
        Uri.parse(
          'http://82.157.18.189:8080/linknote/api/revenge-challenges/$userId',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));

        if (data is List) {
          revengeChallenges.value =
              data.map((item) => RevengeChallenge.fromJson(item)).toList();
        }
      }
    } catch (e) {
      print('从API加载复仇关卡失败: $e');
    }
  }

  // 开始复仇关卡
  void startRevengeChallenge(RevengeChallenge challenge) {
    final quizController = Get.find<QuizController>();

    // 构建挑战对象
    final challengeData = {
      'id': challenge.id,
      'title': challenge.title,
      'source': challenge.category,
      'questionCount': challenge.questions.length,
      'completedCount': challenge.completedCount,
      'date': challenge.createdAt,
      'questions': challenge.questions,
      'levels': challenge.questions,
    };

    // 导航到关卡页面
    Get.toNamed(Routes.QUIZ_LEVELS, arguments: {'challenge': challengeData});
  }

  // 生成新的复仇关卡
  Future<void> generateNewRevengeChallenge() async {
    try {
      isLoading.value = true;

      // 获取错题分析数据
      await fetchWrongAnalysis();

      if (wrongAnalysis.value != null &&
          wrongAnalysis.value!.weakCategories.isNotEmpty) {
        // 选择第一个薄弱类别
        final weakCategory = wrongAnalysis.value!.weakCategories.first;

        // 从错题集中筛选该类别的题目
        List<Question> categoryQuestions =
            questions
                .where(
                  (q) => q.source.toLowerCase().contains(
                    weakCategory.toLowerCase(),
                  ),
                )
                .toList();

        if (categoryQuestions.isNotEmpty) {
          // 转换为chaQuestion类型
          List<chaQuestion> chaQuestions =
              categoryQuestions
                  .map(
                    (q) => chaQuestion(
                      id: int.tryParse(q.id) ?? 0,
                      source: q.source,
                      content: q.content,
                      answer: q.correctOptionIndex,
                      type: q.type,
                      difficulty: q.difficulty,
                      sourceId: q.sourceId,
                      category: q.category,
                    ),
                  )
                  .toList();

          // 创建复仇关卡
          final revengeChallenge = RevengeChallenge(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: '${weakCategory}知识点强化',
            category: weakCategory,
            createdAt: DateTime.now(),
            questions: chaQuestions,
            difficultyLevel: 2,
            weaknessDescription: '针对${weakCategory}知识点的薄弱环节定制训练',
          );

          // 添加到复仇关卡列表
          revengeChallenges.add(revengeChallenge);

          // 开始挑战
          startRevengeChallenge(revengeChallenge);
        } else {
          Get.snackbar('提示', '没有足够的错题生成复仇关卡');
        }
      } else {
        Get.snackbar('提示', '请先完成一些题目，以便系统分析您的薄弱点');
      }
    } catch (e) {
      print('生成复仇关卡失败: $e');
      Get.snackbar('错误', '生成关卡失败，请稍后再试');
    } finally {
      isLoading.value = false;
    }
  }

  // 添加复仇关卡
  void addRevengeChallenge(RevengeChallenge challenge) {
    // 检查是否已存在相同ID的关卡
    if (!revengeChallenges.any((c) => c.id == challenge.id)) {
      revengeChallenges.add(challenge);
      showRevengeSection.value = true;
      update(); // 通知UI更新
      print('成功添加复仇关卡: ${challenge.title}');
    } else {
      print('复仇关卡已存在: ${challenge.id}');
    }
  }
}
