import 'package:get/get.dart';
import 'package:linknote/app/data/models/pdf_document.dart';
import '../models/note.dart';
import '../models/question.dart';
import '../providers/api_provider.dart';
import '../services/database_service.dart';
import '../../../core/values/app_constants.dart';

class QuestionRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final DatabaseService _databaseService = Get.find<DatabaseService>();

  // 从API获取错误问题
  Future<List<Question>> getWrongQuestionsFromApi(int userId) async {
    try {
      final response = await _apiProvider.get(
        'http://82.157.18.189:8080/linknote/api/wrong-answers/page/$userId', // 更新为正确的 API 路径
      );
      if (response.statusCode == 200) {
        print("access successful");
        final Map<String, dynamic> responseData = response.data;

        if (responseData['content'] == null) {
          print("Content is null in response data");
          return [];
        }

        final List<dynamic> data = responseData['content'];
        final List<Question> questions = [];
        print("question还未赋值");
        for (var item in data) {
          try {
            if (item['question'] != null && item['pdfDocument1'] != null) {
              questions.add(Question.fromJson(item));
              print("question增加");
              print(questions);
            } else {
              print("Skipping item due to null question or document: $item");
            }
          } catch (e) {
            print("Error parsing item: $e, Item: $item");
          }
        }
        print("question结束");
        // 保存到本地数据库
        await _databaseService.saveQuestions(questions);
        print("保存成功");
        return questions;
      } else {
        print("access failed: ${response.statusCode}");
        throw Exception('Failed to load questions');
      }
    } catch (e) {
      print("Error in getWrongQuestionsFromApi: $e");

      return _databaseService.getAllQuestions();
    }
  }

  Future<List<Question>> getQuestionsFromApi(int userId) async {
    try {
      final response = await _apiProvider.get(
        '${AppConstants.BASE_URL}${AppConstants.CHALLENGE}/$userId/unanswered',
      );
      if (response.statusCode == 200) {
        print("access successful");
        final Map<String, dynamic> responseData = response.data;
        print(response.data);
        final List<dynamic> data = responseData['content']; // 从 content 中获取问题列表
        final List<Question> questions =
            data.map((item) => Question.fromJson(item)).toList();
        // 保存到本地数据库
        await _databaseService.saveQuestions(questions);

        return questions;
      } else {
        print("access failed");
        throw Exception('Failed to load questions');
      }
    } catch (e) {
      // 如果 API 请求失败，使用本地数据
      return _databaseService.getAllQuestions();
    }
  }

  // 从本地数据库获取所有问题
  List<Question> getQuestionsFromLocal() {
    return _databaseService.getAllQuestions();
  }

  // 获取问题（先尝试API，失败则用本地）
  Future<List<Question>> getQuestions(userId) async {
    try {
      print("访问API");
      return await getWrongQuestionsFromApi(userId);
    } catch (e) {
      print(e);
      print("use local");
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

  // 根据笔记内容生成问题
  Future<List<Question>> getQuestionsFromNoteContent(PdfDocument note) async {
    try {
      // 在实际应用中，这部分会通过API调用后端服务来处理笔记内容生成问题
      // 这里我们使用模拟数据

      List<Question> mockQuestions = [];

      // 生成5-10个问题
      final questionCount = 5 + (note.fileName.length % 6); // 5-10个问题

      for (int i = 0; i < questionCount; i++) {
        mockQuestions.add(
          Question(
            id: 'note_${note.id}_question_$i',
            content: '关于"${note.fileName}"的问题 ${i + 1}',
            options: [
              '选项A - ${note.fileName.substring(0, note.fileName.length > 3 ? 3 : note.fileName.length)}',
              '选项B - ${note.fileName}',
              '选项C - ${note.category}',
              '选项D - 以上都不对',
            ],
            correctOptionIndex: 'A', // 简单的模式用于模拟数据
            source: note.fileName,
            type: '',
            difficulty: '简单',
            sourceId: 1,
            category: '选择题',
          ),
        );
      }

      return mockQuestions;
    } catch (e) {
      print('从笔记生成问题时出错: $e');
      // 失败时返回空列表
      return [];
    }
  }

  //根据笔记分类生成问题
  Future<List<Question>> getQuestionsFromCategory(String category) async {
    try {
      // 获取所有可能具有此类别/来源的问题
      final allQuestions = _databaseService.getAllQuestions();

      // 根据类别/来源筛选问题
      final categoryQuestions =
          allQuestions
              .where(
                (q) =>
                    q.category.toLowerCase().contains(category.toLowerCase()),
              )
              .toList();

      // 如果数据库中有足够的问题，使用这些问题
      if (categoryQuestions.length >= 5) {
        categoryQuestions.shuffle();
        return categoryQuestions.take(5).toList();
      }

      // 否则，生成模拟问题
      List<Question> mockQuestions = List.from(categoryQuestions);

      // 添加更多问题，至少达到5个
      for (int i = categoryQuestions.length; i < 5; i++) {
        mockQuestions.add(
          Question(
            id: 'category_${category}_question_$i',
            content: '关于"${category}"的问题 ${i + 1}',
            options: [
              '选项A - ${category}相关',
              '选项B - ${category}理论',
              '选项C - ${category}应用',
              '选项D - 以上都不对',
            ],
            correctOptionIndex: 'A',
            source: '人工智能导论',
            type: '选择题',
            difficulty: '简单',
            sourceId: 1,
            category: '人工智能',
          ),
        ); // 简单的模式用于模拟数据
      }

      return mockQuestions;
    } catch (e) {
      print('从分类生成问题时出错: $e');
      // 失败时返回空列表
      return [];
    }
  }
}
