import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'routes.dart';
import 'screens/quiz/quiz_screen.dart';
import 'screens/notes/note_screen.dart';
import 'screens/quiz/quiz_collection_screen.dart';
import 'screens/achievements/achievements_screen.dart';
import 'themes/app_theme.dart';

class PixelNoteApp extends StatelessWidget {
  const PixelNoteApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lock orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: 'Pixel Note App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.quiz,
      routes: {
        AppRoutes.quiz: (context) => const QuizScreen(),
        AppRoutes.notes: (context) => const NoteScreen(),
        AppRoutes.quizCollection: (context) => const QuizCollectionScreen(),
        AppRoutes.achievements: (context) => const AchievementsScreen(),
      },
    );
  }
}