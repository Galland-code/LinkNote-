import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../widgets/base_scaffold.dart';
import '../../../widgets/pixel_card.dart';
import '../../../widgets/pixel_button.dart';
import '../../../../core/theme/app_theme.dart';

class ThemeSettingsView extends StatelessWidget {
  final ThemeProvider themeProvider = Get.find<ThemeProvider>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => BaseScaffold(
      // 使用主题提供者的设置
      backgroundColor: themeProvider.backgroundColor,
      gridColor: themeProvider.gridColor,
      gridSize: themeProvider.gridSize.value,
      usePixelGrid: themeProvider.usePixelGrid.value,
      enhanced: themeProvider.useEnhancedGrid.value,
      useNoise: themeProvider.useNoiseEffect.value,

      // 页面头部
      header: Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Text(
              '主题设置',
              style: AppTheme.titleStyle,
            ),
          ),
        ),
      ),

      // 页面内容
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThemeModeSection(),
            SizedBox(height: 16),
            _buildGridStyleSection(),
            SizedBox(height: 16),
            _buildGridSizeSection(),
            SizedBox(height: 16),
            _buildResetButton(),
          ],
        ),
      ),
    ));
  }

  // 主题模式选择部分
  Widget _buildThemeModeSection() {
    return PixelCard(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '主题模式',
            style: AppTheme.subtitleStyle,
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: PixelButton(
                  text: '浅色模式',
                  onPressed: () => themeProvider.isDarkMode.value ? themeProvider.toggleThemeMode() : null,
                  backgroundColor: !themeProvider.isDarkMode.value
                      ? AppTheme.primaryColor
                      : Colors.grey,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: PixelButton(
                  text: '深色模式',
                  onPressed: () => !themeProvider.isDarkMode.value ? themeProvider.toggleThemeMode() : null,
                  backgroundColor: themeProvider.isDarkMode.value
                      ? AppTheme.primaryColor
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 网格样式选择部分
  Widget _buildGridStyleSection() {
    return PixelCard(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '网格样式',
            style: AppTheme.subtitleStyle,
          ),
          SizedBox(height: 16),
          SwitchListTile(
            title: Text('像素风格网格'),
            value: themeProvider.usePixelGrid.value,
            onChanged: (value) => themeProvider.setGridStyle(isPixel: value),
            activeColor: AppTheme.primaryColor,
          ),
          Divider(),
          SwitchListTile(
            title: Text('增强效果'),
            value: themeProvider.useEnhancedGrid.value,
            onChanged: themeProvider.usePixelGrid.value // 根据 usePixelGrid 的值来控制开关的启用状态
                ? (value) => themeProvider.setGridStyle(isEnhanced: value)
                : null, // 如果 usePixelGrid 为 false，则禁用开关
            activeColor: AppTheme.primaryColor,
          ),
          Divider(),
          SwitchListTile(
            title: Text('噪点效果'),
            value: themeProvider.useNoiseEffect.value,
            onChanged: (themeProvider.usePixelGrid.value && themeProvider.useEnhancedGrid.value) 
                ? (value) => themeProvider.setGridStyle(hasNoise: value)
                : null, // 如果条件不满足，则禁用开关
            activeColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  // 网格大小调整部分
  Widget _buildGridSizeSection() {
    return PixelCard(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '网格大小',
            style: AppTheme.subtitleStyle,
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Text('小'),
              Expanded(
                child: Slider(
                  value: themeProvider.gridSize.value,
                  min: 10.0,
                  max: 30.0,
                  divisions: 4,
                  onChanged: (value) => themeProvider.setGridSize(value),
                  activeColor: AppTheme.primaryColor,
                ),
              ),
              Text('大'),
            ],
          ),
          Center(
            child: Text(
              '${themeProvider.gridSize.value.toInt()} px',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 重置按钮
  Widget _buildResetButton() {
    return Center(
      child: PixelButton(
        text: '恢复默认设置',
        onPressed: () => themeProvider.resetToDefaults(),
        width: 200,
        backgroundColor: Colors.grey,
      ),
    );
  }
}
