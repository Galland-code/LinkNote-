import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linknote/core/extensions/context_extensions.dart';
import '../controllers/link_note_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/pixel_card.dart';
import '../../../widgets/pixel_button.dart';

class LinkNoteEditView extends GetView<LinkNoteController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: context.withGridBackground(
          enhanced: true,
          pixelStyle: true,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildEditForm(),
              ),
              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Text(
            controller.editingNoteId.value.isEmpty ? '新建笔记' : '编辑笔记',
            style: AppTheme.titleStyle,
          ),
        ),
      ),
    );
  }

  Widget _buildEditForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题输入
          Text(
            '标题',
            style: AppTheme.subtitleStyle,
          ),
          SizedBox(height: 8),
          PixelCard(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextFormField(
              initialValue: controller.noteTitle.value,
              onChanged: (value) => controller.noteTitle.value = value,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '输入笔记标题',
              ),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 16),

          // 分类选择
          Text(
            '分类',
            style: AppTheme.subtitleStyle,
          ),
          SizedBox(height: 8),
          Obx(() => PixelCard(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.noteCategory.value.isEmpty
                    ? (controller.categories.isNotEmpty ? controller.categories[0] : null)
                    : controller.noteCategory.value,
                onChanged: (value) {
                  if (value != null) {
                    controller.noteCategory.value = value;
                  }
                },
                isExpanded: true,
                items: [
                  ...controller.categories.map((category) => DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  )).toList(),
                  // 添加一个新建分类选项
                  DropdownMenuItem<String>(
                    value: '新建分类',
                    child: Row(
                      children: [
                        Icon(Icons.add, size: 16),
                        SizedBox(width: 8),
                        Text('新建分类'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
          SizedBox(height: 16),

          // 内容输入
          Text(
            '内容',
            style: AppTheme.subtitleStyle,
          ),
          SizedBox(height: 8),
          PixelCard(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextFormField(
              initialValue: controller.noteContent.value,
              onChanged: (value) => controller.noteContent.value = value,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '输入笔记内容',
              ),
              maxLines: 10,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: PixelButton(
              text: '取消',
              onPressed: () {
                Get.back();
              },
              backgroundColor: Colors.grey,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: PixelButton(
              text: '保存',
              onPressed: () {
                controller.saveNote();
              },
            ),
          ),
        ],
      ),
    );
  }
}
