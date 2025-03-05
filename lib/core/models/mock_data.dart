import 'achievement_model.dart';
import 'quiz_model.dart';
import 'note_model.dart';
import 'user_model.dart';
/// Mock data for development and testing
class MockData {
  /// Get mock quiz questions
  static List<Quiz> getMockQuizzes() {
    return [
      Quiz(
        id: '1',
        question: 'What is the basic unit of computer data storage?',
        options: ['Byte', 'Bit', 'Nibble', 'Word'],
        correctAnswer: 1,
        source: '计组复习笔记',
      ),
      Quiz(
        id: '2',
        question: 'Which of the following language executes the fastest on a computer?',
        options: ['Java', 'Python', 'C', 'JavaScript'],
        correctAnswer: 2,
        source: '计组复习笔记',
      ),
      Quiz(
        id: '3',
        question: 'What protocol is used to send email?',
        options: ['HTTP', 'FTP', 'SMTP', 'SSH'],
        correctAnswer: 2,
        source: '测试总复习PPT',
      ),
      Quiz(
        id: '4',
        question: 'Which data structure uses LIFO?',
        options: ['Queue', 'Stack', 'Linked List', 'Tree'],
        correctAnswer: 1,
        source: '计组复习笔记',
      ),
      Quiz(
        id: '5',
        question: 'What does CPU stand for?',
        options: ['Central Processing Unit', 'Computer Personal Unit', 'Central Process Utility', 'Core Processing Unit'],
        correctAnswer: 0,
        source: '计组复习笔记',
      ),
    ];
  }

  /// Get mock achievements
  static List<Achievement> getMockAchievements() {
    return [
      Achievement(
        id: '1',
        title: '连续完美无错',
        icon: 'assets/icons/trophy.png',
        description: '3组',
        date: '2024年12月10日',
        value: 3,
      ),
      Achievement(
        id: '2',
        title: '连续登录',
        icon: 'assets/icons/mug.png',
        description: '3天',
        date: '2024年12月1日',
        value: 3,
      ),
      Achievement(
        id: '3',
        title: '突击达人',
        icon: 'assets/icons/rocket.png',
        description: '5天',
        date: '2024年11月25日',
        value: 5,
      ),
      Achievement(
        id: '4',
        title: '关卡错误率',
        icon: 'assets/icons/smiley.png',
        description: '低于10%',
        date: '2024年11月20日',
        value: 10,
      ),
    ];
  }

  /// Get mock notes
  static List<Note> getMockNotes() {
    return [
      Note(
        id: '1',
        title: '第十七届全国大学生软件创新大赛',
        content: '参赛作品需求分析...',
        date: '2024-12-05',
        icon: 'assets/icons/document.png',
      ),
      Note(
        id: '2',
        title: '计组复习笔记',
        content: '1. CPU架构\n2. 内存管理\n3. 指令集...',
        date: '2024-12-01',
        icon: 'assets/icons/document.png',
      ),
      Note(
        id: '3',
        title: '操作系统期末复习',
        content: '进程管理、内存管理、文件系统...',
        date: '2024-11-25',
        icon: 'assets/icons/document.png',
      ),
    ];
  }

  /// Get mock user data
  static User getMockUser() {
    return User(
      id: 'user1',
      perfectStreak: 3,
      loginStreak: 3,
      unlockedAchievements: ['1', '2', '3', '4'],
    );
  }

  /// Get question bank analysis
  static Map<String, dynamic> getMockQuestionBankAnalysis() {
    return {
      'totalQuestions': 5,
      'sourceDistribution': {
        '计组复习笔记': 4,
        '测试总复习PPT': 1,
      },
      'errorRates': {
        '1': 0.15,
        '2': 0.25,
        '3': 0.10,
        '4': 0.30,
        '5': 0.05,
      },
    };
  }

  /// Get mock todo list
  static List<Map<String, dynamic>> getMockTodoList() {
    return [
      {
        'id': '1',
        'title': '完成每日挑战',
        'completed': false,
      },
      {
        'id': '2',
        'title': '整理RAG技术笔记',
        'completed': false,
      },
    ];
  }
}