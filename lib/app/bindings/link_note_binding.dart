import 'package:get/get.dart';
import '../modules/link_note/controllers/link_note_controller.dart';

class LinkNoteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LinkNoteController>(
          () => LinkNoteController(),
    );
  }
}
