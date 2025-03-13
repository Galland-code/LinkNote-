import '../../app/data/models/question.dart';
import '../../app/data/models/note.dart';
import '../../app/data/models/achievement.dart';

/// Class that provides mock data for the app
class MockData {
  /// Generate mock quiz questions
  static List<Question> getMockQuestions() {
    return [
      Question(
        id: '1',
        source: '计组复习笔记',
        content: 'What is the basic unit of computer data storage?',
        options: ['Byte', 'Bit', 'Nibble', 'Word'],
        correctOptionIndex: 1,
      ),
      Question(
        id: '2',
        source: '计组复习笔记',
        content:
            'Which of the following language executes the fastest on a computer?',
        options: ['Java', 'Python', 'C', 'Assembly'],
        correctOptionIndex: 3,
      ),
      Question(
        id: '3',
        source: '测试总复习PPT',
        content:
            'Which testing technique involves testing individual components in isolation?',
        options: [
          'Integration Testing',
          'System Testing',
          'Unit Testing',
          'Acceptance Testing',
        ],
        correctOptionIndex: 2,
      ),
      Question(
        id: '4',
        source: '计组复习笔记',
        content: 'What does CPU stand for?',
        options: [
          'Central Processing Unit',
          'Computer Processing Unit',
          'Central Processor Unit',
          'Control Processing Unit',
        ],
        correctOptionIndex: 0,
      ),
      Question(
        id: '5',
        source: '计组复习笔记',
        content: 'Which component is known as the brain of the computer?',
        options: ['Hard Drive', 'RAM', 'CPU', 'Motherboard'],
        correctOptionIndex: 2,
      ),
    ];
  }

  /// Generate mock notes
  static List<Note> getMockNotes() {
    return [
      Note(
        id: '1',
        title: '第十七届全国大学生软件创新大赛',
        userId: 'user123',
        content:
            'Key points about the competition and participation requirements...',
        createdAt: DateTime(2024, 12, 5),
        category: '竞赛',
      ),
      Note(
        id: '2',
        title: '计组复习笔记',
        userId: 'user123',
        content: 'Computer organization and architecture review notes...',
        createdAt: DateTime(2024, 12, 1),
        category: '学习',
      ),
      Note(
        id: '3',
        title: 'RAG技术笔记',
        userId: 'user123',
        content: 'Notes on Retrieval Augmented Generation technology...',
        createdAt: DateTime(2024, 11, 28),
        category: '技术',
      ),
      Note(
        id: '4',
        title: '每日挑战',
        userId: 'user123',
        content: 'Daily challenge tasks and progress...',
        createdAt: DateTime(2024, 12, 10),
        category: '挑战',
      ),
    ];
  }

  /// Generate mock achievements
  static List<Achievement> getMockAchievements() {
    return [
      Achievement(
        id: '1',
        title: '连续完美无错',
        description: '连续答对所有题目',
        iconPath: 'assets/icons/trophy.svg',
        isUnlocked: true,
        unlockedAt: DateTime(2024, 12, 10),
        value: '3组',
      ),
      Achievement(
        id: '2',
        title: '连续登录',
        description: '连续登录应用',
        iconPath: 'assets/icons/beer.svg',
        isUnlocked: true,
        unlockedAt: DateTime(2024, 12, 1),
        value: '3天',
      ),
      Achievement(
        id: '3',
        title: '答题王',
        description: '回答100道题目',
        iconPath: 'assets/icons/crown.svg',
        isUnlocked: false,
        value: '45/100',
      ),
      Achievement(
        id: '4',
        title: '关卡错误率',
        description: '在答题中保持低错误率',
        iconPath: 'assets/icons/smiley.svg',
        isUnlocked: true,
        unlockedAt: DateTime(2024, 11, 15),
        value: '5%',
      ),
      Achievement(
        id: '5',
        title: 'NoGameNo Notebook',
        description: '完成所有游戏化笔记任务',
        iconPath: 'assets/icons/gameboy.svg',
        isUnlocked: true,
        unlockedAt: DateTime(2024, 11, 20),
        value: '',
      ),
    ];
  }

  /// Get mock ToDo list items
  static List<String> getMockTodoItems() {
    return ['完成每日挑战', '整理RAG技术笔记'];
  }
}
