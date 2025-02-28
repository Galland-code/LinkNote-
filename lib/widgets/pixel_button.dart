import 'package:flutter/material.dart';
import '../themes/colors.dart';
import '../themes/text_styles.dart';

class PixelButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double width;
  final double height;
  final double fontSize;

  const PixelButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = AppColors.buttonBackground,
    this.textColor = AppColors.buttonText,
    this.width = double.infinity,
    this.height = 56,
    this.fontSize = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: Text(
              text,
              style: TextStyles.button.copyWith(
                fontSize: fontSize,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}