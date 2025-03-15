import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/values/app_constants.dart';
import '../models/user_model.dart';
import '../providers/api_provider.dart';
import '../services/database_service.dart';
import 'package:dio/dio.dart' as dio;
import 'package:hive/hive.dart';

class UserRepository {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  // 用户登录
  Future<UserModel> login(String account, String password) async {
    try {
      final response = await _apiProvider.post(
        '${AppConstants.BASE_URL}${AppConstants.LOGIN}',
        data: {'account': account, 'password': password},
      );
      print("请求登陆");
      print('Response: ${response.data}');

      // 保存Token
      final token = response.data['token'];
      final refreshToken = response.data['refreshToken'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('refreshToken', refreshToken);

      // 返回用户信息
      UserModel user = UserModel.fromJson(response.data['user']);

      // 保存用户信息到 Hive
      var box = await Hive.openBox<UserModel>('users');
      await box.put(user.id, user); // 使用用户 ID 作为键存储用户信息
      print("获取用户信息");
      print(user);

      return user;
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  // 用户注册
  Future<UserModel> register(
    String username,
    String email,
    String password,
    int avatarIndex,
  ) async {
    try {
      final response = await _apiProvider.post(
        '${AppConstants.BASE_URL}${AppConstants.REGISTER}',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'avatarIndex': avatarIndex,
        },
      );

      return UserModel.fromJson(response.data);
    } catch (e) {
      throw e;
    }
  }

  // 获取当前用户
  Future<UserModel?> getCurrentUser() async {
    try {
      var box = await Hive.openBox<UserModel>('users');
      if (box.isNotEmpty) {
        return box.get(box.keys.first); // 获取第一个用户
      }
      return null; // 如果没有用户信息，返回 null
    } catch (e) {
      return UserModel(
        id: 1,
        username: '学习达人',
        email: 'user@example.com',
        password: '123456',
        avatarIndex: 0,
        createdAt: DateTime.now().subtract(Duration(days: 30)),
        level: 5,
        experiencePoints: 475,
      );
    }
  }

  // 更新用户信息
  Future<UserModel> updateUser(UserModel user) async {
    try {
      final response = await _apiProvider.put(
        '${AppConstants.BASE_URL}${AppConstants.UPDATE_PROFILE}',
        data: user.toJson(),
      );

      return UserModel.fromJson(response.data);
    } catch (e) {
      throw e;
    }
  }

  // 注册新用户
  Future<UserModel> registerUser(
    String username,
    String email,
    String password,
    int avatarIndex,
  ) async {
    try {
      final response = await _apiProvider.post(
        '${AppConstants.BASE_URL}${AppConstants.REGISTER}',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'avatarIndex': avatarIndex,
        },
      );
      print(response.data);
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw Exception('注册失败: $e');
    }
  }

  Future<UserModel?> getUserById(String userId) async {
    // TODO: 实现获取用户的逻辑
  }

  Future<void> createUser(UserModel user) async {
    // 实现保存用户到数据库的逻辑
  }

  // 处理响应错误
  static String _handleResponseError(dio.Response? response) {
    if (response == null) {
      return "服务器无响应";
    }

    // 根据响应状态码处理错误
    switch (response.statusCode) {
      case 400:
        return "请求错误";
      case 401:
        return "未授权";
      case 404:
        return "未找到";
      case 500:
        return "服务器错误";
      default:
        return "未知错误: ${response.statusCode}"; // 添加默认返回
    }
  }
}
