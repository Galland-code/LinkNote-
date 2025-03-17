import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    loadUserProfileFromSharedPreferences();
    loadAchievements();
    loadDailyTasks();
  }

  // 从SharedPreferences加载用户资料
  Future<void> loadUserProfileFromSharedPreferences() async {
    try {
      isLoading.value = true;

      // 从SharedPreferences获取用户信息
      final prefs = await SharedPreferences.getInstance();

      // 检查是否有保存的用户信息
      if (prefs.containsKey('userId')) {
        final userId = prefs.getInt('userId');
        final username = prefs.getString('username') ?? '';
        final email = prefs.getString('email') ?? '';
        final password = prefs.getString('password') ?? '';
        final createdAt = prefs.getString('createdAt') ?? '';
        final avatarIndex = prefs.getInt('avatarIndex') ?? 0;
        final level = prefs.getInt('level') ?? 1;
        final experiencePoints = prefs.getInt('experiencePoints') ?? 0;
        final lastLogin = prefs.getString('lastLogin') ?? '';

        // 构建UserModel对象
        currentUser.value = UserModel(
          id: userId,
          username: username,
          email: email,
          password: password,
          createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
          avatarIndex: avatarIndex,
          level: level,
          experiencePoints: experiencePoints,
          lastLogin: DateTime.tryParse(lastLogin),
        );

        // 设置选择的头像索引
        selectedAvatarIndex.value = avatarIndex;
      } else {
        // 如果没有保存的用户信息，尝试从仓库获取
        currentUser.value = await _userRepository.getCurrentUser();
        if (currentUser.value != null && currentUser.value!.avatarIndex != null) {
          selectedAvatarIndex.value = currentUser.value!.avatarIndex!;
        }
      }

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = '加载用户信息失败: $e';
      print('Error loading user profile: $e');
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
          id: currentUser.value!.id,
          username: currentUser.value!.username,
          email: currentUser.value!.email,
          avatarIndex: index,
          password: currentUser.value!.password,
          createdAt: currentUser.value!.createdAt,
          level: currentUser.value!.level,
          experiencePoints: currentUser.value!.experiencePoints,
          lastLogin: currentUser.value!.lastLogin,
        );

        await _userRepository.updateUser(updatedUser);
        currentUser.value = updatedUser;

        // 更新SharedPreferences中的头像索引
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('avatarIndex', index);
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

  // 更新用户经验值
  Future<void> updateUserExperience(int additionalPoints) async {
    try {
      if (currentUser.value != null) {
        final newExperiencePoints = currentUser.value!.experiencePoints + additionalPoints;
        int newLevel = currentUser.value!.level;

        // 简单的升级逻辑，每100点经验提升一级
        if (newExperiencePoints >= (currentUser.value!.level + 1) * 100) {
          newLevel = newExperiencePoints ~/ 100 + 1;
        }

        final updatedUser = UserModel(
          id: currentUser.value!.id,
          username: currentUser.value!.username,
          email: currentUser.value!.email,
          avatarIndex: currentUser.value!.avatarIndex,
          password: currentUser.value!.password,
          createdAt: currentUser.value!.createdAt,
          level: newLevel,
          experiencePoints: newExperiencePoints,
          lastLogin: currentUser.value!.lastLogin,
        );

        // 更新用户信息
        await _userRepository.updateUser(updatedUser);
        currentUser.value = updatedUser;

        // 更新SharedPreferences中的经验值和等级
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('level', newLevel);
        await prefs.setInt('experiencePoints', newExperiencePoints);
      }
    } catch (e) {
      errorMessage.value = '更新用户经验失败: $e';
    }
  }
}