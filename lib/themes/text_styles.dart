import 'package:flutter/material.dart';
import 'colors.dart';

class TextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle subheading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.buttonText,
    height: 1.2,
  );

  static const TextTheme textTheme = TextTheme(
    displayLarge: heading,
    headlineMedium: subheading,
    bodyMedium: body,
    bodySmall: caption,
    labelLarge: button,
  );

  // Prevent instantiation
  TextStyles._();
}