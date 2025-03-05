import 'package:get/get.dart';
import '../../core/models/note_model.dart';
import '../../core/repository/note_repository.dart';
import '../../core/repository/user_repository.dart';

/// 笔记控制器，管理笔记相关状态和逻辑
class NoteController extends GetxController {
  final NoteRepository _noteRepository = Get.find<NoteRepository>();
  final UserRepository _userRepository = Get.find<UserRepository>();

  // 响应式状态变量
  final RxList<Note> notes = <Note>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserNotes();

    // 监听搜索查询和类别筛选变化
    ever(searchQuery, (_) => _filterNotes());
    ever(selectedCategory, (_) => _filterNotes());
  }

  // 加载用户笔记
  Future<void> loadUserNotes({bool forceRefresh = false}) async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final user = await _userRepository.getCurrentUser();
      if (user != null) {
        final userNotes = await _noteRepository.getUserNotes(
          user.id,
          forceRefresh: forceRefresh,
        );
        notes.assignAll(userNotes);
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // 创建笔记
  Future<Note?> createNote(String title, String content, {String? category, String? icon}) async {
    try {
      final user = await _userRepository.getCurrentUser();
      if (user != null) {
        final now = DateTime.now().toIso8601String().split('T')[0];
        final newNote = Note(
          id: '', // ID将由服务器生成
          title: title,
          content: content,
          date: now,
          category: category,
          icon: icon,
          userId: user.id,
        );

        final createdNote = await _noteRepository.createNote(newNote);

        // 刷新笔记列表
        await loadUserNotes();

        return createdNote;
      }
      return null;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      return null;
    }
  }

  // 更新笔记
  Future<Note?> updateNote(String noteId, String title, String content, {String? category, String? icon}) async {
    try {
      final note = notes.firstWhereOrNull((note) => note.id == noteId);
      if (note != null) {
        final updatedNote = Note(
          id: note.id,
          title: title,
          content: content,
          date: note.date,
          category: category ?? note.category,
          icon: icon ?? note.icon,
          userId: note.userId,
        );

        final result = await _noteRepository.updateNote(updatedNote);

        // 更新本地列表
        final index = notes.indexWhere((note) => note.id == noteId);
        if (index != -1) {
          notes[index] = result;
        }

        return result;
      }
      return null;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      return null;
    }
  }

  // 删除笔记
  Future<bool> deleteNote(String noteId) async {
    try {
      final success = await _noteRepository.deleteNote(noteId);

      if (success) {
        // 从本地列表中移除
        notes.removeWhere((note) => note.id == noteId);
      }

      return success;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      return false;
    }
  }

  // 设置搜索查询
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  // 设置选定类别
  void setSelectedCategory(String category) {
    selectedCategory.value = category;
  }

  // 筛选笔记
  void _filterNotes() async {
    isLoading.value = true;

    try {
      final user = await _userRepository.getCurrentUser();
      if (user != null) {
        List<Note> filteredNotes = [];

        // 如果有选定类别，按类别筛选
        if (selectedCategory.isNotEmpty) {
          filteredNotes = _noteRepository.getNotesByCategory(user.id, selectedCategory.value);
        } else {
          filteredNotes = await _noteRepository.getUserNotes(user.id);
        }

        // 如果有搜索查询，进一步筛选
        if (searchQuery.isNotEmpty) {
          filteredNotes = filteredNotes
              .where((note) =>
          note.title.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
              note.content.toLowerCase().contains(searchQuery.value.toLowerCase()))
              .toList();
        }

        notes.assignAll(filteredNotes);
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
