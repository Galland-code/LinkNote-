import 'package:flutter/material.dart';
import '../ui/screens/achievement_screen.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/quiz_screen.dart';
import '../ui/screens/question_bank_screen.dart';

/// App route configuration
class AppRoutes {
  static const String home = '/home';
  static const String quiz = '/quiz';
  static const String questionBank = '/question_bank';
  static const String achievements = '/achievements';

  /// Route map for the app
  static Map<String, WidgetBuilder> get routes => {
    home: (context) => const HomeScreen(),
    quiz: (context) => const QuizScreen(),
    questionBank: (context) => const QuestionBankScreen(),
    achievements: (context) => const AchievementScreen(),
  };
}
