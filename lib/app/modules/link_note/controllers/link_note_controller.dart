import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/cupertino.dart' as pw;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'package:uuid/uuid.dart';
import '../../../../core/values/app_constants.dart';
import '../../../data/models/note.dart';
import '../../../data/repositories/note_repository.dart';
import '../../../data/services/upload_service.dart';
import '../../../routes/app_routes.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../../../data/models/pdf_document.dart';
import 'package:hive/hive.dart';
import '../../../data/models/user_model.dart'; // 确保路径正确
import 'package:shared_preferences/shared_preferences.dart'; // 确保导入 SharedPreferences

class LinkNoteController extends GetxController {
  // 依赖注入
  final NoteRepository _noteRepository = Get.find<NoteRepository>();
  final UploadService _uploadService = UploadService();

  // 定义 userId 变量
  final RxInt userId = 0.obs; // 用户 ID
  final RxString username = ''.obs; // 用户名
  final RxString email = ''.obs; // 用户邮箱

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

  final RxList<PdfDocument> pdfDocuments = <PdfDocument>[].obs;
  final RxBool isLoadingPdf = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserInfo().then((_) {
      // 确保用户信息加载完成后再加载其他数据
      loadNotes();
      loadTodoItems();
      extractCategories();
      loadPdfDocuments();
    });
  }

  // 加载用户信息的方法
  Future<void> loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    userId.value = int.parse(prefs.getString('userId') ?? '0');
    username.value = prefs.getString('username') ?? '';
    email.value = prefs.getString('email') ?? '';
    // 如果需要加载其他字段，可以继续添加
    print("用户信息加载完成: ID: $userId, 用户名: $username, 邮箱: $email");
  }

  int getUserId() {
    return userId.value; // 获取 userId
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
    todoItems.value = ['完成每日挑战', '整理RAG技术笔记'];
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
        userId: userId.toInt(),
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

  // 上传 PDF 文件的函数
  Future<void> uploadPDF(File file, String userId) async {
    try {
      await _uploadService.uploadPDF(file, userId);
      Get.snackbar('上传成功', 'PDF 文件上传成功！');
    } catch (e) {
      Get.snackbar('上传失败', '文件上传失败，请重试！');
    }
  }

  // 新增的导出 PDF 方法
  Future<void> exportNoteAsPDF(String noteTitle, String noteContent) async {
    // 请求存储权限（在 Android 上访问下载目录需要权限）
    await requestStoragePermission();

    // 获取设备的 Downloads 文件夹路径
    final directory = await getExternalStorageDirectory(); // 获取外部存储目录
    if (directory == null) {
      Get.snackbar('Error', '无法获取存储目录');
      return;
    }

    // 构建下载目录路径
    final downloadDirectory = path.join(
      directory.path,
      'Download',
    ); // 设备的 Downloads 文件夹

    // 确保下载目录存在
    final downloadDir = Directory(downloadDirectory);
    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true); // 创建目录
    }

    // 构建文件路径并保存
    final filePath = path.join(downloadDirectory, '$noteTitle.pdf');
    final file = File(filePath);

    // 创建 PDF 文档
    final pdf = pdfWidgets.Document();
    pdf.addPage(
      pdfWidgets.Page(
        build: (pdfWidgets.Context context) {
          return pdfWidgets.Center(
            child: pdfWidgets.Text(
              noteContent,
              style: pdfWidgets.TextStyle(fontSize: 24),
            ),
          );
        },
      ),
    );

    try {
      // 保存 PDF 文件到设备的 Downloads 文件夹
      await file.writeAsBytes(await pdf.save());

      // 提示用户文件已保存
      Get.snackbar('Success', 'PDF 已保存到: $filePath');
      print('PDF 文件已保存到: $filePath');
    } catch (e) {
      // 如果保存失败，显示错误消息
      Get.snackbar('Error', '导出 PDF 失败: $e');
    }
  }

  // 请求存储权限
  Future<void> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  // 显示导出 PDF 选项
  void showExportOptionsDialog(
    BuildContext context,
    String noteTitle,
    String noteContent,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('导出选项'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('导出为 PDF'),
                onTap: () {
                  Navigator.pop(context);
                  exportNoteAsPDF(noteTitle, noteContent);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 加载PDF文件列表
  Future<void> loadPdfDocuments() async {
    try {
      isLoadingPdf.value = true;
      print('请求的 userId: ${userId.value}');
      // 使用Dio获取PDF文件列表
      final response = await dio.Dio().get(
        '${AppConstants.BASE_URL}/files/${userId.value}',
      );
      
      print(response);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        print(data);
        pdfDocuments.value =
            data.map((item) => PdfDocument.fromJson(item)).toList();
      }
    } catch (e) {
      print("userId为：${userId.value}");
      if (e is dio.DioError) {
        print('响应状态码: ${e.response?.statusCode}');
        print('响应数据: ${e.response?.data}');
      }
      print('加载PDF文件失败: $e');
    } finally {
      isLoadingPdf.value = false;
    }
  }

  // 查看PDF文件
  Future<void> viewPdfDocument(PdfDocument document) async {
    try {
      // 显示加载指示器
      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // 获取临时目录
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/${document.fileName}';
      final file = File(filePath);

      // 检查文件是否已下载
      if (!await file.exists()) {
        // 下载文件
        final response = await dio.Dio().get(
          '${AppConstants.BASE_URL}/files/download/${document.id}',
          options: dio.Options(responseType: dio.ResponseType.bytes),
        );

        await file.writeAsBytes(response.data);
      }

      // 关闭加载对话框
      Get.back();

      // 打开PDF查看器
      Get.to(
        () => PDFView(
          filePath: filePath,
          enableSwipe: true,
          swipeHorizontal: true,
          autoSpacing: true,
          pageFling: true,
          pageSnap: true,
          defaultPage: 0,
          fitPolicy: FitPolicy.BOTH,
          onError: (error) {
            Get.snackbar('错误', '无法加载PDF: $error');
          },
        ),
      );
    } catch (e) {
      Get.back(); // 关闭加载对话框
      Get.snackbar('错误', '查看PDF失败: $e');
    }
  }
}
