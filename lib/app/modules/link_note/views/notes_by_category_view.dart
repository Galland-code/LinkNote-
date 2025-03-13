import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/note.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/pixel_card.dart';
import '../controllers/link_note_controller.dart';

class NotesByCategoryView extends StatelessWidget {
  const NotesByCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    // 获取传递的标签名
    final String category = Get.arguments; // 获取标签名
    final LinkNoteController controller = Get.find<LinkNoteController>();

    final List<Note> notesByCategory = controller.getNotesByCategory(category);


    return Scaffold(
      appBar: AppBar(
        title: Text('$category 类别的笔记'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: notesByCategory.length,
          itemBuilder: (context, index) {
            final note = notesByCategory[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  // 点击笔记，跳转到笔记详情页面
                  Get.toNamed(Routes.LINK_NOTE_DETAIL, arguments: note.id);
                },
                child: PixelCard(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Text(
                        note.content,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
