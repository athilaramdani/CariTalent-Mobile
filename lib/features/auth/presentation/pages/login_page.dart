import 'package:caritalent_mobile/app/router/app_router.dart';
import 'package:caritalent_mobile/core/widgets/app_button.dart';
import 'package:caritalent_mobile/core/widgets/app_card.dart';
import 'package:caritalent_mobile/core/widgets/app_shell.dart';
import 'package:caritalent_mobile/core/widgets/app_text_field.dart';
import 'package:caritalent_mobile/core/widgets/gradient_text.dart';
import 'package:caritalent_mobile/features/auth/presentation/pages/register_page.dart';
import 'package:caritalent_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  static const routePath = '/login';

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return AppShell(
      appBar: AppBar(title: const Text('Masuk')),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          AppCard(
            gradient: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GradientText(
                  'Selamat datang lagi',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Masuk sebagai Talent atau Event Organizer.'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AppCard(
            child: Column(
              children: [
                AppTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                ),
                if (auth.errorMessage != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    auth.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                AppButton(
                  label: 'Masuk',
                  icon: Icons.login,
                  isLoading: auth.isLoading,
                  onPressed: _login,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go(RegisterPage.routePath),
                  child: const Text('Belum punya akun? Daftar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    try {
      await ref
          .read(authControllerProvider.notifier)
          .login(_emailController.text.trim(), _passwordController.text);
      final user = ref.read(authControllerProvider).user;
      if (mounted) context.go(dashboardRouteForRole(user?.role));
    } catch (_) {
      // Error ditampilkan dari AuthState.
    }
  }
}
