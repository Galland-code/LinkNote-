import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';
import 'package:linknote/app/data/models/user_model_adapter.dart';
import 'package:path_provider/path_provider.dart';
import 'app/routes/app_pages.dart';
import 'core/theme/app_theme.dart';
import 'app/data/models/question_adapter.dart';
import 'app/data/models/note_adapter.dart';
import 'app/data/models/achievement_adapter.dart';
import 'app/data/providers/api_provider.dart';
import 'app/data/services/database_service.dart';
import 'app/data/repositories/question_repository.dart';
import 'app/data/repositories/note_repository.dart';
import 'app/data/repositories/achievement_repository.dart';
import 'app/data/repositories/user_repository.dart';
import 'app/data/repositories/task_repository.dart';
import 'app/data/services/quiz_service.dart';
import 'core/utils/mock_data.dart';
import 'app/data/models/daily_task_adapter.dart';
import 'app/data/models/user_model_adapter.dart';
import 'app/data/models/pdf_document_adapter.dart';
import 'app/data/models/quiz_challenge_adapter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 设置屏幕方向
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 设置状态栏颜色
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // 初始化Hive
  await Hive.initFlutter();

  // 注册Hive适配器
  Hive.registerAdapter(QuestionAdapter());
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(AchievementAdapter());
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(DailyTaskAdapter());
  Hive.registerAdapter(PdfDocumentAdapter());
  Hive.registerAdapter(QuizChallengeAdapter());

  // 初始化依赖注入
  await initServices();

  await Hive.deleteFromDisk(); // 删除所有 Hive 数据
  Directory appDocDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocDir.path);
  print('Hive database path: ${appDocDir.path}/hive');
   
  runApp(const MyApp());
}

// 初始化所有服务
Future<void> initServices() async {
  // API提供者
  Get.put(ApiProvider());

  // 数据库服务
  final databaseService = await Get.putAsync(() => DatabaseService().init());
  // 数据仓库
  Get.put(QuestionRepository());
  Get.put(NoteRepository());
  Get.put(AchievementRepository());
  Get.put(UserRepository());
  Get.put(TaskRepository());

  // 应用服务
  Get.put(QuizService());

  // 预加载数据
  await _preloadData();

  print('所有服务初始化完成');
}

// 预加载数据
Future<void> _preloadData() async {
  try {
    // 如果本地数据库为空，加载模拟数据
    final databaseService = Get.find<DatabaseService>();
    if (databaseService.getAllQuestions().isEmpty) {
      // 导入模拟数据到数据库
      await _importMockData();
    }
  } catch (e) {
    print('预加载数据错误: $e');
  }
}

// 导入模拟数据
Future<void> _importMockData() async {
  try {
    // 导入模拟数据到数据库
    final databaseService = Get.find<DatabaseService>();

    // 导入问题数据
    await databaseService.saveQuestions(MockData.getMockQuestions());

    // 导入笔记数据
    await databaseService.saveNotes(MockData.getMockNotes());

    // 导入成就数据
    await databaseService.saveAchievements(MockData.getMockAchievements());

    print('模拟数据导入完成');
  } catch (e) {
    print('导入模拟数据错误: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'LinkNote Study App',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false, // 去除调试横幅
      defaultTransition: Transition.cupertino, // 页面切换动画
      // 初始路由，如果有登录状态则直接进入主页，否则进入登录页
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,

      // 开启响应式UI，自动适应不同屏幕尺寸
      builder: (context, child) {
        return MediaQuery(
          // 设置文本缩放比例为1.0，防止系统字体大小影响布局
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
    );
  }
}
