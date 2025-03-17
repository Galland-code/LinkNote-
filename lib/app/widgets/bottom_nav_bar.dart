import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/svg_helper.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex; // 当前选中的导航项索引
  final Function(int) onTap; // 点击导航项时的回调函数

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 获取屏幕宽度
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // 根据屏幕宽度计算适当的边距和内边距
    final horizontalMargin = screenWidth * 0.06; // 屏幕宽度的5%作为水平边距
    final verticalMargin = screenHeight * 0.03; // 屏幕高度的2%作为垂直边距

    // 计算导航栏高度，确保在小屏幕上不会太大
    final navBarHeight = screenHeight * 0.1; // 屏幕高度的8%
    final navBarHeight2 = navBarHeight.clamp(50.0, 70.0); // 限制最小50，最大70

    // 计算边框宽度，确保在大屏幕上不会太细
    final borderWidth = (screenWidth * 0.01).clamp(
      3.0,
      5.0,
    ); // 屏幕宽度的1%，限制在3-5之间

    // 根据屏幕宽度计算图标尺寸
    final iconSize = (screenWidth * 0.07).clamp(
      24.0,
      40.0,
    ); // 屏幕宽度的6%，限制在24-40之间
    final selectedIconSize = (iconSize * 0.8).clamp(20.0, 32.0); // 选中时图标略小

    // 计算字体大小
    final fontSize = (screenWidth * 0.04).clamp(
      14.0,
      20.0,
    ); // 屏幕宽度的4%，限制在14-20之间

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.navBarColor, // 导航栏颜色
        borderRadius: BorderRadius.circular(24), // 圆角
        border: Border.all(color: Colors.black, width: borderWidth), // 边框样式
        boxShadow: [
          // 阴影效果
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // 阴影颜色
            blurRadius: 6, // 模糊半径
            offset: Offset(0, 4), // 阴影偏移
          ),
        ],
      ),
      margin: EdgeInsets.only(
        bottom: screenHeight * 0.02, // 只有下边距
        left: screenWidth * 0.01, // 左边距
        right: screenWidth * 0.01, // 右边距
      ),
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.006, // 屏幕高度的1%
        horizontal: screenWidth * 0.01, // 屏幕宽度的2%
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround, // 子项均匀分布
        children: [
          Expanded(
            // 使用 Expanded 组件
            child: _buildNavItem(
              context,
              0,
              'notebook',
              '笔记',
              currentIndex == 0,
              iconSize,
              selectedIconSize,
              fontSize,
            ),
          ),
          Expanded(
            // 使用 Expanded 组件
            child: _buildNavItem(
              context,
              1,
              'sword',
              '闯关',
              currentIndex == 1,
              iconSize,
              selectedIconSize,
              fontSize,
            ),
          ),
          Expanded(
            // 使用 Expanded 组件
            child: _buildNavItem(
              context,
              2,
              'document',
              '错题',
              currentIndex == 2,
              iconSize,
              selectedIconSize,
              fontSize,
            ),
          ),
          Expanded(
            // 使用 Expanded 组件
            child: _buildNavItem(
              context,
              3,
              'user',
              '我的',
              currentIndex == 3,
              iconSize,
              selectedIconSize,
              fontSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    String iconName,
    String label,
    bool isSelected,
    double iconSize,
    double selectedIconSize,
    double fontSize,
  ) {
    // 获取屏幕宽度来计算项目宽度
    final screenWidth = MediaQuery.of(context).size.width;
    // 每个导航项的最大宽度，考虑到屏幕宽度的因素
    final itemMaxWidth = (screenWidth * 0.22).clamp(80.0, 120.0);

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isSelected ? itemMaxWidth : iconSize * 1.5,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.02, // 屏幕宽度的2%
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFE4E9EA) : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: isSelected ? 3 : 0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // 根据内容调整尺寸
          mainAxisAlignment: MainAxisAlignment.center, // 内容居中
          children: [
            SvgHelper.getSvgIcon(
              iconName,
              color: isSelected ? Colors.black : Colors.black54,
              width: isSelected ? selectedIconSize : iconSize,
            ),
            if (isSelected) ...[
              SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis, // 文本过长时显示省略号
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
