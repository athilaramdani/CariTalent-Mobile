import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.gradient = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
        gradient:
            gradient
                ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.highlight.withValues(alpha: 0.20),
                    Colors.white.withValues(alpha: 0.06),
                    AppTheme.accent.withValues(alpha: 0.16),
                  ],
                )
                : null,
        color: gradient ? null : Colors.white.withValues(alpha: 0.06),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
