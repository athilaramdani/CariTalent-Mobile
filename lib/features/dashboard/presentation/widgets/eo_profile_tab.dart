import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/core/widgets/gradient_text.dart';
import 'package:caritalent_mobile/features/auth/application/auth_controller.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/pages/eo_change_password_page.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/pages/eo_edit_profile_page.dart';
import 'package:caritalent_mobile/features/public/presentation/pages/public_home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EoProfileTab extends ConsumerWidget {
  const EoProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final user = ref.watch(authControllerProvider).user;
    final name = user?.name ?? 'Alex Rodriguez'; // Fallback matching design
    final email = user?.email ?? '@alexrodriguez';
    final phone = user?.phone ?? '0821678909090';

    String initial = 'AR';
    if (name.isNotEmpty && name != 'Alex Rodriguez') {
      final parts = name.split(' ');
      if (parts.length > 1) {
        initial = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else {
        initial = parts[0][0].toUpperCase();
      }
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
// Removed redundant local header

          const Text(
            'Account Settings',
            style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          GradientText(
            'Profile Settings',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ) ?? const TextStyle(),
          ),
          const SizedBox(height: 8),
          const Text(
            'Kelola informasi akun dan keamanan kamu',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.uiDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                           colors: [Color(0xFFB500FF), Color(0xFFE94057)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(initial, style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w900)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(email, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(phone, style: const TextStyle(color: Color(0xFFC026D3), fontSize: 13, fontWeight: FontWeight.w500)), // Subtle purple
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => context.push(EoEditProfilePage.routePath),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    alignment: Alignment.center,
                    child: const Text('Edit Profil', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.uiDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Keamanan Akun', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Ubah password untuk menjaga\nkeamanan akun kamu', style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
                ),
                const Text('PASSWORD SAAT INI', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 2.0, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(8, (index) => Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Colors.white, // Bright solid circles
                      shape: BoxShape.circle,
                    ),
                  )),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => context.push(EoChangePasswordPage.routePath),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFB500FF), Color(0xFFE94057)], // Pink to magenta
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(30), // Highly rounded pill
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.sync, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text('Ubah Password', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          const Text('Info Platform', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Detail akun dan statistik EO kamu', style: TextStyle(color: Colors.white70, fontSize: 13)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
          ),
          
          Row(
            children: [
              _buildStatSquare(context, Icons.business_center_outlined, 'ROLE', 'Event Organizer'),
              const SizedBox(width: 12),
              _buildStatSquare(context, Icons.event_outlined, 'TOTAL EVENTS', '10'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
               _buildStatSquare(context, Icons.book_online_outlined, 'TOTAL BOOKINGS', '2'),
              const SizedBox(width: 12),
              _buildStatSquare(context, Icons.verified_user_outlined, 'MEMBER SEJAK', '2026'),
            ],
          ),
          
          const SizedBox(height: 32),
          
          const Text('Additional Settings', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          GestureDetector(
            onTap: () {
              ref.read(authControllerProvider.notifier).logout();
              context.go(PublicHomePage.routePath);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.15)),
              ),
              child: const Text('Logout', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildStatSquare(BuildContext context, IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.uiDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                 Container(
                   padding: const EdgeInsets.all(4),
                   decoration: BoxDecoration(
                     color: AppTheme.highlight.withValues(alpha: 0.1),
                     borderRadius: BorderRadius.circular(6)
                   ),
                   child: Icon(icon, color: AppTheme.highlight, size: 14),
                 ),
                 const SizedBox(width: 8),
                 Expanded(
                   child: Text(
                     label,
                     style: const TextStyle(color: Colors.white38, fontSize: 9, letterSpacing: 1.5, fontWeight: FontWeight.w700),
                     maxLines: 1,
                     overflow: TextOverflow.ellipsis,
                   ),
                 )
              ],
            ),
            const SizedBox(height: 16),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
