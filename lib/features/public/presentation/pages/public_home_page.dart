import 'package:caritalent_mobile/core/widgets/app_button.dart';
import 'package:caritalent_mobile/core/widgets/app_card.dart';
import 'package:caritalent_mobile/core/widgets/app_shell.dart';
import 'package:caritalent_mobile/core/widgets/gradient_text.dart';
import 'package:caritalent_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:caritalent_mobile/features/auth/presentation/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PublicHomePage extends StatelessWidget {
  const PublicHomePage({super.key});

  static const routePath = '/home';

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            AppCard(
              gradient: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GradientText(
                    'CariTalent',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Temukan talent, kelola event, dan pantau booking dari aplikasi mobile.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            const Spacer(),
            AppButton(
              label: 'Masuk',
              icon: Icons.login,
              onPressed: () => context.go(LoginPage.routePath),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Daftar akun baru',
              icon: Icons.person_add_alt,
              variant: AppButtonVariant.outline,
              onPressed: () => context.go(RegisterPage.routePath),
            ),
          ],
        ),
      ),
    );
  }
}
