import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart'; // For PlatformException
import 'package:linknote/app/data/repositories/user_repository.dart';
import '../../../../core/theme/app_theme.dart';
import '../controllers/link_note_controller.dart';

class LinkNoteUploadPDFView extends StatefulWidget {
  @override
  _LinkNoteUploadPDFViewState createState() => _LinkNoteUploadPDFViewState();
}

class _LinkNoteUploadPDFViewState extends State<LinkNoteUploadPDFView> {
  String? fileName;
  String? filePath;
  bool isUploading = false;
  String? userId;

  @override
  void initState() {
    super.initState();
  }


  // 选择 PDF 文件
  Future<void> pickPDFFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          filePath = result.files.single.path;
          fileName = result.files.single.name;
        });
      }
    } on PlatformException catch (e) {
      // 如果选择文件时出错
      print("FilePicker error: $e");
      Get.snackbar('Error', '无法选择文件');
    }
  }

  // 模拟上传文件的过程
  Future<void> uploadPDF() async {
    if (filePath == null) {
      Get.snackbar(
        'Error',
        '请选择一个 PDF 文件',
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white, // 文本颜色为白色
        snackPosition: SnackPosition.BOTTOM, // 显示在屏幕底部，还行也没有很丑
        borderRadius: 10, // 圆角
        margin: EdgeInsets.all(16), // 外边距
        icon: Icon(
          Icons.error_outline, // 显示错误图标
          color: Colors.white,
        ),
        duration: Duration(seconds: 3), // 显示时长
      );
      return;
    }

    if (userId == null) {
      Get.snackbar('错误', '用户未登录，请先登录');
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      File file = File(filePath!);
      final controller = Get.find<LinkNoteController>();
      await controller.uploadPDF(file, userId!);

      setState(() {
        isUploading = false;
      });
    } catch (e) {
      setState(() {
        isUploading = false;
      });
      Get.snackbar('Error', '文件上传失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('上传 PDF', style: AppTheme.titleStyle),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text('选择一个 PDF 文件', style: AppTheme.titleStyle),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50), // 设置最小宽度和高度
              ),
              onPressed: pickPDFFile,
              child: Text(
                '选择文件',
                style: AppTheme.subtitleStyle.copyWith(color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            if (fileName != null)
              Text('选择的文件: $fileName', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            if (isUploading) CircularProgressIndicator(),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(200, 50), // 设置最小宽度和高度
              ),
              onPressed: isUploading ? null : uploadPDF, // 在上传时禁用按钮
              child: Text(
                '上传 PDF',
                style: AppTheme.subtitleStyle.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
