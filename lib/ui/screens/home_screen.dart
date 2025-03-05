import 'package:flutter/material.dart';
import '../../core/models/mock_data.dart';
import '../../core/models/note_model.dart';
import '../widgets/pixel_container.dart';
import '../widgets/pixel_note_card.dart';
import '../widgets/pixel_title.dart';
import '../widgets/navigation_bar.dart';

/// Home screen that shows notes and todo list
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _currentIndex = 0; // Current navigation index for home screen

  // Mock data for notes and todo list
  late List<Note> _notes;
  late List<Map<String, dynamic>> _todoList;

  @override
  void initState() {
    super.initState();
    // Load mock data
    _notes = MockData.getMockNotes();
    _todoList = MockData.getMockTodoList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background color to match design
      backgroundColor: const Color(0xFFFDF9ED),
      // App bar with title
      appBar: AppBar(
        title: const Text('首页'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      // Main content
      body: SafeArea(
        child: Column(
          children: [
            // Title section
            Padding(
              padding: const EdgeInsets.all(16),
              child: PixelTitle(
                text: 'LinkNote',
                backgroundColor: Colors.white,
              ),
            ),

            // Main content - grows to fill available space
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // First row: Notebook and Todo list
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Notebook section
                          Expanded(
                            child: PixelContainer(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  // Notebook icon and text
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/icons/notebook.png',
                                        width: 24,
                                        height: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        '计组',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Todo list section
                          Expanded(
                            child: PixelContainer(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Todo title with bell icon
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/icons/bell.png',
                                        width: 16,
                                        height: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'ToDo List:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const Divider(),

                                  // Todo list items
                                  ...List.generate(
                                    _todoList.length,
                                        (index) => Row(
                                      children: [
                                        Text('${index + 1}. '),
                                        Expanded(
                                          child: Text(
                                            _todoList[index]['title'],
                                            style: TextStyle(
                                              decoration: _todoList[index]['completed']
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Calendar info
                      Row(
                        children: [
                          Image.asset(
                            'assets/icons/calendar.png',
                            width: 16,
                            height: 16,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Mon.',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '12.16',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Notes list
                      ...List.generate(
                        _notes.length > 3 ? 3 : _notes.length,
                            (index) => PixelNoteCard(
                          note: _notes[index],
                          onTap: () {
                            // Navigate to note detail
                            _showNoteDetail(_notes[index]);
                          },
                        ),
                      ),

                      // Calendar info for last item
                      Row(
                        children: [
                          Image.asset(
                            'assets/icons/calendar.png',
                            width: 16,
                            height: 16,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '5',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '11.12',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom navigation bar - floating
      bottomNavigationBar: PixelBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          // Handle navigation
          switch (index) {
            case 0:
            // Already on home screen
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/quiz');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/question_bank');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/achievements');
              break;
          }
        },
      ),
    );
  }

  // Show note detail in a dialog
  void _showNoteDetail(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('日期: ${note.date}'),
            const SizedBox(height: 16),
            Text('内容: ${note.content}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}