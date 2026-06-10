import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EoChangePasswordPage extends StatefulWidget {
  const EoChangePasswordPage({super.key});

  static const routePath = '/eo/change-password';

  @override
  State<EoChangePasswordPage> createState() => _EoChangePasswordPageState();
}

class _EoChangePasswordPageState extends State<EoChangePasswordPage> {
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.uiDark,
      appBar: AppBar(
        backgroundColor: AppTheme.panel,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('Ubah Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Buat Password Baru',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pastikan password kamu panjang dan memiliki kombinasi yang kuat menggunakan simbol demi keamanan.',
                style: TextStyle(color: Colors.white54, height: 1.5),
              ),
              const SizedBox(height: 40),
              
              _buildLabel('Password Saat Ini'),
              _buildPasswordField('Masukkan password lama', _obscureCurrent, () {
                setState(() => _obscureCurrent = !_obscureCurrent);
              }),
              const SizedBox(height: 24),
              
              _buildLabel('Password Baru'),
              _buildPasswordField('Minimal 8 karakter', _obscureNew, () {
                setState(() => _obscureNew = !_obscureNew);
              }),
              const SizedBox(height: 24),
              
              _buildLabel('Konfirmasi Password Baru'),
              _buildPasswordField('Ulangi password baru', _obscureConfirm, () {
                setState(() => _obscureConfirm = !_obscureConfirm);
              }),
              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFB500FF), Color(0xFFE94057)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement password change logic
                      context.pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password berhasil diubah')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Simpan Password Baru', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildPasswordField(String hint, bool obscureText, VoidCallback toggleVisibility) {
    return TextField(
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
        filled: true,
        fillColor: AppTheme.panel,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.highlight),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.white54,
            size: 20,
          ),
          onPressed: toggleVisibility,
        ),
      ),
    );
  }
}
