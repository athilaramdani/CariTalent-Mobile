import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class GradientText extends StatelessWidget {
  const GradientText(this.text, {super.key, this.style, this.textAlign});

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback:
          (bounds) => const LinearGradient(
            colors: [AppTheme.highlight, AppTheme.accent],
          ).createShader(bounds),
      child: Text(text, style: style, textAlign: textAlign),
    );
  }
}
