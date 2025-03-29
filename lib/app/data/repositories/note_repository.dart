import 'dart:ffi';

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
      final response = await _apiProvider.get('${AppConstants.BASE_URL}${AppConstants.NOTES}');
      if (response.statusCode == 200) {
        print("获取笔记成功");
        print(response.data);
        final List<dynamic> data = response.data;
        final List<Note> notes =
            data.map((item) => Note.fromJson(item)).toList();

        // 保存到本地数据库
        await _databaseService.saveNotes(notes);

        return notes;
      } else {
        print("获取笔记失败,没有从api获取到笔记");
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

  // 获取需要同步的本地修改笔记
  List<Note> getModifiedNotes() {
    return _databaseService
        .getAllNotes()
        .where(
          (note) =>
              note.isNewLocally ||
              note.isModifiedLocally ||
              note.isDeletedLocally,
        )
        .toList();
  }

  // 获取笔记（先尝试API，失败则用本地）
  Future<List<Note>> getNotes() async {
    try {
      return await getNotesFromApi();
    } catch (e) {
      return getNotesFromLocal();
    }
  }

  // 创建新笔记
  Future<Note> createNote(
    String title,
    String content,
    String category,
    int userId,
  ) async {
    // 生成唯一ID
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    // 创建本地新笔记
    final note = Note.localNew(
      id: id,
      title: title,
      content: content,
      category: category,
      userId: userId,
    );

    // 保存到本地
    await _databaseService.saveNote(note);

    // 尝试同步到服务器
    try {
      final response = await _apiProvider.post(
        AppConstants.NOTES,
        data: note.toJson(),
      );
      if (response.statusCode == 201) {
        // 服务器返回的笔记信息
        final serverNote = Note.fromJson(response.data);

        // 将本地笔记标记为已同步
        final syncedNote = note.copyWithSynced();
        await _databaseService.saveNote(syncedNote);

        return syncedNote;
      }
    } catch (e) {
      // 同步失败，保留本地笔记状态
      print('Create note sync error: $e');
    }

    return note;
  }

  // 更新笔记
  Future<Note> updateNote(
    Note note, {
    String? title,
    String? content,
    String? category,
  }) async {
    // 创建修改后的笔记
    final updatedNote = note.copyWithModified(
      title: title,
      content: content,
      category: category,
    );

    // 保存到本地
    await _databaseService.saveNote(updatedNote);

    // 尝试同步到服务器
    try {
      final response = await _apiProvider.put(
        '${AppConstants.NOTE_BY_ID}/${note.id}',
        data: updatedNote.toJson(),
      );
      if (response.statusCode == 200) {
        // 将本地笔记标记为已同步
        final syncedNote = updatedNote.copyWithSynced();
        await _databaseService.saveNote(syncedNote);

        return syncedNote;
      }
    } catch (e) {
      // 同步失败，保留本地笔记状态
      print('Update note sync error: $e');
    }

    return updatedNote;
  }

  // 删除笔记
  Future<void> deleteNote(String id) async {
    // 获取笔记
    final note = _databaseService.getNote(id);
    if (note == null) {
      return;
    }

    // 标记为本地删除
    final deletedNote = note.copyWithDeleted();
    await _databaseService.saveNote(deletedNote);

    // 尝试同步到服务器
    try {
      final response = await _apiProvider.delete('${AppConstants.NOTES}/$id');
      if (response.statusCode == 204) {
        // 同步成功，从本地数据库删除
        await _databaseService.deleteNote(id);
      }
    } catch (e) {
      // 同步失败，保留本地删除标记
      print('Delete note sync error: $e');
    }
  }

  // 更新同步状态
  Future<void> updateSyncStatus(String id, bool isSynced) async {
    final note = _databaseService.getNote(id);
    if (note != null) {
      final syncedNote = note.copyWithSynced();
      await _databaseService.saveNote(syncedNote);
    }
  }

  // 合并服务器数据到本地
  Future<void> mergeServerNotes(List<Note> serverNotes) async {
    final localNotes = _databaseService.getAllNotes();

    // 处理服务器笔记
    for (var serverNote in serverNotes) {
      // 检查本地是否存在
      final localIndex = localNotes.indexWhere(
        (note) => note.id == serverNote.id,
      );

      if (localIndex != -1) {
        final localNote = localNotes[localIndex];

        // 如果本地笔记未修改，更新为服务器版本
        if (!localNote.isModifiedLocally && !localNote.isDeletedLocally) {
          await _databaseService.saveNote(serverNote);
        }
        // 否则保留本地版本，等待下次同步
      } else {
        // 本地不存在，直接添加
        await _databaseService.saveNote(serverNote);
      }
    }

    // 处理服务器已删除的笔记（在服务器中不存在但本地存在的笔记）
    for (var localNote in localNotes) {
      if (!localNote.isNewLocally &&
          !serverNotes.any((note) => note.id == localNote.id)) {
        // 如果本地笔记已被标记为删除，则完全删除
        if (localNote.isDeletedLocally) {
          await _databaseService.deleteNote(localNote.id);
        }
        // 如果本地笔记被修改，保留本地版本等待同步
        // 如果既未删除也未修改，则服务器可能已删除，本地也应删除
        else if (!localNote.isModifiedLocally) {
          await _databaseService.deleteNote(localNote.id);
        }
      }
    }
  }

  //  保存或创建note
  Future<void> saveNote(Note note) async {
    try {
      final response = await _apiProvider.post(
        '${AppConstants.BASE_URL}/files/note',
        data: {
          'title': note.title,
          'content': note.content,
          'userId': note.userId
        },
      );
    }catch(e){
      print(e);
    }

  }
}
