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

  Future<DatabaseService> init() async {
    // 打开所有需要的盒子
    questionsBox = await Hive.openBox<Question>(AppConstants.QUESTIONS_BOX);
    notesBox = await Hive.openBox<Note>(AppConstants.NOTES_BOX);
    achievementsBox = await Hive.openBox<Achievement>(AppConstants.ACHIEVEMENTS_BOX);
    userBox = await Hive.openBox(AppConstants.USER_BOX);

    return this;
  }

  // 问题相关方法
  Future<void> saveQuestion(Question question) async {
    await questionsBox.put(question.id, question);
  }

  Future<void> saveQuestions(List<Question> questions) async {
    final Map<String, Question> questionsMap = {};
    for (var question in questions) {
      questionsMap[question.id] = question;
    }
    await questionsBox.putAll(questionsMap);
  }

  List<Question> getAllQuestions() {
    return questionsBox.values.toList();
  }

  Question? getQuestion(String id) {
    return questionsBox.get(id);
  }

  Future<void> deleteQuestion(String id) async {
    await questionsBox.delete(id);
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

  // 成就相关方法
  Future<void> saveAchievement(Achievement achievement) async {
    await achievementsBox.put(achievement.id, achievement);
  }

  Future<void> saveAchievements(List<Achievement> achievements) async {
    final Map<String, Achievement> achievementsMap = {};
    for (var achievement in achievements) {
      achievementsMap[achievement.id] = achievement;
    }
    await achievementsBox.putAll(achievementsMap);
  }

  List<Achievement> getAllAchievements() {
    return achievementsBox.values.toList();
  }

  Achievement? getAchievement(String id) {
    return achievementsBox.get(id);
  }

  Future<void> updateAchievement(Achievement achievement) async {
    await achievementsBox.put(achievement.id, achievement);
  }

  // 用户偏好设置
  Future<void> saveUserPreference(String key, dynamic value) async {
    await userBox.put(key, value);
  }

  dynamic getUserPreference(String key) {
    return userBox.get(key);
  }
}
