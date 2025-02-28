class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String category;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
  });
}

class NoteCategory {
  final String id;
  final String name;
  final String icon;
  final List<Note> notes;

  const NoteCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.notes,
  });
}

// Sample data
final List<NoteCategory> sampleNoteCategories = [
  NoteCategory(
    id: '1',
    name: '计组',
    icon: 'assets/icons/notebook.svg',
    notes: [
      Note(
        id: '1',
        title: '计组复习笔记',
        content: '计算机组成原理复习笔记内容...',
        createdAt: DateTime(2024, 12, 5, 12, 16),
        updatedAt: DateTime(2024, 12, 5, 12, 16),
        category: '计组',
      ),
    ],
  ),
];

final List<Note> todoList = [
  Note(
    id: '1',
    title: '完成每日挑战',
    content: '',
    createdAt: DateTime(2024, 12, 5, 12, 16),
    updatedAt: DateTime(2024, 12, 5, 12, 16),
    category: 'Todo',
  ),
  Note(
    id: '2',
    title: '整理RAG技术笔记',
    content: '',
    createdAt: DateTime(2024, 12, 5, 12, 16),
    updatedAt: DateTime(2024, 12, 5, 12, 16),
    category: 'Todo',
  ),
];