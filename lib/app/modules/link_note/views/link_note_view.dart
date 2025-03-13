// lib/app/modules/link_note/views/link_note_view.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:linknote/core/extensions/context_extensions.dart';
import '../../../data/models/note.dart';
import '../controllers/link_note_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../../widgets/pixel_card.dart';

class LinkNoteView extends GetView<LinkNoteController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: context.withGridBackground(
          pixelStyle: true,
          enhanced: true,
          child: Column(
            children: [
              _buildHeader(), //标题
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNoteBooksSection(),
                      _buildTodoSection(),
                      _buildRecentNotesSection(),
                      _buildPdfDocumentsSection(),
                    ],
                  ),
                ),
              ),
              _buildBottomNavBar(), //底部navbar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20), // 设置上下内边距

      child: Stack(
        alignment: Alignment.centerRight, // 右对齐
        children: [
          Container(
            width: double.infinity,
            height: 80, // 根据需要调整高度
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/pixel-title.png'), // 替换为你的图片路径
                fit: BoxFit.contain,
              ),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: 8),
                  Text('LinkNote', style: AppTheme.titleStyle),
                  SizedBox(width: 8),
                ],
              ),
            ),
          ),
          Positioned(
            // 使用 Positioned 来放置 FloatingActionButton
            right: 20, // 右侧对齐
            child: FloatingActionButton(
              onPressed:
                  () => Get.toNamed(Routes.LINK_NOTE_EDIT), // 点击按钮时导航到编辑页面
              backgroundColor: AppTheme.primaryColor, // 按钮背景颜色
              child: Icon(Icons.add, color: Colors.white), // 按钮图标
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16), // 圆角边框
                side: BorderSide(color: Colors.black, width: 2), // 边框样式
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteBooksSection() {
    return Obx(() {
      // 如果数据正在加载，显示加载指示器
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      // 获取去重后的标签，从 controller.notes 获取
      Set<String> uniqueCategories = {};
      for (var note in controller.notes) {
        uniqueCategories.add(note.category);
      }

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 8, bottom: 8),
              child: Text('笔记分类', style: AppTheme.subtitleStyle),
            ),
            // 使用 SingleChildScrollView 和 Row 来实现横向滚动
            SingleChildScrollView(
              scrollDirection: Axis.horizontal, // 设置横向滚动
              child: Row(
                children: [
                  // 遍历分类标签并显示
                  ...uniqueCategories.map((category) {
                    return Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          // 点击标签时跳转到该标签的笔记列表页面
                          Get.toNamed(
                            Routes.LINK_NOTE_NOTES_BY_CATEGORY,
                            arguments: category,
                          );
                        },
                        child: Column(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/notebook.svg',
                              height: 80,
                            ),
                            SizedBox(height: 8),
                            Text('$category', style: AppTheme.subtitleStyle),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  Padding(
                    padding: EdgeInsets.only(right: 12), // "新建" 按钮与其他标签之间的间距
                    child: PixelCard(
                      padding: EdgeInsets.all(12),
                      child: GestureDetector(
                        onTap: () {
                          _showCreateOrUploadDialog(Get.context!);
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              size: 40,
                              color: AppTheme.primaryColor,
                            ),
                            SizedBox(height: 8),
                            Text('新建', style: AppTheme.subtitleStyle),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showCreateOrUploadDialog(BuildContext context) {
    // 弹出选择新建笔记或上传 PDF 的对话框
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('选择操作'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('创建笔记'),
                onTap: () {
                  // 点击后创建新笔记
                  Navigator.pop(context);
                  Get.toNamed(Routes.LINK_NOTE_EDIT);
                },
              ),
              ListTile(
                title: Text('上传 PDF'),
                onTap: () {
                  // 点击后上传 PDF
                  Navigator.pop(context);
                  // 确保上下文有效
                  if (Get.context != null) {
                    Get.toNamed(Routes.LINK_NOTE_UPLOAD_PDF); // 确保这个路由是有效的
                  } else {
                    print("上下文无效，无法导航到上传 PDF 页面");
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTodoSection() {
    return Obx(
      () => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: PixelCard(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/bell.svg',
                    width: 32,
                    height: 32,
                  ),
                  SizedBox(width: 8),
                  Text('ToDo List:', style: AppTheme.subtitleStyle),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.add, color: AppTheme.primaryColor),
                    onPressed: () {
                      // 显示添加待办项的对话框
                      Get.dialog(
                        AlertDialog(
                          title: Text('添加待办项'),
                          content: TextField(
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: '输入待办事项',
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (value) {
                              if (value.isNotEmpty) {
                                controller.addTodoItem(value);
                                Get.back();
                              }
                            },
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: Text('取消'),
                            ),
                            TextButton(
                              onPressed: () {
                                // 获取文本字段的值并添加
                                final textField = Get.find<TextField>();
                                if (textField.controller?.text.isNotEmpty ??
                                    false) {
                                  controller.addTodoItem(
                                    textField.controller!.text,
                                  );
                                  Get.back();
                                }
                              },
                              child: Text('添加'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              Divider(color: Colors.black26),
              ...controller.todoItems.asMap().entries.map((entry) {
                int idx = entry.key;
                String item = entry.value;
                return Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text('${idx + 1}. ', style: AppTheme.bodyStyle),
                      Expanded(child: Text(item, style: AppTheme.bodyStyle)),
                      IconButton(
                        icon: Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                        ),
                        onPressed: () => controller.removeTodoItem(idx),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        iconSize: 20,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentNotesSection() {
    return Obx(
      () => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 8, bottom: 8),
              child: Text('最近笔记', style: AppTheme.subtitleStyle),
            ),
            ...controller.notes
                .map(
                  (note) => GestureDetector(
                    onLongPress: () {
                      // 通过长按导出 PDF
                      final currentContext = Get.context!; // 获取当前上下文
                      controller.showExportOptionsDialog(
                        currentContext,
                        note.title,
                        note.content,
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: PixelCard(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    note.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  DateFormat('MM月dd日').format(note.createdAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondaryColor.withOpacity(
                                      0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.secondaryColor,
                                    ),
                                  ),
                                  child: Text(
                                    note.category,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.secondaryColor,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Text(
                                      note.content,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfDocumentsSection() {
    return Obx(() {
      if (controller.isLoadingPdf.value) {
        return Center(child: CircularProgressIndicator());
      }

      if (controller.pdfDocuments.isEmpty) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.picture_as_pdf, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text('没有PDF文档', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('PDF 文档', style: AppTheme.subtitleStyle),
                TextButton(
                  onPressed: () => controller.loadPdfDocuments(),
                  child: Text('刷新'),
                ),
              ],
            ),
          ),
          Container(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.pdfDocuments.length,
              itemBuilder: (context, index) {
                final doc = controller.pdfDocuments[index];
                return GestureDetector(
                  onTap: () => controller.viewPdfDocument(doc),
                  child: Container(
                    width: 140,
                    margin: EdgeInsets.only(right: 16),
                    child: PixelCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 80,
                            width: double.infinity,
                            color: Colors.red.shade100,
                            child: Center(
                              child: Icon(
                                Icons.picture_as_pdf,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc.fileName,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  doc.category ?? '未分类',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '${doc.uploadTime.year}/${doc.uploadTime.month}/${doc.uploadTime.day}',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildBottomNavBar() {
    return Obx(
      () => BottomNavBar(
        currentIndex: controller.currentNavIndex.value,
        onTap: (index) {
          controller.currentNavIndex.value = index;

          // 导航
          switch (index) {
            case 0:
              // 已经在笔记页面
              break;
            case 1:
              Get.offAllNamed(Routes.QUIZ);
              break;
            case 2:
              Get.offAllNamed(Routes.QUESTION_BANK);
              break;
            case 3:
              Get.offAllNamed(Routes.PROFILE);
              break;
          }
        },
      ),
    );
  }
}
