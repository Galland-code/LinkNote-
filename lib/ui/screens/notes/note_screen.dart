import 'package:flutter/material.dart';
import '../../models/note_model.dart';
import '../../widgets/pixel_card.dart';
import '../../widgets/pixel_container.dart';
import '../../widgets/pixel_navbar.dart';
import '../../widgets/pixel_text.dart';
import '../../themes/colors.dart';

class NoteScreen extends StatelessWidget {
  const NoteScreen({Key? key}) : super(key: key);

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
                    Image.asset(
                      'assets/icons/heart.png',
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: PixelText.heading(
                        'LinkNote',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Image.asset(
                      'assets/icons/plus.png',
                      width: 24,
                      height: 24,
                    ),
                  ],
                ),
              ),

              // Notebooks section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildNotebookItem('计组', '..'),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTodoCard(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Recent notes
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDateIndicator(DateTime(2024, 12, 5)),
                      const SizedBox(height: 16),
                      _buildNoteCard(
                        '第十七届全国大学生软件创新大赛',
                        DateTime(2024, 12, 5, 12, 16),
                      ),
                      const SizedBox(height: 16),
                      _buildNoteCard(
                        '计组复习笔记',
                        DateTime(2024, 12, 5, 12, 10),
                      ),
                      const SizedBox(height: 16),
                      _buildDateIndicator(DateTime(2024, 12, 1)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildNoteCard(
                              'RAG技术笔记',
                              DateTime(2024, 12, 1, 11, 12),
                            ),
                          ),
                          const SizedBox(width: 16),
                          _buildNotebookItem('计组', '..'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom navigation
              const PixelNavbar(currentIndex: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotebookItem(String title, String subtitle) {
    return PixelCard(
      width: 80,
      height: 100,
      backgroundColor: Colors.white,
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icons/notebook.png',
            width: 40,
            height: 40,
          ),
          const SizedBox(height: 8),
          PixelText.caption(
            title,
            textAlign: TextAlign.center,
          ),
          PixelText.caption(
            subtitle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTodoCard() {
    return PixelCard(
      backgroundColor: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/icons/bell.png',
                width: 24,
                height: 24,
                color: AppColors.accent,
              ),
              const SizedBox(width: 8),
              const PixelText.subheading('ToDo List:'),
            ],
          ),
          const Divider(),
          for (int i = 0; i < todoList.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PixelText.body('${i + 1}. ${todoList[i].title}'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateIndicator(DateTime date) {
    return Row(
      children: [
        Image.asset(
          'assets/icons/calendar.png',
          width: 20,
          height: 20,
          color: Colors.red,
        ),
        const SizedBox(width: 8),
        PixelText.caption(
          'Mon. ${date.day}.${date.month}',
        ),
      ],
    );
  }

  Widget _buildNoteCard(String title, DateTime date) {
    return PixelCard(
      backgroundColor: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/icons/note_file.png',
            width: 32,
            height: 32,
          ),
          const SizedBox(height: 8),
          PixelText.body(
            title,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}