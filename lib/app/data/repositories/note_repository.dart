import 'package:get/get.dart';
import '../models/note.dart';
import '../providers/api_provider.dart';
import '../services/database_service.dart';
import '../../../core/values/app_constants.dart';

class NoteRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final DatabaseService _databaseService = Get.find<DatabaseService>();

  // 从API获取所有笔记
  Future<List<Note>> getNotesFromApi() async {
    try {
      final response = await _apiProvider.get(AppConstants.GET_NOTES);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final List<Note> notes = data.map((item) => Note(
          id: item['id'],
          title: item['title'],
          content: item['content'],
          createdAt: DateTime.parse(item['createdAt']),
          category: item['category'],
        )).toList();

        // 保存到本地数据库
        await _databaseService.saveNotes(notes);

        return notes;
      } else {
        throw Exception('Failed to load notes');
      }
    } catch (e) {
      // 如果API请求失败，使用本地数据
      return _databaseService.getAllNotes();
    }
  }

  // 从本地数据库获取所有笔记
  List<Note> getNotesFromLocal() {
    return _databaseService.getAllNotes();
  }

  // 获取笔记（先尝试API，失败则用本地）
  Future<List<Note>> getNotes() async {
    try {
      return await getNotesFromApi();
    } catch (e) {
      return getNotesFromLocal();
    }
  }

  // 保存笔记到本地
  Future<void> saveNote(Note note) async {
    await _databaseService.saveNote(note);
  }

  // 删除笔记
  Future<void> deleteNote(String id) async {
    await _databaseService.deleteNote(id);
  }
}