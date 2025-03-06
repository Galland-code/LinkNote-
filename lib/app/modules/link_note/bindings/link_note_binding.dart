import 'package:get/get.dart';
import '../controllers/link_note_controller.dart';

class LinkNoteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LinkNoteController>(
          () => LinkNoteController(),
    );
  }
}