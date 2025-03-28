// lib/app/data/services/database_service.dart - 注意模块
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/question.dart';
import '../models/note.dart';
import '../models/achievement.dart';
import '../../../core/values/app_constants.dart';

class DatabaseService extends GetxService {
  late Box<Question> questionsBox;
  late Box<Note> notesBox;
  late Box<Achievement> achievementsBox;
  late Box userBox;
  late Box syncStatusBox;

  Future<DatabaseService> init() async {
    // 打开所有需要的盒子
    questionsBox = await Hive.openBox<Question>(AppConstants.QUESTIONS_BOX);
    notesBox = await Hive.openBox<Note>(AppConstants.NOTES_BOX);
    achievementsBox = await Hive.openBox<Achievement>(
      AppConstants.ACHIEVEMENTS_BOX,
    );
    userBox = await Hive.openBox(AppConstants.USER_BOX);
    syncStatusBox = await Hive.openBox(AppConstants.SYNC_STATUS_BOX);

    return this;
  }


  // 笔记相关方法
  Future<void> saveNote(Note note) async {
    await notesBox.put(note.id, note);
  }

  Future<void> saveNotes(List<Note> notes) async {
    final Map<String, Note> notesMap = {};
    for (var note in notes) {
      notesMap[note.id] = note;
    }
    await notesBox.putAll(notesMap);
  }

  List<Note> getAllNotes() {
    return notesBox.values.toList();
  }

  Note? getNote(String id) {
    return notesBox.get(id);
  }

  Future<void> deleteNote(String id) async {
    await notesBox.delete(id);
  }

  // 获取未同步的笔记
  List<Note> getModifiedNotes() {
    return notesBox.values
        .where(
          (note) =>
              note.isNewLocally ||
              note.isModifiedLocally ||
              note.isDeletedLocally,
        )
        .toList();
  }

  // 获取指定用户的所有笔记
  List<Note> getNotesByUserId(String userId) {
    return notesBox.values.where((note) => note.userId == userId).toList();
  }

  // 获取特定分类的笔记
  List<Note> getNotesByCategory(String userId, String category) {
    return notesBox.values
        .where((note) => note.userId == userId && note.category == category)
        .toList();
  }

  // 获取需要同步的笔记
  List<Note> getUnsyncedNotes(String userId) {
    return notesBox.values
        .where((note) => note.userId == userId && !note.isSynced)
        .toList();
  }

  // 问题相关方法
  Future<void> saveQuestion(Question question) async {
    await questionsBox.put(question.id, question);
  }

  Future<void> saveQuestions(List<Question> questions) async {
    if (!questionsBox.isOpen) {
      questionsBox = await Hive.openBox<Question>(AppConstants.QUESTIONS_BOX); // 重新打开
      print("Reopened questionsBox");
    }
    final Map<String, Question> questionsMap = {};
    for (var question in questions) {
      questionsMap[question.id] = question;
    }
    await questionsBox.putAll(questionsMap);
  }

  List<Question> getAllQuestions() {
    if (!questionsBox.isOpen) {
      print("questionsBox is closed, returning empty list");
      return [];
    }
    return questionsBox.values.toList();
  }

  Question? getQuestion(String id) {
    return questionsBox.get(id);
  }

  Future<void> deleteQuestion(String id) async {
    await questionsBox.delete(id);
  }

  Future<void> saveAchievements(List<Achievement> achievements) async {
    try {
      if (!achievementsBox.isOpen) {
        achievementsBox = await Hive.openBox<Achievement>(AppConstants.ACHIEVEMENTS_BOX);
      }
      print("准备保存成就到数据库，数量: ${achievements.length}");
      final Map<String, Achievement> achievementsMap = {};
      for (var achievement in achievements) {
        achievementsMap[achievement.id] = achievement;
        print("保存成就: ${achievement.title}");
      }
      await achievementsBox.putAll(achievementsMap);
      print("成就保存完成，当前数据库中成就数量: ${achievementsBox.length}");
    } catch (e) {
      print("保存成就时出错: $e");
      rethrow;
    }
  }

  List<Achievement> getAllAchievements() {
    try {
      if (!achievementsBox.isOpen) {
        print("achievementsBox 未打开，尝试重新打开");
        achievementsBox = Hive.box<Achievement>(AppConstants.ACHIEVEMENTS_BOX);
      }
      final achievements = achievementsBox.values.toList();
      print("从数据库获取成就数量: ${achievements.length}");
      return achievements;
    } catch (e) {
      print("获取成就时出错: $e");
      return [];
    }
  }
  Achievement? getAchievement(String id) {
    return achievementsBox.get(id);
  }

  Future<void> updateAchievement(Achievement achievement) async {
    await achievementsBox.put(achievement.id, achievement);
  }

  // 同步状态跟踪
  Future<void> saveSyncStatus(
    String entityId,
    String entityType,
    DateTime lastSyncedAt,
    int localVersion,
    int serverVersion,
  ) async {
    await syncStatusBox.put('$entityType:$entityId', {
      'entityId': entityId,
      'entityType': entityType,
      'lastSyncedAt': lastSyncedAt.millisecondsSinceEpoch,
      'localVersion': localVersion,
      'serverVersion': serverVersion,
    });
  }

  Map<String, dynamic>? getSyncStatus(String entityId, String entityType) {
    return syncStatusBox.get('$entityType:$entityId');
  }

  // 用户偏好设置
  Future<void> saveUserPreference(String key, dynamic value) async {
    await userBox.put(key, value);
  }

  dynamic getUserPreference(String key) {
    return userBox.get(key);
  }

  // 清除所有数据(用于退出登录等)
  Future<void> clearAllData() async {
    await notesBox.clear();
    await questionsBox.clear();
    await achievementsBox.clear();
    await syncStatusBox.clear();
    // 保留一些用户偏好设置，如语言等
    final language = userBox.get('language');
    final theme = userBox.get('theme');
    await userBox.clear();
    if (language != null) {
      await userBox.put('language', language);
    }
    if (theme != null) {
      await userBox.put('theme', theme);
    }
  }

  // 检查数据库是否为空(首次启动时使用)
  bool isDatabaseEmpty() {
    return notesBox.isEmpty &&
        questionsBox.isEmpty &&
        achievementsBox.isEmpty &&
        !userBox.containsKey('userId');
  }

  // 添加 updateSyncStatus 方法
  Future<void> updateSyncStatus(String noteId, bool isSynced) async {
    // 实现更新同步状态的逻辑
    // 例如，更新数据库中对应 noteId 的记录
  }
}
