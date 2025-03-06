import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/note.dart';
import '../../../data/repositories/note_repository.dart';
import '../../../routes/app_routes.dart';

class LinkNoteController extends GetxController {
  // 依赖注入
  final NoteRepository _noteRepository = Get.find<NoteRepository>();

  // 可观察变量
  final RxInt currentNavIndex = 0.obs;
  final RxList<Note> notes = <Note>[].obs;
  final RxList<String> todoItems = <String>[].obs;
  final RxList<String> categories = <String>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // 编辑相关
  final RxString editingNoteId = ''.obs;
  final RxString noteTitle = ''.obs;
  final RxString noteContent = ''.obs;
  final RxString noteCategory = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotes();
    loadTodoItems();
    extractCategories();
  }

  // 加载笔记
  Future<void> loadNotes() async {
    try {
      isLoading.value = true;
      notes.value = await _noteRepository.getNotes();
      notes.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // 按时间降序
      isLoading.value = false;
      errorMessage.value = '';
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = '加载笔记失败: $e';
    }
  }

  // 提取所有分类
  void extractCategories() {
    final Set<String> uniqueCategories = {};
    for (var note in notes) {
      uniqueCategories.add(note.category);
    }
    categories.value = uniqueCategories.toList();
  }

  // 加载待办事项
  void loadTodoItems() {
    // 实际项目中应该从数据库加载
    todoItems.value = [
      '完成每日挑战',
      '整理RAG技术笔记',
    ];
  }

  // 添加待办事项
  void addTodoItem(String item) {
    if (item.isNotEmpty) {
      todoItems.add(item);
    }
  }

  // 删除待办事项
  void removeTodoItem(int index) {
    if (index >= 0 && index < todoItems.length) {
      todoItems.removeAt(index);
    }
  }

  // 创建新笔记
  void createNewNote() {
    // 重置编辑状态
    editingNoteId.value = '';
    noteTitle.value = '';
    noteContent.value = '';
    noteCategory.value = categories.isNotEmpty ? categories[0] : '学习笔记';

    // 导航到编辑页面
    Get.toNamed(Routes.LINK_NOTE_EDIT);
  }

  // 编辑笔记
  void editNote(String id) {
    final note = notes.firstWhere((note) => note.id == id);

    editingNoteId.value = note.id;
    noteTitle.value = note.title;
    noteContent.value = note.content;
    noteCategory.value = note.category;

    Get.toNamed(Routes.LINK_NOTE_EDIT);
  }

  // 保存笔记
  Future<void> saveNote() async {
    if (noteTitle.value.isEmpty) {
      errorMessage.value = '标题不能为空';
      return;
    }

    try {
      final uuid = Uuid();
      final id = editingNoteId.value.isEmpty ? uuid.v4() : editingNoteId.value;

      final note = Note(
        id: id,
        title: noteTitle.value,
        content: noteContent.value,
        createdAt: DateTime.now(),
        category: noteCategory.value,
      );

      await _noteRepository.saveNote(note);

      // 重新加载笔记列表
      await loadNotes();

      // 提取分类
      extractCategories();

      // 返回列表页面
      Get.back();
    } catch (e) {
      errorMessage.value = '保存笔记失败: $e';
    }
  }

  // 删除笔记
  Future<void> deleteNote(String id) async {
    try {
      await _noteRepository.deleteNote(id);
      await loadNotes();
    } catch (e) {
      errorMessage.value = '删除笔记失败: $e';
    }
  }

  // 按分类筛选笔记
  List<Note> getNotesByCategory(String category) {
    return notes.where((note) => note.category == category).toList();
  }
}
