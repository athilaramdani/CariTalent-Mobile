import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/core/widgets/app_button.dart';
import 'package:caritalent_mobile/core/widgets/app_shell.dart';
import 'package:caritalent_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:caritalent_mobile/features/auth/presentation/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PublicHomePage extends StatelessWidget {
  const PublicHomePage({super.key});

  static const routePath = '/home';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppShell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            const Spacer(flex: 2),

            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.highlight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: AppTheme.highlight.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    'Komunitas Event Terbaik',
                    style: textTheme.labelLarge?.copyWith(
                      color: AppTheme.highlight,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Title
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: textTheme.displaySmall,
                children: [
                  const TextSpan(text: 'Temukan '),
                  TextSpan(
                    text: 'Talent Terbaik\n',
                    style: TextStyle(
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [AppTheme.highlight, AppTheme.accent],
                        ).createShader(
                          const Rect.fromLTWH(0.0, 0.0, 300.0, 50.0),
                        ),
                    ),
                  ),
                  const TextSpan(text: 'untuk Acaramu'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Platform terpercaya untuk menghubungkan\nevent organizer dengan talent profesional',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                ),
              ),
            ),

            const Spacer(flex: 3),

            // Mulai Sekarang Button (Solid)
            AppButton(
              label: 'Mulai Sekarang',
              onPressed: () => context.go(RegisterPage.routePath),
            ),

            const SizedBox(height: 16),

            // Masuk Button (Outline)
            AppButton(
              label: 'Masuk',
              variant: AppButtonVariant.outline,
              onPressed: () => context.go(LoginPage.routePath),
            ),

            const SizedBox(height: 48),

            // Bottom Text
            RichText(
              text: TextSpan(
                style: textTheme.bodyMedium,
                children: [
                  const TextSpan(text: 'Sudah dipercaya oleh '),
                  const TextSpan(
                    text: '1000+',
                    style: TextStyle(
                      color: AppTheme.highlight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: ' event organizer'),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
