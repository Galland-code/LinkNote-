import 'package:flutter/material.dart';
import '../../models/note_model.dart';
import '../../widgets/pixel_card.dart';
import '../../widgets/pixel_container.dart';
import '../../widgets/pixel_text.dart';
import '../../themes/colors.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note note;

  const NoteDetailScreen({
    Key? key,
    required this.note,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/grid_paper.png'),
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: const Icon(Icons.arrow_back),
                      ),
                    ),
                    const Expanded(
                      child: PixelText.heading(
                        'Note',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: const Icon(Icons.edit),
                    ),
                  ],
                ),
              ),

              // Note header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PixelCard(
                  backgroundColor: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PixelText.heading(note.title),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppColors.secondary,
                                width: 1,
                              ),
                            ),
                            child: PixelText.caption(note.category),
                          ),
                          const SizedBox(width: 8),
                          Image.asset(
                            'assets/icons/calendar.png',
                            width: 16,
                            height: 16,
                          ),
                          const SizedBox(width: 4),
                          PixelText.caption(
                            '${note.updatedAt.year}/${note.updatedAt.month}/${note.updatedAt.day}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Note content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: PixelCard(
                    backgroundColor: Colors.white,
                    child: note.content.isEmpty
                        ? const Center(
                      child: PixelText.body('No content'),
                    )
                        : PixelText.body(note.content),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}