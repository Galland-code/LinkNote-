import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/achievement.dart';
import '../../../data/models/daily_task.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/achievement_repository.dart';
import '../../../data/repositories/task_repository.dart';
import '../../../routes/app_routes.dart';

class ProfileController extends GetxController {
  // 依赖注入
  final UserRepository _userRepository = Get.find<UserRepository>();
  final AchievementRepository _achievementRepository = Get.find<AchievementRepository>();
  final TaskRepository _taskRepository = Get.find<TaskRepository>();

  // 可观察变量
  final RxInt currentNavIndex = 3.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxList<Achievement> achievements = <Achievement>[].obs;
  final RxList<DailyTask> dailyTasks = <DailyTask>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // 选择的头像索引
  final RxInt selectedAvatarIndex = 1.obs;

  // 今日日期
  final Rx<DateTime> today = DateTime.now().obs;

  // 任务完成状态
  final RxInt completedTasksCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
    loadAchievements();
    loadDailyTasks();
  }

  // 加载用户资料
  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;
      currentUser.value = await _userRepository.getCurrentUser();
      if (currentUser.value != null && currentUser.value!.avatarIndex != null) {
        selectedAvatarIndex.value = currentUser.value!.avatarIndex!;
      }
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = '加载用户信息失败: $e';
    }
  }

  // 加载成就
  Future<void> loadAchievements() async {
    try {
      isLoading.value = true;
      achievements.value = await _achievementRepository.getAchievements();
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = '加载成就失败: $e';
    }
  }

  // 加载每日任务
  Future<void> loadDailyTasks() async {
    try {
      isLoading.value = true;
      dailyTasks.value = await _taskRepository.getDailyTasks();
      updateCompletedTasksCount();
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = '加载每日任务失败: $e';
    }
  }

  // 更新已完成任务计数
  void updateCompletedTasksCount() {
    completedTasksCount.value = dailyTasks.where((task) => task.isCompleted).length;
  }

  // 切换任务完成状态
  Future<void> toggleTaskCompletion(String taskId) async {
    try {
      final taskIndex = dailyTasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        final task = dailyTasks[taskIndex];
        final updatedTask = DailyTask(
          id: task.id,
          title: task.title,
          description: task.description,
          points: task.points,
          isCompleted: !task.isCompleted,
          completedAt: !task.isCompleted ? DateTime.now() : null,
        );

        await _taskRepository.updateTask(updatedTask);

        dailyTasks[taskIndex] = updatedTask;
        dailyTasks.refresh();

        updateCompletedTasksCount();
      }
    } catch (e) {
      errorMessage.value = '更新任务状态失败: $e';
    }
  }

  // 保存用户头像选择
  Future<void> saveAvatarSelection(int index) async {
    try {
      selectedAvatarIndex.value = index;
      if (currentUser.value != null) {
        final updatedUser = UserModel(
          username: currentUser.value!.username,
          email: currentUser.value!.email,
          avatarIndex: index,
          password: currentUser.value!.password,
          createdAt: currentUser.value!.createdAt,
          level: currentUser.value!.level,
          experiencePoints: currentUser.value!.experiencePoints
        );

        await _userRepository.updateUser(updatedUser);
        currentUser.value = updatedUser;
      }
    } catch (e) {
      errorMessage.value = '保存头像选择失败: $e';
    }
  }

  // 获取已解锁成就
  List<Achievement> getUnlockedAchievements() {
    return achievements.where((a) => a.isUnlocked).toList();
  }

  // 获取进行中成就
  List<Achievement> getInProgressAchievements() {
    return achievements.where((a) => !a.isUnlocked).toList();
  }

  // 获取任务完成进度百分比
  double getTaskCompletionPercentage() {
    if (dailyTasks.isEmpty) return 0.0;
    return completedTasksCount.value / dailyTasks.length * 100;
  }

  // 获取当前日期格式化字符串
  String getFormattedDate() {
    return DateFormat('yyyy年MM月dd日').format(today.value);
  }

  // 获取今日经验值
  int getTodayExperiencePoints() {
    return dailyTasks
        .where((task) => task.isCompleted)
        .fold(0, (sum, task) => sum + task.points);
  }

  // 导航到成就详情
  void navigateToAchievementDetail(Achievement achievement) {
    print(achievement.iconPath);
    Get.toNamed(Routes.PROFILE_ACHIEVEMENT_DETAIL, arguments: {'achievements': achievement});
  }

  // 导航到编辑资料
  void navigateToEditProfile() {
    Get.toNamed(Routes.PROFILE_EDIT);
  }
}
