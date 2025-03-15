import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import '../../../core/values/app_constants.dart';

/// 用户认证服务，处理用户登录、注册、退出等操作
class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepository = Get.find<UserRepository>();

  // 观察变量 - 当前用户
  final Rxn<UserModel> currentUser = Rxn<UserModel>();

  // 登录状态
  final RxBool isLoggedIn = false.obs;

  // 加载状态
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 监听认证状态变化
    _auth.authStateChanges().listen(_authStateChanged);
  }

  // 认证状态变化处理
  void _authStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      // 未登录状态
      currentUser.value = null;
      isLoggedIn.value = false;
    } else {
      // 已登录状态，获取用户信息
      try {
        isLoading.value = true;
        UserModel? user = await _userRepository.getUserById(firebaseUser.uid);
        if (user != null) {
          currentUser.value = user;
          isLoggedIn.value = true;
        }
      } finally {
        isLoading.value = false;
      }
    }
  }

  // 电子邮件密码登录
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // 电子邮件密码注册
  Future<bool> createUserWithEmailAndPassword(
    String email,
    String password,
    String username,
  ) async {
    try {
      isLoading.value = true;
      // 创建Firebase用户
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 创建用户模型
      UserModel user = UserModel(
        username: username,
        email: email,
        password: password,
        createdAt: DateTime.now(),
        level: 1,
        experiencePoints: 0,
        avatarIndex: 0,
      );

      // 保存到数据库
      await _userRepository.createUser(user);

      return true;
    } catch (e) {
      return false;
    }
  }

  // 退出登录
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      // 错误处理
    }
  }

  // 获取当前用户ID
  String? get currentUserId => _auth.currentUser?.uid;

  // 重置密码
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      return false;
    }
  }
}
