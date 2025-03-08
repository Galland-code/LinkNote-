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
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.navBarColor, // 导航栏颜色
        borderRadius: BorderRadius.circular(24), // 圆角
        border: Border.all(color: Colors.black, width: 5), // 边框样式
        boxShadow: [
          // 阴影效果
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // 阴影颜色
            blurRadius: 6, // 模糊半径
            offset: Offset(0, 4), // 阴影偏移
          ),
        ],
      ),
      margin: EdgeInsets.all(30), // 外边距
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10), // 增加内边距以增加高度
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround, // 子项均匀分布
        children: [
          _buildNavItem(0, 'notebook', '笔记', currentIndex == 0), // 第一个导航项
          _buildNavItem(1, 'sword', '闯关', currentIndex == 1), // 第二个导航项
          _buildNavItem(2, 'document', '错题', currentIndex == 2), // 第三个导航项
          _buildNavItem(3, 'user', '我的', currentIndex == 3), // 第四个导航项
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    String iconName,
    String label,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => onTap(index), // 点击时调用回调函数
      child: Container(
        height: 60,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8), // 内边距
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFE4E9EA) : null, // 选中时的背景颜色
          borderRadius: BorderRadius.circular(20), // 圆角边框
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent, // 边框颜色
            width: 3, // 边框宽度
          ),
        ),
        child: Row(
          children: [
            SvgHelper.getSvgIcon(
              iconName,
              color: isSelected ? Colors.black : Colors.black54, // 图标颜色
              width: isSelected ? 32 : 46, // 选中时图标大小为32，未选中时为40
            ),
            if (isSelected) ...[
              // 仅在选中时显示文本
              SizedBox(width: 4), // 图标与文本之间的间距
              Text(
                label, // 导航项标签
                style: TextStyle(
                  color: Colors.black, // 文本颜色
                  fontSize: 20, // 字体大小
                  fontWeight: FontWeight.bold, // 字体粗细
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
