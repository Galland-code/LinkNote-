import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../network/api_client.dart';
import '../network/api_provider.dart';
import '../repository/quiz_repository.dart';
import '../repository/achievement_repository.dart';
import '../repository/note_repository.dart';
import '../repository/user_repository.dart';
import '../../ui/controllers/quiz_controller.dart';
import '../../ui/controllers/achievement_controller.dart';
import '../../ui/controllers/note_controller.dart';
import '../../ui/controllers/user_controller.dart';
import '../../ui/controllers/settings_controller.dart';

/// 依赖注入配置
class DependencyInjection {
  static Future<void> init() async {
    // 注册API相关实例
    Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    Get.lazyPut<ApiProvider>(() => ApiProvider(), fenix: true);

    // 注册仓库层
    Get.lazyPut<QuizRepository>(() => QuizRepository(), fenix: true);
    Get.lazyPut<AchievementRepository>(() => AchievementRepository(), fenix: true);
    Get.lazyPut<NoteRepository>(() => NoteRepository(), fenix: true);
    Get.lazyPut<UserRepository>(() => UserRepository(), fenix: true);

    // 注册控制器
    Get.lazyPut<QuizController>(() => QuizController(), fenix: true);
    Get.lazyPut<AchievementController>(() => AchievementController(), fenix: true);
    Get.lazyPut<NoteController>(() => NoteController(), fenix: true);
    Get.lazyPut<UserController>(() => UserController(), fenix: true);
    Get.lazyPut<SettingsController>(() => SettingsController(), fenix: true);
  }
}
