import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/features/auth/application/auth_controller.dart';
import 'package:caritalent_mobile/features/dashboard/application/dashboard_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TalentHomeTab extends ConsumerWidget {
  const TalentHomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header with Gradient Background
          _buildHeader(context, user?.name ?? 'Talent', textTheme),

          // 2. Overlapping Stats Grid
          Transform.translate(
            offset: const Offset(0, -40),
            child: _buildStatsGrid(context, textTheme),
          ),

          // 3. My Applications Section
          Transform.translate(
            offset: const Offset(0, -20),
            child: Column(
              children: [
                _buildSectionHeader(context, 'My Applications', 'Lamaran event terbaru', textTheme, onSeeAll: () {
                  ref.read(talentNavIndexProvider.notifier).state = 1;
                }),
                _buildApplicationCard(
                  context: context,
                  title: 'Braga Jazz Evening',
                  status: 'Accepted',
                  date: '12 Mar 2025 • 7:00 PM',
                  location: 'Braga Art Square',
                  statusColor: Colors.green,
                  textTheme: textTheme,
                ),
                _buildApplicationCard(
                  context: context,
                  title: 'Festival Musik Kemerdekaan',
                  status: 'Applied',
                  date: '17 Aug 2025 • 10:00 AM',
                  location: 'Lapangan Gasibu',
                  statusColor: Colors.purple,
                  textTheme: textTheme,
                ),
                _buildApplicationCard(
                  context: context,
                  title: 'Cafe Acoustic Night',
                  status: 'Rejected',
                  date: '05 Sep 2025 • 8:00 PM',
                  location: 'Kopi Anjis',
                  statusColor: Colors.red,
                  textTheme: textTheme,
                ),
              ],
            ),
          ),

          // 4. Bookings Section
          Transform.translate(
            offset: const Offset(0, -20),
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Bookings', 'Registrasi booking terbaru', textTheme, onSeeAll: () {
                  ref.read(talentNavIndexProvider.notifier).state = 2;
                }),
                _buildApplicationCard(
                  context: context,
                  title: 'Pernikahan Budi & Ani',
                  status: 'Confirmed',
                  date: '20 May 2025 • 19:00',
                  location: 'Gedung Sate Bandung',
                  statusColor: Colors.green,
                  textTheme: textTheme,
                ),
                _buildApplicationCard(
                  context: context,
                  title: 'Gathering Kantor Tech',
                  status: 'Pending',
                  date: '10 Jun 2025 • 18:00',
                  location: 'Hotel Transylvania',
                  statusColor: Colors.orange,
                  textTheme: textTheme,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // 5. Invitations Section
          Transform.translate(
            offset: const Offset(0, -20),
            child: Column(
              children: [
                _buildSectionHeader(context, 'Invitations', 'Undangan eksklusif dari EO', textTheme, onSeeAll: () {
                  ref.read(talentNavIndexProvider.notifier).state = 3;
                }),
                _buildApplicationCard(
                  context: context,
                  title: 'Private Birthday Party',
                  status: 'Pending',
                  date: '25 Dec 2025 • 20:00',
                  location: 'Villa Lembang',
                  statusColor: Colors.blue,
                  textTheme: textTheme,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name, TextTheme textTheme) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        bottom: 80,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.highlight, AppTheme.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selamat datang kembali',
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Jelajahi event menarik dan kelola talent dengan mudah pemesanan kamu',
            style: textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
        children: [
          _buildStatCard(context, 'TOTAL LAMARAN', '3', 'Lamaran event terkirim', Icons.assignment_outlined, textTheme),
          _buildStatCard(context, 'UNDANGAN AKTIF', '1', 'Undangan masuk dari EO', Icons.mail_outline, textTheme),
          _buildStatCard(context, 'TOTAL BOOKING', '2', 'Booking telah disetujui', Icons.check_circle_outline, textTheme),
          _buildStatCard(context, 'RATING RATA-RATA', '4.8', 'Dari total 12 ulasan', Icons.star_outline, textTheme),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, String hint, IconData icon, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.uiDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: textTheme.labelSmall?.copyWith(
                    color: AppTheme.neutralMedium,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.highlight.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppTheme.highlight, size: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            hint,
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String subtitle, TextTheme textTheme, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: textTheme.bodySmall,
              ),
            ],
          ),
          if (onSeeAll != null)
            InkWell(
              onTap: onSeeAll,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                child: Row(
                  children: [
                    Text(
                      'Lihat Semua',
                      style: textTheme.labelLarge?.copyWith(color: AppTheme.highlight),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward, color: AppTheme.highlight, size: 14),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard({
    required BuildContext context,
    required String title,
    required String status,
    required String date,
    required String location,
    required Color statusColor,
    required TextTheme textTheme,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.uiDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  status,
                  style: textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: AppTheme.neutralMedium),
              const SizedBox(width: 6),
              Text(date, style: textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: AppTheme.neutralMedium),
              const SizedBox(width: 6),
              Text(location, style: textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
