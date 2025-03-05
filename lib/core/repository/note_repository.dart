import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/note_model.dart';
import '../network/api_provider.dart';

/// 笔记仓库，处理笔记数据的获取和存储
class NoteRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final Box<Note> _noteBox = Hive.box<Note>('noteBox');

  // 获取所有笔记
  List<Note> getAllNotes() {
    return _noteBox.values.toList();
  }

  // 获取用户笔记
  Future<List<Note>> getUserNotes(String userId, {bool forceRefresh = false}) async {
    // 如果不强制刷新，尝试从本地获取
    if (!forceRefresh) {
      final localNotes = _noteBox.values
          .where((note) => note.userId == userId)
          .toList();

      if (localNotes.isNotEmpty) {
        return localNotes;
      }
    }

    try {
      // 从服务器获取数据
      final notes = await _apiProvider.getUserNotes(userId);

      // 清空该用户旧数据并存储新数据
      final keysToDelete = _noteBox.keys
          .where((key) => _noteBox.get(key)?.userId == userId)
          .toList();

      for (var key in keysToDelete) {
        await _noteBox.delete(key);
      }

      for (var note in notes) {
        await _noteBox.put(note.id, note);
      }

      return notes;
    } catch (e) {
      // 如果网络请求失败但本地有该用户的数据，返回本地数据
      final localNotes = _noteBox.values
          .where((note) => note.userId == userId)
          .toList();

      if (localNotes.isNotEmpty) {
        return localNotes;
      }

      rethrow;
    }
  }

  // 创建笔记
  Future<Note> createNote(Note note) async {
    try {
      // 发送到服务器
      final createdNote = await _apiProvider.createNote(note);

      // 保存到本地
      await _noteBox.put(createdNote.id, createdNote);

      return createdNote;
    } catch (e) {
      // 如果网络请求失败，先保存到本地，等网络恢复后再同步
      // 生成临时ID
      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      final tempNote = Note(
        id: tempId,
        title: note.title,
        content: note.content,
        date: note.date,
        icon: note.icon,
        category: note.category,
        userId: note.userId,
      );

      await _noteBox.put(tempId, tempNote);
      return tempNote;
    }
  }

  // 更新笔记
  Future<Note> updateNote(Note note) async {
    // 先更新本地，再异步更新服务器
    await _noteBox.put(note.id, note);

    try {
      // TODO: 调用API更新笔记
      return note;
    } catch (e) {
      // 出错了，但本地已更新，可以后续重试
      return note;
    }
  }

  // 删除笔记
  Future<bool> deleteNote(String noteId) async {
    // 先从本地删除
    await _noteBox.delete(noteId);

    try {
      // TODO: 调用API删除笔记
      return true;
    } catch (e) {
      // 出错了，但本地已删除，可以后续重试
      return true;
    }
  }

  // 按类别获取笔记
  List<Note> getNotesByCategory(String userId, String category) {
    return _noteBox.values
        .where((note) => note.userId == userId && note.category == category)
        .toList();
  }

  // 搜索笔记
  List<Note> searchNotes(String userId, String keyword) {
    return _noteBox.values
        .where((note) =>
    note.userId == userId &&
        (note.title.toLowerCase().contains(keyword.toLowerCase()) ||
            note.content.toLowerCase().contains(keyword.toLowerCase())))
        .toList();
  }
}
