import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/note.dart';
import '../../../data/models/pdf_document.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/pixel_card.dart';
import '../controllers/link_note_controller.dart';

class NotesByCategoryView extends StatelessWidget {
  const NotesByCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    // 获取传递的标签名
    final String category = Get.arguments;
    final LinkNoteController controller = Get.find<LinkNoteController>();

    final data = controller.getNotesByCategory(category);
    final notesByCategory = data['notes'] as List<Note>;
    final pdfsByCategory = data['pdfs'] as List<PdfDocument>;

    return Scaffold(
      appBar: AppBar(
        title: Text('$category 类别的笔记和PDF'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            // 显示笔记列表
            ...notesByCategory.map((note) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
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
            )),
            
            // 显示PDF文件列表
            ...pdfsByCategory.map((pdf) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  controller.viewPdfDocument(pdf);
                },
                child: PixelCard(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pdf.fileName,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'PDF 文件',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
