import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';

class PdfPreviewView extends StatelessWidget {
  final String filePath;
  final String fileName;

  const PdfPreviewView({required this.filePath, required this.fileName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: PDFView(
        filePath: filePath,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
        onError: (error) {
          Get.snackbar('错误', '无法打开 PDF: $error');
        },
        onPageError: (page, error) {
          Get.snackbar('错误', '第 $page 页加载失败: $error');
        },
      ),
    );
  }
}