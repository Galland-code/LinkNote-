abstract class Routes {
  // 认证路由
  static const AUTH = '/auth';
  static const AUTH_LOGIN = '/auth/login';
  static const AUTH_REGISTER = '/auth/register';

  // 主要导航路由
  static const QUIZ = '/quiz';
  static const LINK_NOTE = '/link-note';
  static const QUESTION_BANK = '/question-bank';
  static const PROFILE = '/profile';

  // Quiz 子路由
  static const QUIZ_QUESTION = '/quiz/question';
  static const QUIZ_RESULT = '/quiz/result';
  static const QUIZ_HISTORY = '/quiz/history';
  static const QUIZ_CHALLENGE_SELECT = '/quiz/challenge-select';
  static const QUIZ_LEVELS = '/quiz/levels';

  // LinkNote 子路由
  static const LINK_NOTE_EDIT = '/link-note/edit';
  static const LINK_NOTE_DETAIL = '/link-note/detail';
  static const LINK_NOTE_CATEGORY = '/link-note/category';
  static const LINK_NOTE_UPLOAD_PDF = '/link-note/uploadPDF'; // 上传 PDF 页面
  static const LINK_NOTE_NOTES_BY_CATEGORY = '/link-note/notes_by_category';

  // QuestionBank 子路由
  static const QUESTION_BANK_DETAIL = '/question-bank/detail';
  static const QUESTION_BANK_SOURCE = '/question-bank/source';

  // Profile 子路由
  static const PROFILE_EDIT = '/profile/edit';
  static const PROFILE_ACHIEVEMENTS = '/profile/achievements';
  static const PROFILE_ACHIEVEMENT_DETAIL = '/profile/achievements/detail';
  static const PROFILE_AVATAR_SELECTION = '/profile/avatar-selection';
  static const PROFILE_DAILY_TASKS = '/profile/daily-tasks';

  static const String ACHIEVEMENTS = '/achievements';
}
