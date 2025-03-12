import 'package:get/get.dart';
import '../../../data/models/question.dart';
import '../../../data/models/note.dart';
import '../../../data/repositories/question_repository.dart';
import '../../../data/repositories/note_repository.dart';
import '../../../data/services/quiz_service.dart';
import '../../../routes/app_routes.dart';

class QuizController extends GetxController {
  // Dependencies
  final QuestionRepository _questionRepository = Get.find<QuestionRepository>();
  final NoteRepository _noteRepository = Get.find<NoteRepository>();
  final QuizService _quizService = Get.find<QuizService>();

  // Observable variables
  final RxInt currentNavIndex = 1.obs;
  final RxList<Question> questions = <Question>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Challenge generation
  final RxList<Note> notes = <Note>[].obs;
  final RxList<String> categories = <String>[].obs;
  final RxString selectedCategory = ''.obs;
  final RxString selectedNoteId = ''.obs;
  final RxString selectedDifficulty = '简单'.obs;//默认简单

  // Challenge history
  final RxList<Map<String, dynamic>> challengeHistory = <Map<String, dynamic>>[].obs;

  // Current question state
  final RxInt currentQuestionIndex = 0.obs;
  final RxBool isAnswered = false.obs;
  final RxInt selectedAnswerIndex = (-1).obs;

  // Timer
  final RxInt timer = 60.obs;  // Timer for each question
  late Rxn<int> timerInterval; // Interval for timer updating

  // Statistics
  final RxMap<String, dynamic> quizStats = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadQuestions();
    loadNotes();
    loadChallengeHistory();
    updateQuizStats();
    startTimer();
  }

  // Load all questions
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

  // Load all notes for selection
  Future<void> loadNotes() async {
    try {
      isLoading.value = true;
      notes.value = await _noteRepository.getNotes();

      // Extract unique categories
      final Set<String> categorySet = {};
      for (var note in notes) {
        categorySet.add(note.category);
      }
      categories.value = categorySet.toList();

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = '加载笔记失败: $e';
    }
  }

  // Load challenge history
  void loadChallengeHistory() {
    // In a real app, this would fetch from the database
    // Mock data for now
    challengeHistory.value = [
      {
        'id': '1',
        'title': '计组复习笔记 - 挑战1',
        'source': '计组复习笔记',
        'questionCount': 10,
        'completedCount': 7,
        'date': DateTime.now().subtract(Duration(days: 1)),
        'questions': [], // Would contain actual questions
        'levels': 2,
        'createdAt': '2024',
      },
      {
        'id': '2',
        'title': '测试理论 - 挑战2',
        'source': '测试理论笔记',
        'questionCount': 8,
        'completedCount': 4,
        'date': DateTime.now().subtract(Duration(days: 3)),
        'questions': [], // Would contain actual questions
        'levels': 2,
        'createdAt': '2024',
      },
      {
        'id': '3',
        'title': '所有笔记 - 随机挑战',
        'source': '多个来源',
        'questionCount': 15,
        'completedCount': 15,
        'date': DateTime.now().subtract(Duration(days: 5)),
        'questions': [], // Would contain actual questions
        'levels': 2,
        'createdAt': '2024',
      },
    ];
  }

  // Update quiz statistics
  void updateQuizStats() {
    quizStats.value = _quizService.getQuizStats();
  }

  // Select category for challenge
  void selectCategory(String category) {
    selectedCategory.value = category;
    selectedNoteId.value = '';
  }

  // Select specific note for challenge
  void selectNote(String noteId) {
    selectedNoteId.value = noteId;
    final note = notes.firstWhere((n) => n.id == noteId, orElse: () => notes.first);
    selectedCategory.value = note.category;
  }

  // Generate a new challenge based on selection
  Future<void> generateChallenge() async {
    try {
      isLoading.value = true;

      List<Question> challengeQuestions = [];
      String challengeTitle = '';

      if (selectedNoteId.value.isNotEmpty) {
        final note = notes.firstWhere((n) => n.id == selectedNoteId.value);
        challengeTitle = '${note.title} - 挑战';
        challengeQuestions = await _questionRepository.getQuestionsFromNoteContent(note);
      } else if (selectedCategory.value.isNotEmpty) {
        challengeTitle = '${selectedCategory.value} - 分类挑战';
        challengeQuestions = await _questionRepository.getQuestionsFromCategory(selectedCategory.value);
      } else {
        challengeTitle = '随机挑战';
        challengeQuestions = questions.toList()..shuffle();
        challengeQuestions = challengeQuestions.take(10).toList();
      }

      final challenge = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': challengeTitle,
        'source': selectedNoteId.value.isNotEmpty
            ? notes.firstWhere((n) => n.id == selectedNoteId.value).title
            : selectedCategory.value.isNotEmpty ? selectedCategory.value : '多个来源',
        'questionCount': challengeQuestions.length,
        'completedCount': 0,
        'date': DateTime.now(),
        'questions': challengeQuestions,
        'levels': challengeQuestions,
      };

      challengeHistory.insert(0, challenge);

      isLoading.value = false;

      questions.value = challengeQuestions;
      currentQuestionIndex.value = 0;
      isAnswered.value = false;
      selectedAnswerIndex.value = -1;

      Get.toNamed(Routes.QUIZ_LEVELS, arguments: {'challenge': challenge});
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = '生成挑战失败: $e';
    }
  }

  // Continue an existing challenge
  void continueChallenge(Map<String, dynamic> challenge) {
    questions.value = List<Question>.from(challenge['questions']);
    currentQuestionIndex.value = challenge['completedCount'];
    isAnswered.value = false;
    selectedAnswerIndex.value = -1;

    if (challenge['completedCount'] < challenge['questionCount']) {
      Get.toNamed(Routes.QUIZ_QUESTION);
    } else {
      Get.toNamed(Routes.QUIZ_LEVELS, arguments: {'challenge': challenge});
    }
  }

  // Answer current question
  Future<void> answerQuestion(int index) async {
    if (isAnswered.value) return;

    isAnswered.value = true;
    selectedAnswerIndex.value = index;

    final currentQuestion = questions[currentQuestionIndex.value];
    final isCorrect = await _quizService.recordAnswer(currentQuestion.id, index);

    updateQuizStats();

    if (challengeHistory.isNotEmpty) {
      final challengeIndex = challengeHistory.indexWhere((c) => c['questions'] == questions.value || (c['questionCount'] == questions.length && c['title'].contains(currentQuestion.source)));

      if (challengeIndex >= 0) {
        final challenge = challengeHistory[challengeIndex];
        challenge['completedCount'] = currentQuestionIndex.value + 1;
        challengeHistory[challengeIndex] = challenge;
      }
    }

    await Future.delayed(Duration(seconds: 1));
    nextQuestion();
  }

  // Move to next question
  void nextQuestion() {
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      isAnswered.value = false;
      selectedAnswerIndex.value = -1;
    } else {
      Get.toNamed(Routes.QUIZ_RESULT);
    }
  }

  // Start new challenge
  void startNewChallenge() {}

  // Start a timer for each question
  void startTimer() {
    timerInterval = Rxn<int>();
    timerInterval.value = 60;

    timerInterval.listen((count) {
      if (count != null && count > 0) {
        timer.value = count - 1;
      }
    });

    // Simulate timer decrement every second
    Future.delayed(Duration(seconds: 1), () => startTimer());
  }

}
