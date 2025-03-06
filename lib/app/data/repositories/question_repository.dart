import 'package:get/get.dart';
import '../models/question.dart';
import '../providers/api_provider.dart';
import '../services/database_service.dart';
import '../../../core/values/app_constants.dart';

class QuestionRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final DatabaseService _databaseService = Get.find<DatabaseService>();

  // 从API获取所有问题
  Future<List<Question>> getQuestionsFromApi() async {
    try {
      final response = await _apiProvider.get(AppConstants.GET_QUESTIONS);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final List<Question> questions = data.map((item) => Question(
          id: item['id'],
          source: item['source'],
          content: item['content'],
          options: List<String>.from(item['options']),
          correctOptionIndex: item['correctOptionIndex'],
        )).toList();

        // 保存到本地数据库
        await _databaseService.saveQuestions(questions);

        return questions;
      } else {
        throw Exception('Failed to load questions');
      }
    } catch (e) {
      // 如果API请求失败，使用本地数据
      return _databaseService.getAllQuestions();
    }
  }

  // 从本地数据库获取所有问题
  List<Question> getQuestionsFromLocal() {
    return _databaseService.getAllQuestions();
  }

  // 获取问题（先尝试API，失败则用本地）
  Future<List<Question>> getQuestions() async {
    try {
      return await getQuestionsFromApi();
    } catch (e) {
      return getQuestionsFromLocal();
    }
  }

  // 保存问题到本地
  Future<void> saveQuestion(Question question) async {
    await _databaseService.saveQuestion(question);
  }

  // 删除问题
  Future<void> deleteQuestion(String id) async {
    await _databaseService.deleteQuestion(id);
  }
}
