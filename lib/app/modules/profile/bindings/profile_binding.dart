import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../auth/controllers/auth_controller.dart';
class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
    Get.lazyPut<ProfileController>(() => ProfileController());  }
}
