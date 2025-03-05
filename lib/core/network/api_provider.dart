import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/quiz_model.dart';
import '../models/achievement_model.dart';
import '../models/note_model.dart';
import '../models/user_model.dart';
import 'api_client.dart';
import 'api_constants.dart';

/// API提供者，封装所有网络请求
class ApiProvider {
  final ApiClient _apiClient = Get.find<ApiClient>();

  // 获取所有测验题
  Future<List<Quiz>> getQuizzes() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.quizzes);
      return (response.data as List).map((item) => Quiz.fromJson(item)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 获取随机测验题
  Future<List<Quiz>> getRandomQuizzes(int count) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.quizzes}/random',
        queryParameters: {'count': count},
      );
      return (response.data as List).map((item) => Quiz.fromJson(item)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 检查测验答案
  Future<bool> checkAnswer(String quizId, int answerIndex) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.quizzes}/$quizId/check',
        queryParameters: {'answerIndex': answerIndex},
      );
      return response.data['correct'] as bool;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 获取用户成就
  Future<List<Achievement>> getUserAchievements(String userId) async {
    try {
      final response = await _apiClient.dio.get('${ApiConstants.achievements}/user/$userId');
      return (response.data as List).map((item) => Achievement.fromJson(item)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 解锁成就
  Future<bool> unlockAchievement(String userId, String achievementId) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.achievements}/user/$userId/unlock/$achievementId',
      );
      return response.data['unlocked'] as bool;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 获取用户笔记
  Future<List<Note>> getUserNotes(String userId) async {
    try {
      final response = await _apiClient.dio.get('${ApiConstants.notes}/user/$userId');
      return (response.data as List).map((item) => Note.fromJson(item)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 创建笔记
  Future<Note> createNote(Note note) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.notes,
        data: note.toJson(),
      );
      return Note.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 更新用户统计数据
  Future<User> updateUserStatistics(String userId, int correctAnswers, int totalQuestions) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.users}/$userId/update-stats',
        queryParameters: {
          'correctAnswers': correctAnswers,
          'totalQuestions': totalQuestions,
        },
      );
      return User.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // 错误处理
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return Exception('网络连接超时，请检查网络');
      } else if (error.type == DioExceptionType.connectionError) {
        return Exception('网络连接错误，请检查网络');
      } else if (error.response != null) {
        final statusCode = error.response!.statusCode;
        final message = error.response!.data['message'] ?? '未知错误';

        if (statusCode == 401) {
          return Exception('登录已过期，请重新登录');
        } else if (statusCode == 403) {
          return Exception('没有权限访问该资源');
        } else if (statusCode == 404) {
          return Exception('请求的资源不存在');
        } else {
          return Exception('服务器错误：$message');
        }
      }
    }
    return Exception('网络请求失败，请重试');
  }
}
