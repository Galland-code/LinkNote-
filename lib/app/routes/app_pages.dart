import 'package:get/get.dart';
import 'package:linknote/app/modules/link_note/views/notes_by_category_view.dart';

// Auth Module
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/avatar_selection_view.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';

// Quiz Module
import '../modules/link_note/views/link_note_upload_pdf_view.dart';
import '../modules/profile/views/achievement_detail_view.dart';
import '../modules/quiz/bindings/quiz_binding.dart';
import '../modules/quiz/views/quiz_qna_difficult.dart';
import '../modules/quiz/views/quiz_challenge_select_view.dart';
import '../modules/quiz/views/quiz_levels_view.dart';
import '../modules/quiz/views/quiz_view.dart';
import '../modules/quiz/views/quiz_question_view.dart';
import '../modules/quiz/views/quiz_result_view.dart';
import '../modules/quiz/views/quiz_history_view.dart';

// LinkNote Module
import '../modules/link_note/bindings/link_note_binding.dart';
import '../modules/link_note/views/link_note_view.dart';
import '../modules/link_note/views/link_note_edit_view.dart';
import '../modules/link_note/views/link_note_detail_view.dart';
import '../modules/link_note/views/link_note_category_view.dart';

// Question Bank Module
import '../modules/question_bank/bindings/question_bank_binding.dart';
import '../modules/question_bank/views/question_bank_view.dart';
import '../modules/question_bank/views/question_bank_detail_view.dart';
import '../modules/question_bank/views/question_bank_source_view.dart';

// Profile Module
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/profile/views/edit_profile_view.dart';
import '../modules/profile/views/achievements_view.dart';
import '../modules/profile/views/achievement_detail_view.dart';
import '../modules/profile/views/avatar_selection_view.dart';
import '../modules/profile/views/daily_tasks_view.dart';

import 'app_routes.dart';

class AppPages {
  // 根据登录状态设置初始路由
  static const INITIAL = Routes.AUTH_LOGIN; // 默认从登录页面开始

  static final routes = [
    // 认证路由
    GetPage(
      name: Routes.AUTH,
      page: () => LoginView(),
      binding: AuthBinding(),
      children: [
        GetPage(
          name: '/login',
          page: () => LoginView(),
        ),
        GetPage(
          name: '/register',
          page: () => RegisterView(),
          binding: AuthBinding(),
        ),
      ],
    ),

    // Quiz路由

    // Quiz路由 (updated)
    GetPage(
      name: Routes.QUIZ,
      page: () => QuizView(),
      binding: QuizBinding(),
      children: [
        GetPage(
          name: '/question',
          page: () => QuizQuestionView(),
        ),
        GetPage(
          name: '/result',
          page: () => QuizResultView(),
        ),
        GetPage(
          name: '/history',
          page: () => QuizHistoryView(),
        ),
        GetPage(
          name: '/challenge-select',
          page: () => QuizChallengeSelectView(),
        ),
        GetPage(
          name: '/levels',
          page: () => QuizLevelsView(),
        ),
        GetPage(
          name: '/qna',
          page: () => QuizQnaView(),
        ),
      ],
    ),

    // LinkNote路由
    GetPage(
      name: Routes.LINK_NOTE,
      page: () => LinkNoteView(),
      binding: LinkNoteBinding(),
      children: [
        GetPage(
          name: '/edit',
          page: () => LinkNoteEditView(),
        ),
        GetPage(name: '/uploadPDF', page: () => LinkNoteUploadPDFView()),
        GetPage(
          name: '/detail',
          page: () => LinkNoteDetailView(),
        ),
        GetPage(
          name: '/category',
          page: () => LinkNoteCategoryView(),
        ),
        GetPage(name: '/notes_by_category', page: () => const NotesByCategoryView()),

      ],
    ),

    // QuestionBank路由
    GetPage(
      name: Routes.QUESTION_BANK,
      page: () => QuestionBankView(),
      binding: QuestionBankBinding(),
      children: [
        GetPage(
          name: '/detail',
          page: () => QuestionBankDetailView(),
        ),
        GetPage(
          name: '/source',
          page: () => QuestionBankSourceView(),
        ),
      ],
    ),

    // Profile路由
    GetPage(
      name: Routes.PROFILE,
      page: () => ProfileView(),
      binding: ProfileBinding(),
      children: [
        GetPage(
          name: '/edit',
          page: () => EditProfileView(),
        ),
        GetPage(
          name: '/achievements',
          page: () => AchievementsView(),
        ),
        GetPage(
          name: '/achievements/detail',
          page: () => AchievementDetailView(),
        ),
        GetPage(
          name: '/avatar-selection',
          page: () => AvatarSelectionView(),
        ),
        GetPage(
          name: '/daily-tasks',
          page: () => DailyTasksView(),
        ),
      ],
    ),
  ];
}
