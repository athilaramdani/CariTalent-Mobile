import 'package:caritalent_mobile/app/router/app_router.dart';
import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/core/constants/user_roles.dart';
import 'package:caritalent_mobile/features/auth/application/auth_controller.dart';
import 'package:caritalent_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:caritalent_mobile/features/auth/presentation/pages/register_talent_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterEoPage extends ConsumerStatefulWidget {
  const RegisterEoPage({super.key});

  static const routePath = '/register/eo';

  @override
  ConsumerState<RegisterEoPage> createState() => _RegisterEoPageState();
}

class _RegisterEoPageState extends ConsumerState<RegisterEoPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Header Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.highlight.withValues(alpha: 0.20),
                      Colors.white.withValues(alpha: 0.06),
                      AppTheme.accent.withValues(alpha: 0.16),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                        children: [
                          TextSpan(text: 'Buat akun '),
                          TextSpan(
                            text: 'CariTalent',
                            style: TextStyle(color: Color(0xFFF472B6)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pilih role mobile kamu: Talent atau EO.',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Segmented Role Toggle (EO Selected)
              Center(
                child: Container(
                  width: 220,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.go(RegisterTalentPage.routePath),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            color: Colors.transparent,
                            alignment: Alignment.center,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.mic, size: 14, color: Colors.white54),
                                SizedBox(width: 4),
                                Text(
                                  'Talent',
                                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
                            ),
                            borderRadius: BorderRadius.circular(26),
                          ),
                          alignment: Alignment.center,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check, size: 14, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'EO',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Inputs matching EO screenshot exactly
              _buildInput(
                controller: _nameController,
                hint: 'Nama',
              ),
              const SizedBox(height: 14),
              _buildInput(
                controller: _emailController,
                hint: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              _buildInput(
                controller: _phoneController,
                hint: 'Nomor HP',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),
              _buildInput(
                controller: _passwordController,
                hint: 'Password',
                obscureText: _obscurePassword,
                isPassword: true,
                onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              const SizedBox(height: 14),
              _buildInput(
                controller: _confirmPasswordController,
                hint: 'Konfirmasi password',
                obscureText: _obscureConfirmPassword,
                isPassword: true,
                onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),

              if (auth.errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  auth.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 28),

              // Purple Signup Button
              Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB57AFF), Color(0xFF8B5CF6)],
                  ),
                ),
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: auth.isLoading
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Daftar',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Sudah punya akun? ', style: TextStyle(color: Colors.white54, fontSize: 14)),
                  GestureDetector(
                    onTap: () => context.go(LoginPage.routePath),
                    child: const Text(
                      'Masuk',
                      style: TextStyle(color: Color(0xFFF472B6), fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool isPassword = false,
    VoidCallback? onToggle,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.04),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.white38, size: 18),
                onPressed: onToggle,
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB57AFF)),
        ),
      ),
    );
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua field.')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi password tidak cocok.')),
      );
      return;
    }

    try {
      await ref.read(authControllerProvider.notifier).register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: confirmPassword,
        phone: phone,
        role: UserRoles.eo,
      );
      final user = ref.read(authControllerProvider).user;
      if (user != null && mounted) {
        context.go(dashboardRouteForRole(user.role));
      }
    } catch (_) {}
  }
}
