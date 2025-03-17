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
    // 优先从 SharedPreferences 获取
    final prefs = await SharedPreferences.getInstance();
    
    if (prefs.containsKey('userId')) {
      final userId = prefs.getInt('userId');
      final username = prefs.getString('username') ?? '';
      final email = prefs.getString('email') ?? '';
      final password = prefs.getString('password') ?? '';
      final createdAt = prefs.getString('createdAt') ?? '';
      final avatarIndex = prefs.getInt('avatarIndex') ?? 0;
      final level = prefs.getInt('level') ?? 1;
      final experiencePoints = prefs.getInt('experiencePoints') ?? 0;
      final lastLogin = prefs.getString('lastLogin') ?? '';
      
      return UserModel(
        id: userId!,
        username: username,
        email: email,
        password: password,
        createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
        avatarIndex: avatarIndex,
        level: level,
        experiencePoints: experiencePoints,
        lastLogin: DateTime.tryParse(lastLogin),
      );
    }
    
    // 如果SharedPreferences中没有数据，尝试从Hive获取
    try {
      var box = await Hive.openBox<UserModel>('users');
      if (box.isNotEmpty) {
        return box.getAt(0);
      }
    } catch (e) {
      print('Error retrieving from Hive: $e');
    }
    
    // 如果本地存储都没有，尝试从API获取
    final token = prefs.getString('token');
    if (token != null && token.isNotEmpty) {
      final response = await _apiProvider.get(
        '${AppConstants.BASE_URL}/user/profile',
      );
      final user = UserModel.fromJson(response.data);
      
      // 保存到SharedPreferences
      await _saveUserToSharedPreferences(user);
      return user;
    }
    
    return null;
  } catch (e) {
    print('Error getting current user: $e');
    return null;
  }
}
  Future<void> _saveUserToSharedPreferences(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user.id != null) {
      await prefs.setInt('userId', user.id!);
    }
    await prefs.setString('username', user.username);
    await prefs.setString('email', user.email);
    await prefs.setString('password', user.password);
    await prefs.setString('createdAt', user.createdAt.toIso8601String());
    await prefs.setInt('avatarIndex', user.avatarIndex ?? 0);
    await prefs.setInt('level', user.level);
    await prefs.setInt('experiencePoints', user.experiencePoints);

    if (user.lastLogin != null) {
      await prefs.setString('lastLogin', user.lastLogin!.toIso8601String());
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
