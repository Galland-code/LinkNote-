import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/link_note_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/pixel_card.dart';
import '../../../widgets/pixel_button.dart';
import '../../../data/models/note.dart';

class LinkNoteCategoryView extends GetView<LinkNoteController> {
  @override
  Widget build(BuildContext context) {
    final String category = Get.arguments['category'];

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            image: DecorationImage(
              image: AssetImage('assets/images/grid_background.png'),
              repeat: ImageRepeat.repeat,
            ),
          ),
          child: Column(
            children: [
              _buildHeader(category),
              Expanded(
                child: _buildNotesList(category),
              ),
              _buildBackButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String category) {
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
            category,
            style: AppTheme.titleStyle,
          ),
        ),
      ),
    );
  }

  Widget _buildNotesList(String category) {
    final notes = controller.getNotesByCategory(category);

    if (notes.isEmpty) {
      return Center(
        child: Text(
          '暂无笔记',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return _buildNoteItem(note);
      },
    );
  }

  Widget _buildNoteItem(Note note) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () {
          Get.toNamed(
            Routes.LINK_NOTE_DETAIL,
            arguments: {'note': note},
          );
        },
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    DateFormat('MM月dd日').format(note.createdAt),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                note.content,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: PixelButton(
        text: '返回',
        onPressed: () {
          Get.back();
        },
        backgroundColor: Colors.grey,
      ),
    );
  }
}