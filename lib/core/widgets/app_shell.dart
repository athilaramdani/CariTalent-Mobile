import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.child,
    this.appBar,
    this.safeArea = true,
  });

  final Widget child;
  final PreferredSizeWidget? appBar;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    final content = DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.uiDark, Color(0xFF111827), Color(0xFF003342)],
        ),
      ),
      child: safeArea ? SafeArea(child: child) : child,
    );

    return Scaffold(appBar: appBar, body: content);
  }
}
