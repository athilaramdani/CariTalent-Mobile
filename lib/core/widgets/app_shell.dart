import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.child,
    this.appBar,
    this.bottomNavigationBar,
    this.safeArea = true,
  });

  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.0, -0.6),
          radius: 1.2,
          colors: [
            Color(0xFF1E1040), // dark purple center (spotlight)
            Color(0xFF0D0B1E), // very dark navy mid
            Color(0xFF080714), // near-black edges
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: safeArea ? SafeArea(child: child) : child,
    );

    return Scaffold(
      appBar: appBar,
      body: content,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
