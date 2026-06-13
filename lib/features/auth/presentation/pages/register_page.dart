import 'package:caritalent_mobile/app/router/app_router.dart';
import 'package:caritalent_mobile/core/constants/user_roles.dart';
import 'package:caritalent_mobile/core/widgets/app_button.dart';
import 'package:caritalent_mobile/core/widgets/app_card.dart';
import 'package:caritalent_mobile/core/widgets/app_shell.dart';
import 'package:caritalent_mobile/core/widgets/app_text_field.dart';
import 'package:caritalent_mobile/core/widgets/gradient_text.dart';
import 'package:caritalent_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:caritalent_mobile/features/auth/application/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  static const routePath = '/register';

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _stageNameController = TextEditingController();

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _role = UserRoles.talent;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _stageNameController.dispose();

    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return AppShell(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                gradient: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GradientText(
                      'Buat akun CariTalent',
                      style: GoogleFonts.syne(
                        textStyle: Theme.of(context).textTheme.headlineSmall,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pilih role mobile Anda: Talent atau EO.',
                      style: GoogleFonts.dmSans(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AppCard(
                child: Column(
                  children: [
                    SegmentedButton<String>(
                      segments: [
                        ButtonSegment(
                          value: UserRoles.talent,
                          icon: const Icon(Icons.mic_external_on),
                          label: Text(
                            'Talent',
                            style: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
                          ),
                        ),
                        ButtonSegment(
                          value: UserRoles.eo,
                          icon: const Icon(Icons.event),
                          label: Text(
                            'EO',
                            style: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      selected: {_role},
                      onSelectionChanged: (value) {
                        setState(() => _role = value.first);
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(controller: _nameController, label: 'Nama'),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _emailController,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _phoneController,
                      label: 'Nomor HP',
                      keyboardType: TextInputType.phone,
                    ),
                    if (_role == UserRoles.talent) ...[
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _stageNameController,
                        label: 'Nama Panggung',
                      ),
                    ],

                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _passwordController,
                      label: 'Kata Sandi',
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _confirmPasswordController,
                      label: 'Konfirmasi Kata Sandi',
                      obscureText: true,
                    ),
                    if (auth.errorMessage != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        auth.errorMessage!,
                        style: GoogleFonts.dmSans(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Daftar',
                      icon: Icons.person_add_alt,
                      isLoading: auth.isLoading,
                      onPressed: _register,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sudah punya akun? ',
                          style: GoogleFonts.dmSans(
                            textStyle: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go(LoginPage.routePath),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            foregroundColor: Theme.of(context).colorScheme.primary,
                          ),
                          child: Text(
                            'Masuk',
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    try {
      await ref
          .read(authControllerProvider.notifier)
          .register(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            passwordConfirmation: _confirmPasswordController.text,
            phone: _phoneController.text.trim(),
            role: _role,
            stageName: _role == UserRoles.talent ? _stageNameController.text.trim() : null,
          );
      final user = ref.read(authControllerProvider).user;
      if (mounted) context.go(dashboardRouteForRole(user?.role));
    } catch (_) {
      // Error ditampilkan dari AuthState.
    }
  }
}
