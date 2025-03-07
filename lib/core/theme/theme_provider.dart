import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app_theme.dart';

/// 主题提供者，管理应用主题设置
class ThemeProvider extends GetxController {
  // 定义可观察变量
  final RxBool isDarkMode = false.obs;
  final RxDouble gridSize = 20.0.obs;
  final RxBool usePixelGrid = true.obs;
  final RxBool useEnhancedGrid = true.obs;
  final RxBool useNoiseEffect = true.obs;

  // 背景和网格颜色
  final Rx<Color> backgroundColorLight = Color(0xFFF5F5DC).obs;
  final Rx<Color> gridColorLight = Color(0xFFE6E6C8).obs;
  final Rx<Color> backgroundColorDark = Color(0xFF2D2D2D).obs;
  final Rx<Color> gridColorDark = Color(0xFF3A3A3A).obs;

  // 获取当前背景色
  Color get backgroundColor => isDarkMode.value
      ? backgroundColorDark.value
      : backgroundColorLight.value;

  // 获取当前网格色
  Color get gridColor => isDarkMode.value
      ? gridColorDark.value
      : gridColorLight.value;

  // 切换暗色/亮色模式
  void toggleThemeMode() {
    isDarkMode.value = !isDarkMode.value;

    // 更新GetX主题
    Get.changeTheme(getThemeData());

    // 保存设置（可选）
    _saveSettings();
  }

  // 获取当前主题数据
  ThemeData getThemeData() {
    return isDarkMode.value ? AppTheme.darkTheme : AppTheme.lightTheme;
  }

  // 修改网格大小
  void setGridSize(double size) {
    gridSize.value = size;
    _saveSettings();
  }

  // 设置网格风格
  void setGridStyle({
    bool? isPixel,
    bool? isEnhanced,
    bool? hasNoise,
  }) {
    if (isPixel != null) usePixelGrid.value = isPixel;
    if (isEnhanced != null) useEnhancedGrid.value = isEnhanced;
    if (hasNoise != null) useNoiseEffect.value = hasNoise;
    _saveSettings();
  }

  // 自定义背景颜色
  void setBackgroundColor(Color color, {bool isDark = false}) {
    if (isDark) {
      backgroundColorDark.value = color;
    } else {
      backgroundColorLight.value = color;
    }
    _saveSettings();
  }

  // 自定义网格颜色
  void setGridColor(Color color, {bool isDark = false}) {
    if (isDark) {
      gridColorDark.value = color;
    } else {
      gridColorLight.value = color;
    }
    _saveSettings();
  }

  // 恢复默认设置
  void resetToDefaults() {
    isDarkMode.value = false;
    gridSize.value = 20.0;
    usePixelGrid.value = true;
    useEnhancedGrid.value = true;
    useNoiseEffect.value = true;

    backgroundColorLight.value = Color(0xFFF5F5DC);
    gridColorLight.value = Color(0xFFE6E6C8);
    backgroundColorDark.value = Color(0xFF2D2D2D);
    gridColorDark.value = Color(0xFF3A3A3A);

    Get.changeTheme(AppTheme.lightTheme);
    _saveSettings();
  }

  // 保存设置
  void _saveSettings() {
    // 这里可以使用 SharedPreferences 或 Hive 保存设置
    // 例如：
    /*
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isDarkMode.value);
    prefs.setDouble('gridSize', gridSize.value);
    prefs.setBool('usePixelGrid', usePixelGrid.value);
    // 等等...
    */
  }

  // 加载设置
  Future<void> loadSettings() async {
    // 这里可以从 SharedPreferences 或 Hive 加载设置
    // 例如：
    /*
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool('isDarkMode') ?? false;
    gridSize.value = prefs.getDouble('gridSize') ?? 20.0;
    usePixelGrid.value = prefs.getBool('usePixelGrid') ?? true;
    // 等等...

    // 应用加载的设置
    Get.changeTheme(getThemeData());
    */
  }

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }
}
