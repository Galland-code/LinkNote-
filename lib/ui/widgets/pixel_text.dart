import 'package:flutter/material.dart';
import '../themes/text_styles.dart';

class PixelText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow overflow;

  const PixelText.heading(
      this.text, {
        Key? key,
        this.textAlign = TextAlign.left,
        this.maxLines,
        this.overflow = TextOverflow.ellipsis,
      })  : style = TextStyles.heading,
        super(key: key);

  const PixelText.subheading(
      this.text, {
        Key? key,
        this.textAlign = TextAlign.left,
        this.maxLines,
        this.overflow = TextOverflow.ellipsis,
      })  : style = TextStyles.subheading,
        super(key: key);

  const PixelText.body(
      this.text, {
        Key? key,
        this.textAlign = TextAlign.left,
        this.maxLines,
        this.overflow = TextOverflow.ellipsis,
        TextStyle? style,
      })  : style = style ?? TextStyles.body,
        super(key: key);

  const PixelText.caption(
      this.text, {
        Key? key,
        this.textAlign = TextAlign.left,
        this.maxLines,
        this.overflow = TextOverflow.ellipsis,
      })  : style = TextStyles.caption,
        super(key: key);

  const PixelText.custom(
      this.text, {
        Key? key,
        required this.style,
        this.textAlign = TextAlign.left,
        this.maxLines,
        this.overflow = TextOverflow.ellipsis,
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}