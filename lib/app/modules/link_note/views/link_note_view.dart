// lib/app/modules/link_note/views/link_note_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:linknote/core/extensions/context_extensions.dart';
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
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNoteBooksSection(),
                      _buildTodoSection(),
                      _buildRecentNotesSection(),
                    ],
                  ),
                ),
              ),
              _buildBottomNavBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_downward, size: 20),
                SizedBox(width: 8),
                Text('LinkNote', style: AppTheme.titleStyle),
                SizedBox(width: 8),
              ],
            ),
          ),
          Positioned(
            right: 0,
            child: FloatingActionButton(
              onPressed: () => Get.toNamed(Routes.LINK_NOTE_EDIT),
              backgroundColor: AppTheme.primaryColor,
              child: Icon(Icons.add, color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.black, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteBooksSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: PixelCard(
              padding: EdgeInsets.all(12),
              child: Column(
                children: [
                  Image.asset('assets/images/notebook.png', height: 40),
                  SizedBox(height: 8),
                  Text('计组', style: AppTheme.subtitleStyle),
                ],
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: PixelCard(
              padding: EdgeInsets.all(12),
              child: Column(
                children: [
                  Image.asset('assets/images/notebook.png', height: 40),
                  SizedBox(height: 8),
                  Text('RAG技术', style: AppTheme.subtitleStyle),
                ],
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: PixelCard(
              padding: EdgeInsets.all(12),
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
        ],
      ),
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
                  Image.asset('assets/images/bell.png', width: 24, height: 24),
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
                    onTap:
                        () => Get.toNamed(
                          Routes.LINK_NOTE_DETAIL,
                          arguments: {'note': note},
                        ),
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
