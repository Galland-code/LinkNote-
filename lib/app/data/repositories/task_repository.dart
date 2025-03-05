import 'package:get/get.dart';
import '../models/daily_task.dart';
import '../services/database_service.dart';

class TaskRepository {
  final DatabaseService _databaseService = Get.find<DatabaseService>();

  // 获取每日任务
  Future<List<DailyTask>> getDailyTasks() async {
    // 这里可以从API获取，或者从本地生成
    // 模拟数据
    return [
      DailyTask(
        id: '1',
        title: '完成5道试题',
        description: '在测验中答对至少5道题目',
        points: 10,
        isCompleted: false,
      ),
      DailyTask(
        id: '2',
        title: '创建一条笔记',
        description: '记录你学到的知识',
        points: 5,
        isCompleted: true,
        completedAt: DateTime.now().subtract(Duration(hours: 2)),
      ),
      DailyTask(
        id: '3',
        title: '复习错题',
        description: '从错题库中选择至少3道题复习',
        points: 15,
        isCompleted: false,
      ),
      DailyTask(
        id: '4',
        title: '连续登录',
        description: '今日签到成功',
        points: 3,
        isCompleted: true,
        completedAt: DateTime.now().subtract(Duration(minutes: 30)),
      ),
    ];
  }

  // 更新任务状态
  Future<void> updateTask(DailyTask task) async {
    // 实际应用中，这里应该调用API或更新本地数据库
    await Future.delayed(Duration(milliseconds: 300)); // 模拟网络延迟
    return;
  }
}
