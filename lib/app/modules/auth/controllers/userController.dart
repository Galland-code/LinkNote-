import 'package:get/get.dart';

class UserController extends GetxController {
  var userId = 0.obs;

  void setUserId(int id) {
    userId.value = id; // 更新 userId
  }
}
