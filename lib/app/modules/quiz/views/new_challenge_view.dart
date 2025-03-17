// import 'package:get/get.dart';
// import '../../../data/models/question.dart';
// import '../../../data/models/note.dart';
// import '../../../data/repositories/question_repository.dart';
// import '../../../data/repositories/note_repository.dart';
// import '../../../data/services/quiz_service.dart';
// import '../../../routes/app_routes.dart';
//
// class QuizController extends GetxController {
//   // Dependencies
//   final QuestionRepository _questionRepository = Get.find<QuestionRepository>();
//   final NoteRepository _noteRepository = Get.find<NoteRepository>();
//   final QuizService _quizService = Get.find<QuizService>();
//
//   // Observable variables
//   final RxInt currentNavIndex = 1.obs;
//   final RxList<Question> questions = <Question>[].obs;
//   final RxBool isLoading = false.obs;
//   final RxString errorMessage = ''.obs;
//
//   // Challenge generation
//   final RxList<Note> notes = <Note>[].obs;
//   final RxList<String> categories = <String>[].obs;
//   final RxString selectedCategory = ''.obs;  // 选择的笔记分类
//   final Rx<Note?> selectedNote = Rx<Note?>(null);  // 选择的笔记
//
//   // Challenge history
//   final RxList<Map<String, dynamic>> challengeHistory = <Map<String, dynamic>>[].obs;
//
//   // Current question state
//   final RxInt currentQuestionIndex = 0.obs;
//   final RxBool isAnswered = false.obs;
//   final RxInt selectedAnswerIndex = (-1).obs;
//
//   // Statistics
//   final RxMap<String, dynamic> quizStats = <String, dynamic>{}.obs;
//
//   // 筛选的分类
//   final RxString selectedCategoryFilter = ''.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     loadQuestions();
//     loadNotes();
//     loadChallengeHistory();
//     updateQuizStats();
//   }
//
//   // 加载所有问题
//   Future<void> loadQuestions() async {
//     try {
//       isLoading.value = true;
//       questions.value = await _questionRepository.getQuestions(userId);
//       isLoading.value = false;
//       errorMessage.value = '';
//     } catch (e) {
//       isLoading.value = false;
//       errorMessage.value = '加载问题失败: $e';
//     }
//   }
//
//   // 加载笔记
//   Future<void> loadNotes() async {
//     try {
//       isLoading.value = true;
//       notes.value = await _noteRepository.getNotes();
//
//       // 提取唯一分类
//       final Set<String> categorySet = {};
//       for (var note in notes) {
//         categorySet.add(note.category);
//       }
//       categories.value = categorySet.toList();
//
//       isLoading.value = false;
//     } catch (e) {
//       isLoading.value = false;
//       errorMessage.value = '加载笔记失败: $e';
//     }
//   }
//
//   // 加载挑战历史
//   void loadChallengeHistory() {
//     // 在真实的应用中，这将从数据库获取数据
//     // 目前使用模拟数据
//     challengeHistory.value = [
//       {
//         'id': '1',
//         'title': '计组复习笔记 - 挑战1',
//         'source': '计组复习笔记',
//         'questionCount': 10,
//         'completedCount': 7,
//         'date': DateTime.now().subtract(Duration(days: 1)),
//         'questions': [], // 包含实际问题
//         'levels': 2,
//         'createdAt': '2024',
//       },
//       {
//         'id': '2',
//         'title': '测试理论 - 挑战2',
//         'source': '测试理论笔记',
//         'questionCount': 8,
//         'completedCount': 4,
//         'date': DateTime.now().subtract(Duration(days: 3)),
//         'questions': [], // 包含实际问题
//         'levels': 2,
//         'createdAt': '2024',
//       },
//       {
//         'id': '3',
//         'title': '所有笔记 - 随机挑战',
//         'source': '多个来源',
//         'questionCount': 15,
//         'completedCount': 15,
//         'date': DateTime.now().subtract(Duration(days: 5)),
//         'questions': [], // 包含实际问题
//         'levels': 2,
//         'createdAt': '2024',
//       },
//     ];
//   }
//
//   // 更新答题统计
//   void updateQuizStats() {
//     quizStats.value = _quizService.getQuizStats();
//   }
//
//   // 选择挑战的分类
//   void selectCategory(String category) {
//     selectedCategory.value = category;
//     selectedNote.value = null;
//   }
//
//   // 选择特定的笔记
//   void selectNote(Note note) {
//     selectedNote.value = note;
//     selectedCategory.value = note.category;
//   }
//
//   // 生成新的挑战
//   Future<void> generateChallenge() async {
//     try {
//       isLoading.value = true;
//
//       List<Question> challengeQuestions = [];
//       String challengeTitle = '';
//
//       if (selectedNote.value != null) {
//         // 根据选定的笔记生成挑战
//         challengeTitle = '${selectedNote.value!.title} - 挑战';
//         // challengeQuestions = await _questionRepository.getQuestionsFromNoteContent(selectedNote.value!);
//       } else if (selectedCategory.value.isNotEmpty) {
//         // 根据选定的分类生成挑战
//         challengeTitle = '${selectedCategory.value} - 分类挑战';
//         // challengeQuestions = await _questionRepository.getQuestionsFromCategory(selectedCategory.value);
//       } else {
//         // 如果未选择笔记或分类，则随机生成挑战
//         challengeTitle = '随机挑战';
//         challengeQuestions = questions.toList()..shuffle();
//         challengeQuestions = challengeQuestions.take(10).toList();
//       }
//
//       final challenge = {
//         'id': DateTime.now().millisecondsSinceEpoch.toString(),
//         'title': challengeTitle,
//         'source': selectedNote.value != null
//             ? selectedNote.value!.title
//             : selectedCategory.value.isNotEmpty
//             ? selectedCategory.value
//             : '多个来源',
//         'questionCount': challengeQuestions.length,
//         'completedCount': 0,
//         'date': DateTime.now(),
//         'questions': challengeQuestions,
//         'levels': challengeQuestions,
//       };
//
//       challengeHistory.insert(0, challenge);
//
//       isLoading.value = false;
//
//       questions.value = challengeQuestions;
//       currentQuestionIndex.value = 0;
//       isAnswered.value = false;
//       selectedAnswerIndex.value = -1;
//
//       Get.toNamed(Routes.QUIZ_LEVELS, arguments: {'challenge': challenge});
//     } catch (e) {
//       isLoading.value = false;
//       errorMessage.value = '生成挑战失败: $e';
//     }
//   }
//
//   // 继续已有的挑战
//   void continueChallenge(Map<String, dynamic> challenge) {
//     questions.value = List<Question>.from(challenge['questions']);
//     currentQuestionIndex.value = challenge['completedCount'];
//     isAnswered.value = false;
//     selectedAnswerIndex.value = -1;
//
//     if (challenge['completedCount'] < challenge['questionCount']) {
//       Get.toNamed(Routes.QUIZ_QUESTION);
//     } else {
//       Get.toNamed(Routes.QUIZ_LEVELS, arguments: {'challenge': challenge});
//     }
//   }
//
//   // 答题
//   Future<void> answerQuestion(int index) async {
//     if (isAnswered.value) return;
//
//     isAnswered.value = true;
//     selectedAnswerIndex.value = index;
//
//     final currentQuestion = questions[currentQuestionIndex.value];
//     final isCorrect = await _quizService.recordAnswer(currentQuestion.id, index);
//
//     updateQuizStats();
//
//     if (challengeHistory.isNotEmpty) {
//       final challengeIndex = challengeHistory.indexWhere((c) => c['questions'] == questions.value || (c['questionCount'] == questions.length && c['title'].contains(currentQuestion.source)));
//
//       if (challengeIndex >= 0) {
//         final challenge = challengeHistory[challengeIndex];
//         challenge['completedCount'] = currentQuestionIndex.value + 1;
//         challengeHistory[challengeIndex] = challenge;
//       }
//     }
//
//     await Future.delayed(Duration(seconds: 1));
//     nextQuestion();
//   }
//
//   // 下一题
//   void nextQuestion() {
//     if (currentQuestionIndex.value < questions.length - 1) {
//       currentQuestionIndex.value++;
//       isAnswered.value = false;
//       selectedAnswerIndex.value = -1;
//     } else {
//       Get.toNamed(Routes.QUIZ_RESULT);
//     }
//   }
// }
