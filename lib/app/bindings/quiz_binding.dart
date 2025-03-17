import 'package:get/get.dart';
import '../modules/quiz/controllers/quiz_controller.dart';
import '../modules/link_note/controllers/link_note_controller.dart';
class QuizBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(LinkNoteController()); // 确保在 QuizBinding 中注册 LinkNoteController

    Get.lazyPut<QuizController>(
          () => QuizController(),
    );
  }
}
