import 'package:get/get.dart';
import '../../ui/screens/home_screen.dart';
import '../../ui/screens/quiz_screen.dart';
import '../../ui/screens/question_bank_screen.dart';
import '../../ui/screens/achievement_screen.dart';
import '../../ui/bindings/home_binding.dart';
import '../../ui/bindings/quiz_binding.dart';
import '../../ui/bindings/profile_binding.dart';
import '../../ui/bindings/achievement_binding.dart';

/// 应用路由配置
class AppPages {
  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.QUIZ,
      page: () => const QuizScreen(),
      binding: QuizBinding(),
    ),
    GetPage(
      name: Routes.QUESTION_BANK,
      page: () => const QuestionBankScreen(),
      binding: QuestionBankBinding(),
    ),
    GetPage(
      name: Routes.ACHIEVEMENTS,
      page: () => const AchievementScreen(),
      binding: AchievementBinding(),
    ),
  ];
}

/// 路由名称常量
class Routes {
  static const HOME = '/home';
  static const QUIZ = '/quiz';
  static const QUESTION_BANK = '/question_bank';
  static const ACHIEVEMENTS = '/achievements';
}