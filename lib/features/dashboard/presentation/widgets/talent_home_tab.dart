import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/core/widgets/gradient_text.dart';
import 'package:caritalent_mobile/features/auth/application/auth_controller.dart';
import 'package:caritalent_mobile/core/widgets/app_header.dart';
import 'package:caritalent_mobile/features/dashboard/application/dashboard_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/pages/talent_reviews_page.dart';

class TalentHomeTab extends ConsumerWidget {
  const TalentHomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Top Navbar
            _buildTopNav(),
            const SizedBox(height: 32),

            // 2. Main Title Section
            _buildMainTitles(user?.name ?? 'The Rotten Bandung', textTheme),
            const SizedBox(height: 24),

            // 3. Stats Grid
            _buildStatsGrid(context, textTheme),
            const SizedBox(height: 32),

            // 4. Invitations Section
            _buildSectionHeader(context, 'Invitations', 'Undangan eksklusif dari EO', textTheme, onSeeAll: () {
              ref.read(talentNavIndexProvider.notifier).state = 3;
            }),
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: AppTheme.uiDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: const Center(
                child: Text(
                  'No current invitations available',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 5. Upcoming Bookings Section
            _buildSectionHeader(context, 'Upcoming Bookings', 'Registrasi booking terbaru', textTheme, onSeeAll: () {
              ref.read(talentNavIndexProvider.notifier).state = 4;
            }),
            _buildBookingCard(
              context: context,
              title: 'Pernikahan Budi & Ani',
              status: 'Confirmed',
              date: '20 May 2025',
              location: 'Gedung Sate Bandung',
              price: 'Rp 5.000.000',
              description: 'Penampilan band akustik untuk resepsi pernikahan durasi 2 jam...',
              statusColor: Colors.green,
              textTheme: textTheme,
            ),
            _buildBookingCard(
              context: context,
              title: 'Gathering Kantor Tech',
              status: 'Pending',
              date: '10 Jun 2025',
              location: 'Hotel Transylvania',
              price: 'Rp 6.500.000',
              description: 'Acara gathering perusahaan dengan target peserta 150 orang...',
              statusColor: Colors.orange,
              textTheme: textTheme,
            ),
            const SizedBox(height: 32),

            // 6. Recent Applications Section
            _buildSectionHeader(context, 'Recent Applications', 'Lamaran event terbaru', textTheme, onSeeAll: () {
              ref.read(talentNavIndexProvider.notifier).state = 2;
            }),
            _buildRecentAppCard(
              context: context,
              title: 'Braga Jazz Evening',
              status: 'Accepted',
              date: '12 Mar 2025',
              statusColor: Colors.green,
              textTheme: textTheme,
            ),
            _buildRecentAppCard(
              context: context,
              title: 'Festival Musik Kemerdekaan',
              status: 'Applied',
              date: '17 Aug 2025',
              statusColor: const Color(0xFFB500FF), // Purple
              textTheme: textTheme,
            ),
            _buildRecentAppCard(
              context: context,
              title: 'Cafe Acoustic Night',
              status: 'Rejected',
              date: '05 Sep 2025',
              statusColor: Colors.red,
              textTheme: textTheme,
            ),
            const SizedBox(height: 32),

            // 7. Talent Reviews Section
            _buildSectionHeader(context, 'Talent Reviews', 'Ulasan dari event organizer', textTheme, onSeeAll: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TalentReviewsPage()));
            }),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TalentReviewsPage()));
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF271340), Color(0xFF1B0E2A)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB500FF), Color(0xFFDE33A2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.star_rate_outlined, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lihat Semua Ulasan',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              ...List.generate(5, (i) => const Icon(Icons.star, color: Colors.amber, size: 13)),
                              const SizedBox(width: 6),
                              const Text('5.0 / 5  ·  1 ulasan', style: TextStyle(color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'What organizers say about your performance',
                            style: TextStyle(color: Colors.white38, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Color(0xFFC48DF6), size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNav() {
    return const AppHeader();
  }

  Widget _buildMainTitles(String name, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome back,',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 4),
        GradientText(
          name == 'Talent' ? 'The Rotten Bandung' : name,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ) ?? const TextStyle(),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTag('Pop Punk'),
            _buildTag('Hardcore'),
            _buildTag('Alternative Rock'),
            _buildVerifiedTag(),
          ],
        ),
      ],
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2ECC71).withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF2ECC71),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildVerifiedTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2ECC71).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.circle, color: Color(0xFF2ECC71), size: 8),
          SizedBox(width: 6),
          Text(
            'Verified Talent',
            style: TextStyle(
              color: Color(0xFF2ECC71),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, TextTheme textTheme) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.6,
      children: [
        _buildStatCard(context, 'TOTAL APPLICATIONS', '3', 'Lamaran yang sudah dikirim', Icons.assignment_outlined, const Color(0xFFC48DF6)),
        _buildStatCard(context, 'TOTAL INVITATIONS', '4', 'Undangan dari organizer', Icons.mail_outline, const Color(0xFFC48DF6)),
        _buildStatCard(context, 'TOTAL BOOKINGS', '1', 'Booking terkonfirmasi dan selesai', Icons.event_available_outlined, Colors.blue),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const TalentReviewsPage()));
          },
          child: _buildStatCard(context, 'AVERAGE RATING', '5.0 / 5', 'Berdasarkan perform terakhir', Icons.stars_outlined, Colors.blue),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, String hint, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.uiDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hint,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white54,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String subtitle, TextTheme textTheme, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle, style: textTheme.bodySmall),
          ],
        ),
        if (onSeeAll != null)
          InkWell(
            onTap: onSeeAll,
            child: Row(
              children: [
                Text(
                  'Lihat Semua',
                  style: textTheme.labelMedium?.copyWith(
                    color: const Color(0xFFC48DF6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward, color: Color(0xFFC48DF6), size: 14),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBookingCard({
    required BuildContext context,
    required String title,
    required String status,
    required String date,
    required String location,
    required String price,
    required String description,
    required Color statusColor,
    required TextTheme textTheme,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.uiDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
                   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                 ),
               ),
               Container(
                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                 decoration: BoxDecoration(
                   color: statusColor.withValues(alpha: 0.1),
                   borderRadius: BorderRadius.circular(8),
                 ),
                 child: Text(
                   status.toLowerCase(),
                   style: textTheme.labelSmall?.copyWith(
                     color: statusColor,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
               ),
            ],
          ),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.white54),
              const SizedBox(width: 8),
              Text(date, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Colors.white54),
              const SizedBox(width: 8),
              Text(location, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Agreed Price', style: TextStyle(color: Colors.white54, fontSize: 13)),
              Text(price, style: const TextStyle(color: Color(0xFF2ECC71), fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAppCard({
    required BuildContext context,
    required String title,
    required String status,
    required String date,
    required Color statusColor,
    required TextTheme textTheme,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.uiDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text('$date • ${status.toLowerCase()}', style: const TextStyle(color: Colors.white54, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status.toLowerCase(),
              style: textTheme.labelSmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
