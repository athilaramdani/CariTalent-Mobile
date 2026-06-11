import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/core/widgets/gradient_text.dart';
import 'package:caritalent_mobile/features/auth/application/auth_controller.dart';
import 'package:caritalent_mobile/core/widgets/app_header.dart';
import 'package:caritalent_mobile/features/dashboard/application/dashboard_providers.dart';
import 'package:caritalent_mobile/features/dashboard/domain/invitation_model.dart';
import 'package:caritalent_mobile/features/dashboard/domain/booking_model.dart';
import 'package:caritalent_mobile/features/dashboard/domain/application_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/pages/talent_reviews_page.dart';

class TalentHomeTab extends ConsumerWidget {
  const TalentHomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final textTheme = Theme.of(context).textTheme;

    // Watch all data
    final talentAsync = ref.watch(myTalentProvider);
    final invitationsAsync = ref.watch(myInvitationsProvider);
    final bookingsAsync = ref.watch(myBookingsProvider);
    final applicationsAsync = ref.watch(myApplicationsProvider);
    final reviewsAsync = ref.watch(myReviewsProvider);

    final name = user?.name ?? 'Talent';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Top Navbar
            const AppHeader(),
            const SizedBox(height: 32),

            // 2. Main Title Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back,',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 4),
                GradientText(
                  name,
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ) ?? const TextStyle(),
                ),
                const SizedBox(height: 16),
                talentAsync.when(
                  data: (talent) => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...talent.genre.take(3).map((g) => _buildTag(g)),
                      if (talent.verified) _buildVerifiedTag(),
                    ],
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. Stats Grid from real data
            _buildStatsGridLive(context, textTheme, ref,
              applicationsAsync: applicationsAsync,
              invitationsAsync: invitationsAsync,
              bookingsAsync: bookingsAsync,
              reviewsAsync: reviewsAsync,
            ),
            const SizedBox(height: 32),

            // 4. Invitations Section
            _buildSectionHeader(context, 'Invitations', 'Undangan eksklusif dari EO', textTheme, onSeeAll: () {
              ref.read(talentNavIndexProvider.notifier).state = 3;
            }),
            const SizedBox(height: 12),
            invitationsAsync.when(
              data: (invitations) {
                final pending = invitations.where((i) => i.status == 'pending').toList();
                if (pending.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    decoration: BoxDecoration(
                      color: AppTheme.uiDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: const Center(
                      child: Text(
                        'Tidak ada undangan aktif',
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ),
                  );
                }
                return Column(
                  children: pending.take(2).map((inv) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildInvitationCard(context, inv, textTheme, ref),
                  )).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 32),

            // 5. Upcoming Bookings Section
            _buildSectionHeader(context, 'Upcoming Bookings', 'Booking terkonfirmasi', textTheme, onSeeAll: () {
              ref.read(talentNavIndexProvider.notifier).state = 4;
            }),
            const SizedBox(height: 12),
            bookingsAsync.when(
              data: (bookings) {
                final upcoming = bookings.where((b) => b.status == 'confirmed').toList();
                if (upcoming.isEmpty) {
                  return _buildEmptyCard('Tidak ada upcoming bookings');
                }
                return Column(
                  children: upcoming.take(2).map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildBookingCardLive(context, b, textTheme),
                  )).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 32),

            // 6. Recent Applications Section
            _buildSectionHeader(context, 'Recent Applications', 'Lamaran event terbaru', textTheme, onSeeAll: () {
              ref.read(talentNavIndexProvider.notifier).state = 2;
            }),
            const SizedBox(height: 12),
            applicationsAsync.when(
              data: (applications) {
                if (applications.isEmpty) {
                  return _buildEmptyCard('Belum ada lamaran');
                }
                return Column(
                  children: applications.take(3).map((app) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildRecentAppCardLive(context, app, textTheme),
                  )).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 32),

            // 7. Talent Reviews Section
            _buildSectionHeader(context, 'Talent Reviews', 'Ulasan dari event organizer', textTheme, onSeeAll: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const TalentReviewsPage()));
            }),
            const SizedBox(height: 12),
            reviewsAsync.when(
              data: (data) {
                final rating = data.averageRating.toStringAsFixed(1);
                final count = data.totalReviews;
                return GestureDetector(
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
                                  ...List.generate(5, (i) => Icon(
                                    i < data.averageRating.floor() ? Icons.star : Icons.star_border,
                                    color: Colors.amber, size: 13,
                                  )),
                                  const SizedBox(width: 6),
                                  Text('$rating / 5  ·  $count ulasan',
                                    style: const TextStyle(color: Colors.white54, fontSize: 12)),
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
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
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
        style: const TextStyle(color: Color(0xFF2ECC71), fontSize: 10, fontWeight: FontWeight.w500),
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
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: Color(0xFF2ECC71), size: 8),
          SizedBox(width: 6),
          Text('Verified Talent', style: TextStyle(color: Color(0xFF2ECC71), fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatsGridLive(
    BuildContext context,
    TextTheme textTheme,
    WidgetRef ref, {
    required AsyncValue applicationsAsync,
    required AsyncValue invitationsAsync,
    required AsyncValue bookingsAsync,
    required AsyncValue reviewsAsync,
  }) {
    final appCount = applicationsAsync.when(
      data: (apps) => '${(apps as List).length}', loading: () => '—', error: (_, __) => '—');
    final invCount = invitationsAsync.when(
      data: (invs) => '${(invs as List).length}', loading: () => '—', error: (_, __) => '—');
    final bookCount = bookingsAsync.when(
      data: (bkgs) => '${(bkgs as List).length}', loading: () => '—', error: (_, __) => '—');
    final rating = reviewsAsync.when(
      data: (r) {
        final data = r as dynamic;
        return '${data.averageRating.toStringAsFixed(1)} / 5';
      },
      loading: () => '— / 5',
      error: (_, __) => '— / 5',
    );

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.6,
      children: [
        _buildStatCard(context, 'TOTAL APPLICATIONS', appCount, 'Lamaran yang sudah dikirim',
            Icons.assignment_outlined, const Color(0xFFC48DF6)),
        _buildStatCard(context, 'TOTAL INVITATIONS', invCount, 'Undangan dari organizer',
            Icons.mail_outline, const Color(0xFFC48DF6)),
        _buildStatCard(context, 'TOTAL BOOKINGS', bookCount, 'Booking terkonfirmasi dan selesai',
            Icons.event_available_outlined, Colors.blue),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TalentReviewsPage())),
          child: _buildStatCard(context, 'AVERAGE RATING', rating, 'Berdasarkan perform terakhir',
              Icons.stars_outlined, Colors.blue),
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
                  child: Text(title,
                    style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w600),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, height: 1.0),
          ),
          const SizedBox(height: 4),
          Text(hint,
            style: const TextStyle(fontSize: 10, color: Colors.white54, height: 1.2),
            maxLines: 2, overflow: TextOverflow.ellipsis,
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
                Text('Lihat Semua',
                  style: textTheme.labelMedium?.copyWith(color: const Color(0xFFC48DF6), fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward, color: Color(0xFFC48DF6), size: 14),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyCard(String msg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: AppTheme.uiDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Center(child: Text(msg, style: const TextStyle(color: Colors.white54, fontSize: 13))),
    );
  }

  Widget _buildInvitationCard(BuildContext context, InvitationModel inv, TextTheme textTheme, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.uiDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(inv.eventTitle,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('${inv.eventDateFormatted} • ${inv.offeredPriceFormatted}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => ref.read(talentNavIndexProvider.notifier).state = 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFB500FF), Color(0xFFDE33A2)]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Lihat', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCardLive(BuildContext context, BookingModel booking, TextTheme textTheme) {
    return Container(
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
            children: [
              Expanded(
                child: Text(booking.eventTitle,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(booking.statusCapitalized,
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(booking.eventDateVenueFormatted,
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Agreed Price', style: TextStyle(color: Colors.white54, fontSize: 13)),
              Text(booking.agreedPriceFormatted,
                style: const TextStyle(color: Color(0xFF2ECC71), fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAppCardLive(BuildContext context, ApplicationModel app, TextTheme textTheme) {
    Color statusColor;
    if (app.status == 'accepted') {
      statusColor = Colors.green;
    } else if (app.status == 'rejected') {
      statusColor = Colors.red;
    } else {
      statusColor = const Color(0xFFB500FF);
    }
    return Container(
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
                  app.event?.title ?? 'Event',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text('${app.dateFormatted} • ${app.status}',
                  style: const TextStyle(color: Colors.white54, fontSize: 13)),
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
              '${app.status[0].toUpperCase()}${app.status.substring(1)}',
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
