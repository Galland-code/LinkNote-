import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../core/repository/user_repository.dart';

/// 设置控制器，管理应用设置相关状态和逻辑
class SettingsController extends GetxController {
  final UserRepository _userRepository = Get.find<UserRepository>();

  // 响应式状态变量
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  final RxBool notificationsEnabled = true.obs;
  final RxString language = 'zh_CN'.obs;
  final RxDouble fontSize = 14.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  // 加载设置
  Future<void> loadSettings() async {
    try {
      final user = await _userRepository.getCurrentUser();
      if (user != null) {
        final settings = _userRepository.getUserSettings(user.id);
        if (settings != null) {
          themeMode.value = ThemeMode.values[settings['themeMode'] ?? 0];
          notificationsEnabled.value = settings['notificationsEnabled'] ?? true;
          language.value = settings['language'] ?? 'zh_CN';
          fontSize.value = settings['fontSize'] ?? 14.0;
        }
      }
    } catch (e) {
      print('加载设置失败: $e');
    }
  }

  // 保存设置
  Future<void> saveSettings() async {
    try {
      final user = await _userRepository.getCurrentUser();
      if (user != null) {
        final settings = {
          'themeMode': themeMode.value.index,
          'notificationsEnabled': notificationsEnabled.value,
          'language': language.value,
          'fontSize': fontSize.value,
        };

        await _userRepository.saveUserSettings(user.id, settings);
      }
    } catch (e) {
      print('保存设置失败: $e');
    }
  }

  // 设置主题模式
  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    Get.changeThemeMode(mode);
    saveSettings();
  }

  // 切换通知状态
  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
    saveSettings();
  }

  // 设置语言
  void setLanguage(String languageCode) {
    language.value = languageCode;
    Get.updateLocale(Locale(languageCode));
    saveSettings();
  }

  // 设置字体大小
  void setFontSize(double size) {
    fontSize.value = size;
    saveSettings();
  }
}