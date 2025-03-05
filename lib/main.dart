import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'core/di/dependency_injection.dart';
import 'core/routes/app_pages.dart';
import 'core/themes/app_theme.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化Hive
  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDirectory.path);

  // 注册Hive适配器
  await registerAdapters();

  // 注册依赖注入
  await DependencyInjection.init();

  runApp(const MyApp());
}

Future<void> registerAdapters() async {
  // 注册各种模型的Hive适配器
  Hive.registerAdapter(QuizAdapter());
  Hive.registerAdapter(AchievementAdapter());
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(UserAdapter());

  // 打开Hive盒子
  await Hive.openBox('quizBox');
  await Hive.openBox('achievementBox');
  await Hive.openBox('noteBox');
  await Hive.openBox('userBox');
  await Hive.openBox('settingsBox');
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Quiz App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.fade,
    );
  }
}
