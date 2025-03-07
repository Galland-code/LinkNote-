import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// SVG图标辅助类，提供统一的SVG图标加载和处理方法
class SvgHelper {
  // SVG资源路径
  static const String _svgPath = 'assets/icons/';

  /// 获取SVG图标小部件
  ///
  /// [name] SVG文件名（不含扩展名）
  /// [color] 图标颜色，为null时使用原始颜色
  /// [width] 图标宽度
  /// [height] 图标高度，为null时使用width相同值
  static Widget getSvgIcon(
      String name, {
        Color? color,
        double width = 24,
        double? height,
      }) {
    return SvgPicture.asset(
      '${_svgPath}$name.svg',
      width: width,
      height: height ?? width,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  /// 获取SVG头像图标
  static Widget getAvatarIcon(
      int index, {
        double size = 40,
        BoxFit fit = BoxFit.cover,
      }) {
    return SvgPicture.asset(
      'assets/avatars/avatar_$index.svg',
      width: size,
      height: size,
      fit: fit,
    );
  }
}

// lib/app/data/models/avatar_data.dart - 更新为使用SVG路径
class AvatarData {
  static const List<String> avatars = [
    'assets/avatars/avatar_1.svg',
    'assets/avatars/avatar_2.svg',
    'assets/avatars/avatar_3.svg',
    'assets/avatars/avatar_4.svg',
    'assets/avatars/avatar_5.svg',
    'assets/avatars/avatar_6.svg',
    'assets/avatars/avatar_7.svg',
    'assets/avatars/avatar_8.svg',
  ];
}
