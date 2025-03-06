import 'package:flutter/material.dart';

/// 应用动画定义
class AppAnimations {
  // 淡入淡出动画
  static Animation<double> fadeIn(AnimationController controller) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  // 缩放动画
  static Animation<double> scale(AnimationController controller) {
    return Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  // 上滑动画
  static Animation<Offset> slideUp(AnimationController controller) {
    return Tween<Offset>(begin: Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  // 下滑动画
  static Animation<Offset> slideDown(AnimationController controller) {
    return Tween<Offset>(begin: Offset(0, -1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  // 左滑动画
  static Animation<Offset> slideLeft(AnimationController controller) {
    return Tween<Offset>(begin: Offset(1, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  // 右滑动画
  static Animation<Offset> slideRight(AnimationController controller) {
    return Tween<Offset>(begin: Offset(-1, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  // 弹跳动画
  static Animation<double> bounce(AnimationController controller) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.bounceOut,
      ),
    );
  }

  // 闪烁动画
  static Animation<double> pulse(AnimationController controller) {
    return TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.2), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 1),
    ]).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );
  }
}