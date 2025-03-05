import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../controllers/profile_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/pixel_card.dart';
import '../../../widgets/pixel_button.dart';
import '../../../widgets/pixel_empty_state.dart';

class DailyTasksView extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            image: DecorationImage(
              image: AssetImage('assets/images/grid_background.png'),
              repeat: ImageRepeat.repeat,
            ),
          ),
          child: Column(
            children: [
              _buildHeader(),
              _buildProgressSection(),
              Expanded(
                child: _buildTasksList(),
              ),
              _buildBackButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Text(
            '今日任务',
            style: AppTheme.titleStyle,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: PixelCard(
        backgroundColor: AppTheme.yellowCardColor,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // 任务完成进度
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '今日进度',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '完成更多任务获得经验',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      width: 180,
                      child: LinearProgressIndicator(
                        value: controller.completedTasksCount.value /
                            (controller.dailyTasks.isEmpty ? 1 : controller.dailyTasks.length),
                        backgroundColor: Colors.white,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                        minHeight: 12,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${controller.completedTasksCount.value}/${controller.dailyTasks.length} 已完成',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryColor, width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '获得经验',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '+${controller.getTodayExperiencePoints()}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksList() {
    return Obx(() {
      if (controller.dailyTasks.isEmpty) {
        return PixelEmptyState(
          message: '今日暂无任务',
          imagePath: 'assets/images/empty_tasks.png',
        );
      }

      return ListView(
        padding: EdgeInsets.all(16),
        children: [
          ...controller.dailyTasks.map((task) => _buildTaskItem(task)).toList(),
        ],
      );
    });
  }

  Widget _buildTaskItem(task) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: PixelCard(
        padding: EdgeInsets.all(16),
        backgroundColor: task.isCompleted ?
        AppTheme.greenCardColor.withOpacity(0.7) :
        Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 复选框
                GestureDetector(
                  onTap: () => controller.toggleTaskCompletion(task.id),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: task.isCompleted ? AppTheme.primaryColor : Colors.transparent,
                      border: Border.all(
                        color: task.isCompleted ? AppTheme.primaryColor : Colors.grey,
                        width: 2.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: task.isCompleted
                        ? Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                ),
                SizedBox(width: 16),

                // 任务标题和经验值
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                              color: task.isCompleted ? Colors.grey[600] : Colors.black,
                            ),
                          ),
                          if (task.completedAt != null) ...[
                            SizedBox(height: 4),
                            Text(
                              '完成于 ${_formatTime(task.completedAt!)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: task.isCompleted ? Colors.green[100] : Colors.amber[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: task.isCompleted ? Colors.green : Colors.amber,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: task.isCompleted ? Colors.green[800] : Colors.amber[800],
                            ),
                            SizedBox(width: 4),
                            Text(
                              '+${task.points}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: task.isCompleted ? Colors.green[800] : Colors.amber[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 任务描述
            if (task.description != null && task.description!.isNotEmpty) ...[
              Padding(
                padding: EdgeInsets.only(left: 44, top: 8, right: 8),
                child: Text(
                  task.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildBackButton() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: PixelButton(
        text: '返回',
        onPressed: () => Get.back(),
        backgroundColor: Colors.grey,
        width: double.infinity,
      ),
    );
  }
}