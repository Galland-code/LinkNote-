class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String source;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    required this.source,
  });
}

class QuizCollection {
  final String id;
  final String title;
  final String source;
  final List<QuizQuestion> questions;
  final int totalQuestions;

  const QuizCollection({
    required this.id,
    required this.title,
    required this.source,
    required this.questions,
    required this.totalQuestions,
  });
}

// Sample data
final List<QuizCollection> sampleQuizCollections = [
  QuizCollection(
    id: '1',
    title: '计组复习笔记',
    source: '计组复习笔记',
    questions: [
      QuizQuestion(
        id: '1',
        question: 'What is the basic unit of computer data storage?',
        options: ['Bit', 'Byte', 'Kilobyte', 'Megabyte'],
        correctOptionIndex: 1,
        source: '计组复习笔记',
      ),
      QuizQuestion(
        id: '2',
        question: 'Which of the following language executes the fastest on a computer?',
        options: ['Java', 'Python', 'C', 'JavaScript'],
        correctOptionIndex: 2,
        source: '计组复习笔记',
      ),
    ],
    totalQuestions: 2,
  ),
  QuizCollection(
    id: '2',
    title: '测试总复习PPT',
    source: '测试总复习PPT',
    questions: [
      QuizQuestion(
        id: '3',
        question: 'What is a test case?',
        options: ['A document', 'A set of inputs and expected results', 'A bug report', 'A test plan'],
        correctOptionIndex: 1,
        source: '测试总复习PPT',
      ),
    ],
    totalQuestions: 1,
  ),
];