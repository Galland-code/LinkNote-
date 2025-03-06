import 'package:get/get.dart';
import '../modules/quiz/controllers/quiz_controller.dart';

class QuizBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuizController>(
          () => QuizController(),
    );
  }
}
