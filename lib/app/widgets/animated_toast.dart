import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class ResultDialog {
  static void show({
    required bool isCorrect,
    Duration duration = const Duration(seconds: 1),
  }) {
    showDialog(
      context: Get.context!,
      barrierDismissible: true,
      barrierColor: Colors.transparent, // 设置背景透明
      builder: (context) => Center(
        child: Lottie.asset(
          isCorrect
              ? 'assets/lottie/success.json'
              : 'assets/lottie/error.json',
          width: 200,
          height: 200,
          repeat: false,
          fit: BoxFit.contain,
        ),
      ),
    );

    // 自动关闭对话框
    Future.delayed(duration, () {
      if (Navigator.of(Get.context!).canPop()) {
        Navigator.of(Get.context!).pop();
      }
    });
  }
}