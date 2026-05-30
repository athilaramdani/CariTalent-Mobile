import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/core/widgets/app_card.dart';
import 'package:caritalent_mobile/core/widgets/gradient_text.dart';
import 'package:caritalent_mobile/features/auth/application/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EoProfileTab extends ConsumerWidget {
  const EoProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final user = ref.watch(authControllerProvider).user;
    final name = user?.name ?? 'Event Organizer';

    String initial = 'EO';
    if (name.isNotEmpty) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GradientText(
                'CariTalent',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ) ?? const TextStyle(),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.white),
                    onPressed: () {},
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppTheme.highlight, AppTheme.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(Icons.person_outline, color: Colors.white, size: 20),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 32),

          Text(
            'Account Settings',
            style: textTheme.labelSmall?.copyWith(color: AppTheme.highlight, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          GradientText(
            'Profile Settings',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ) ?? const TextStyle(),
          ),
          const SizedBox(height: 8),
          Text(
            'Kelola informasi akun dan keamanan kamu',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.panel,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.highlight.withValues(alpha: 0.15)),
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
                          colors: [AppTheme.highlight, AppTheme.accent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(initial, style: textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w900)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(user?.email ?? 'email@example.com', style: textTheme.bodySmall),
                          const SizedBox(height: 2),
                          Text(user?.phone ?? '-', style: textTheme.bodySmall?.copyWith(color: AppTheme.highlight)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.highlight.withValues(alpha: 0.3)),
                  ),
                  alignment: Alignment.center,
                  child: Text('Edit Profil', style: textTheme.labelLarge),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Keamanan Akun', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Ubah password untuk menjaga\nkeamanan akun kamu', style: textTheme.bodyMedium),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: AppTheme.border, height: 1),
                ),
                Text('PASSWORD SAAT INI', style: textTheme.labelSmall?.copyWith(color: AppTheme.neutralMedium, letterSpacing: 1.0)),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(8, (index) => Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppTheme.neutralMedium,
                      shape: BoxShape.circle,
                    ),
                  )),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.highlight, AppTheme.accent],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.sync, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text('Ubah Password', style: textTheme.labelLarge),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          Text('Info Platform', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Detail akun dan statistik EO kamu', style: textTheme.bodyMedium),
          const SizedBox(height: 16),
          
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
          
          Text('Additional Settings', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          
          GestureDetector(
            onTap: () {
              ref.read(authControllerProvider.notifier).logout();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
              ),
              child: Text('Logout', style: textTheme.labelLarge?.copyWith(color: Colors.redAccent)),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildStatSquare(BuildContext context, IconData icon, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                 Container(
                   padding: const EdgeInsets.all(4),
                   decoration: BoxDecoration(
                     color: AppTheme.highlight.withValues(alpha: 0.15),
                     borderRadius: BorderRadius.circular(6)
                   ),
                   child: Icon(icon, color: AppTheme.highlight, size: 14),
                 ),
                 const SizedBox(width: 8),
                 Expanded(
                   child: Text(
                     label,
                     style: textTheme.labelSmall?.copyWith(color: AppTheme.neutralMedium, letterSpacing: 0.5),
                     maxLines: 1,
                     overflow: TextOverflow.ellipsis,
                   ),
                 )
              ],
            ),
            const SizedBox(height: 16),
            Text(value, style: textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
