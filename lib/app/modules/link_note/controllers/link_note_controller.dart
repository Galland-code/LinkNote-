import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/cupertino.dart' as pw;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
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
import 'package:shared_preferences/shared_preferences.dart';

import '../views/link_note_pdfPreview.dart'; // 确保导入 SharedPreferences

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
  Future<void> uploadPDF(File file, int userId) async {
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

      // 使用 http.get 获取 PDF 文件列表
      final response = await http.get(
        Uri.parse('${AppConstants.BASE_URL}/files/${userId.value}'),
      );

      print(response.body);

if (response.statusCode == 200) {
        // 打印原始字节数据和默认解码后的字符串以调试
        print('Raw bytes: ${response.bodyBytes}');
        print('Raw response: ${response.body}');

        // 使用 UTF-8 解码字节数据
        String decodedResponse = utf8.decode(response.bodyBytes, allowMalformed: true);
        print('Decoded response (before processing): $decodedResponse');

        // 处理重复数组
        if (decodedResponse.contains('][')) {
          // 截取第一个完整的 JSON 数组
          decodedResponse = decodedResponse.substring(0, decodedResponse.indexOf(']') + 1);
          print('检测到重复数组，已截取第一个数组: $decodedResponse');
        } else if (!decodedResponse.startsWith('[') || !decodedResponse.endsWith(']')) {
          throw FormatException('响应数据不是有效的 JSON 数组');
        }

        // 解析 JSON
        final List<dynamic> jsonData = jsonDecode(decodedResponse);
        pdfDocuments.value = jsonData.map((json) {
          // 从嵌套的 user 对象中提取 userId
          final userId = json['user']['id'] as int;
          return PdfDocument.fromJson({
            ...json,
            'userId': userId, // 将 user.id 映射到 userId
          });
        }).toList();

        print('成功解析 PDF 数据: ${pdfDocuments.length} 条记录');
        
      } else {
        print('请求失败，状态码: ${response.statusCode}');
      }
    } catch (e) {
      print("userId为：${userId.value}");
      print('加载PDF文件失败: $e');
    } finally {
      isLoadingPdf.value = false;
    }
  }

  // 查看PDF文件
  Future<void> viewPdfDocument(PdfDocument doc) async {
    try {
      // 显示加载提示
      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // 从服务器下载 PDF 文件
      final response = await http.get(Uri.parse(doc.filePath));

      if (response.statusCode == 200) {
        // 获取临时目录并保存 PDF 文件
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/${doc.fileName}');
        await file.writeAsBytes(response.bodyBytes);

        // 关闭加载提示
        Get.back();

        // 导航到 PDF 预览页面
        Get.to(() => PdfPreviewView(filePath: file.path, fileName: doc.fileName));
      } else {
        Get.back();
        Get.snackbar('错误', '无法加载 PDF 文件: HTTP ${response.statusCode}');
      }
    } catch (e) {
      Get.back();
      Get.snackbar('错误', '加载 PDF 文件失败: $e');
    }
  }
}
