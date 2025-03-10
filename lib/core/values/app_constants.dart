class AppConstants {
  // 路由常量
  static const String HOME = '/home';
  static const String QUIZ = '/quiz';
  static const String LINK_NOTE = '/link-note';
  static const String QUESTION_BANK = '/question-bank';
  static const String PROFILE = '/profile';

  // API端点
  static const String BASE_URL = 'http://82.157.18.189:8080/linknote/api'; // 修改为你的后端URL

  // 用户相关
  static const String LOGIN = '/auth/login';
  static const String REGISTER = '/auth/register';
  static const String LOGOUT = '/auth/logout';
  static const String USER_INFO = '/users/me';
  static const String UPDATE_PROFILE = '/users/update';

  // 笔记相关
  static const String UPLOAD_FILE = '/files/upload';
  static const String NOTES = '/notes';
  static const String NOTE_BY_ID = '/notes/'; // 需要附加ID
  static const String NOTES_BY_CATEGORY = '/notes/category/'; // 需要附加分类名

  // 问题相关
  static const String QUESTIONS = '/questions';
  static const String QUESTION_BY_ID = '/questions/'; // 需要附加ID
  static const String QUESTIONS_BY_SOURCE = '/questions/source/'; // 需要附加来源

  static const String GET_QUESTIONS = '/questions';
  static const String GET_NOTES = '/notes';
  static const String GET_ACHIEVEMENTS = '/achievements';

  // 成就相关
  static const String ACHIEVEMENTS = '/achievements';
  static const String UNLOCK_ACHIEVEMENT = '/achievements/unlock/'; // 需要附加ID

  // 任务相关
  static const String DAILY_TASKS = '/tasks/daily';
  static const String COMPLETE_TASK = '/tasks/complete/'; // 需要附加ID

  // Hive盒子名称
  static const String QUESTIONS_BOX = 'questions_box';
  static const String NOTES_BOX = 'notes_box';
  static const String ACHIEVEMENTS_BOX = 'achievements_box';
  static const String USER_BOX = 'user_box';
  static const String SYNC_STATUS_BOX = 'sync_status_box';
  static const String TASKS_BOX = 'tasks_box';

  // 资源路径
  static const String IMAGES_PATH = 'assets/images/';
  static const String ICONS_PATH = 'assets/icons/';
  static const String AVATARS_PATH = 'assets/images/avatars/';

  // 同步相关
  static const int SYNC_INTERVAL = 60; // 自动同步间隔（秒）

  // 其他常量
  static const int EXP_PER_LEVEL = 100; // 每级所需经验
  static const int ACHIEVEMENT_EXP_REWARD = 20; // 解锁成就奖励经验

  static const String GETIEVEMENTS_ACH =
      '/api/achievements'; // 添加 GETIEVEMENTS_ACH 常量
}
