import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linknote/core/extensions/context_extensions.dart';
import '../controllers/quiz_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/pixel_card.dart';
import '../../../widgets/pixel_button.dart';
import '../../../widgets/pixel_loading.dart';

class QuizChallengeSelectView extends GetView<QuizController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: context.withGridBackground(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Obx(() {
                if (controller.showDialogForGeneration.value) {
                  // 显示生成问题的对话框
                  _showQuestionGenerationDialog();
                }
                return SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSelectionTabs(),
                      SizedBox(height: 16),
                      _buildSelectionContent(),
                    ],
                  ),
                );
              }),
              ),
              _buildBottomButtons(),
            ],
          ),
        ),
      ),
    );
  }
void _showQuestionGenerationDialog() {
    showDialog(
      context: Get.context!,
      builder: (context) {
        return AlertDialog(
          title: Text('生成问题'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('该笔记没有题目。请输入您希望生成的题目数量：'),
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  controller.questionCount.value = int.tryParse(value) ?? 5;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // 调用生成题目的接口
                controller.generateQuestionsForNote(
                  controller.noteIdToGenerateQuestions.value,
                  controller.questionCount.value,
                );
                controller.showDialogForGeneration.value = false;
                Get.back(); // 关闭对话框
              },
              child: Text('生成'),
            ),
            TextButton(
              onPressed: () {
                controller.showDialogForGeneration.value = false;
                Get.back(); // 关闭对话框
              },
              child: Text('取消'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Stack(
        alignment: Alignment.centerRight, // 右对齐
        children: [
          Container(
            width: double.infinity,
            height: 90,
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
                  Text('选择挑战内容', style: AppTheme.titleStyle),
                  SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionTabs() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                controller.selectedCategory.value = '';
                controller.selectedNoteId.value = -1;
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      controller.selectedCategory.value.isEmpty &&
                              controller.selectedNoteId.value == -1
                          ? AppTheme.primaryColor
                          : Colors.transparent,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(10),
                  ),
                ),
                child: Text(
                  '随机挑战',
                  style: TextStyle(
                    color:
                        controller.selectedCategory.value.isEmpty &&
                                controller.selectedNoteId.value == -1
                            ? Colors.white
                            : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          VerticalDivider(width: 1, color: Colors.black),
          Expanded(
            child: GestureDetector(
              onTap: () {
                controller.selectedNoteId.value = -1;
                if (controller.categories.isNotEmpty) {
                  controller.selectedCategory.value = controller.categories[0];
                }
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      controller.selectedCategory.isNotEmpty &&
                              controller.selectedNoteId.value == -1
                          ? AppTheme.primaryColor
                          : Colors.transparent,
                ),
                child: Text(
                  '分类挑战',
                  style: TextStyle(
                    color:
                        controller.selectedCategory.isNotEmpty &&
                                controller.selectedNoteId.value == -1
                            ? Colors.white
                            : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          VerticalDivider(width: 1, color: Colors.black),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (controller.pdfDocuments.isNotEmpty) {
                  controller.selectedNoteId.value =
                      controller.pdfDocuments[0].id;
                  controller.selectedCategory.value =
                      controller.pdfDocuments[0].category;
                }
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      controller.selectedNoteId.value != -1
                          ? AppTheme.primaryColor
                          : Colors.transparent,
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(10),
                  ),
                ),
                child: Text(
                  '笔记挑战',
                  style: TextStyle(
                    color:
                        controller.selectedNoteId.value != -1
                            ? Colors.white
                            : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionContent() {
    // Random challenge - no selection needed
    if (controller.selectedCategory.value.isEmpty &&
        controller.selectedNoteId.value == -1) {
      return PixelCard(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.shuffle, size: 48, color: AppTheme.primaryColor),
            SizedBox(height: 16),
            Text(
              '随机挑战',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              '从所有笔记中随机生成问题，测试您的全面掌握程度。',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              '问题数量: 5',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    // Category selection
    if (controller.selectedCategory.value.isNotEmpty &&
        controller.selectedNoteId.value == -1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '选择笔记分类',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          ...controller.categories
              .map(
                (category) => GestureDetector(
                  onTap: () => controller.selectCategory(category),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12),
                    child: PixelCard(
                      backgroundColor:
                          controller.selectedCategory.value == category
                              ? AppTheme.primaryColor.withOpacity(0.2)
                              : Colors.white,
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  controller.selectedCategory.value == category
                                      ? AppTheme.primaryColor
                                      : Colors.grey[300],
                              border: Border.all(
                                color:
                                    controller.selectedCategory.value ==
                                            category
                                        ? AppTheme.primaryColor
                                        : Colors.grey,
                                width: 2,
                              ),
                            ),
                            child:
                                controller.selectedCategory.value == category
                                    ? Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                    : null,
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${controller.pdfDocuments.where((n) => n.category == category).length} 条笔记',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ],
      );
    }

    // Note selection
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '选择笔记',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        ...controller.pdfDocuments
            .map(
              (note) => GestureDetector(
                onTap: () => controller.selectNote(note.id),
                child: Container(
                  margin: EdgeInsets.only(bottom: 12),
                  child: PixelCard(
                    backgroundColor:
                        controller.selectedNoteId.value == note.id
                            ? AppTheme.primaryColor.withOpacity(0.2)
                            : Colors.white,
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                controller.selectedNoteId.value == note.id
                                    ? AppTheme.primaryColor
                                    : Colors.grey[300],
                            border: Border.all(
                              color:
                                  controller.selectedNoteId.value == note.id
                                      ? AppTheme.primaryColor
                                      : Colors.grey,
                              width: 2,
                            ),
                          ),
                          child:
                              controller.selectedNoteId.value == note.id
                                  ? Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                  : null,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                note.fileName ?? '未命名文档',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                note.category ?? '未分类',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: PixelButton(
              text: '返回',
              onPressed: () => Get.back(),
              backgroundColor: Colors.grey,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: PixelButton(
              text: '开始挑战',
              onPressed: () => controller.generateChallenge(),
            ),
          ),
        ],
      ),
    );
  }
}
