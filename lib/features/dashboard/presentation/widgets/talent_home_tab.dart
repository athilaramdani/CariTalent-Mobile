import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/core/widgets/gradient_text.dart';
import 'package:caritalent_mobile/features/auth/application/auth_controller.dart';
import 'package:caritalent_mobile/core/widgets/app_header.dart';
import 'package:caritalent_mobile/features/dashboard/application/dashboard_providers.dart';
import 'package:caritalent_mobile/features/dashboard/domain/invitation_model.dart';
import 'package:caritalent_mobile/features/dashboard/domain/booking_model.dart';
import 'package:caritalent_mobile/features/dashboard/domain/application_model.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/pages/talent_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/pages/talent_reviews_page.dart';
import 'package:go_router/go_router.dart';

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

            // 3. Quick actions
            _buildQuickActions(context, ref),
            const SizedBox(height: 24),

            // 4. Stats Grid from real data
            _buildStatsGridLive(context, textTheme, ref,
              applicationsAsync: applicationsAsync,
              invitationsAsync: invitationsAsync,
              bookingsAsync: bookingsAsync,
              reviewsAsync: reviewsAsync,
            ),
            const SizedBox(height: 32),

            // 5. Invitations Section
            _buildSectionHeader(context, 'Invitations', 'Undangan eksklusif dari EO', textTheme, onSeeAll: () {
              ref.read(talentNavIndexProvider.notifier).state = 3;
            }),
            const SizedBox(height: 12),
            invitationsAsync.when(
              data: (invitations) {
                final recent = _sortInvitationsForHome(invitations);
                if (recent.isEmpty) {
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
                  children: recent.take(2).map((inv) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildInvitationCard(context, inv, textTheme, ref),
                  )).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _buildEmptyCard('Gagal memuat undangan: $e'),
            ),
            const SizedBox(height: 32),

            // 6. Upcoming Bookings Section
            _buildSectionHeader(context, 'Upcoming Bookings', 'Booking terkonfirmasi', textTheme, onSeeAll: () {
              ref.read(talentNavIndexProvider.notifier).state = 4;
            }),
            const SizedBox(height: 12),
            bookingsAsync.when(
              data: (bookings) {
                final upcoming = _sortBookingsForHome(bookings)
                    .where((b) => _isDashboardBookingStatus(b.status))
                    .toList();
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
              error: (e, _) => _buildEmptyCard('Gagal memuat bookings: $e'),
            ),
            const SizedBox(height: 32),

            // 7. Recent Applications Section
            _buildSectionHeader(context, 'Recent Applications', 'Lamaran event terbaru', textTheme, onSeeAll: () {
              ref.read(talentNavIndexProvider.notifier).state = 2;
            }),
            const SizedBox(height: 12),
            applicationsAsync.when(
              data: (applications) {
                final recent = _sortApplicationsForHome(applications);
                if (recent.isEmpty) {
                  return _buildEmptyCard('Belum ada lamaran');
                }
                return Column(
                  children: recent.take(3).map((app) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildRecentAppCardLive(context, app, textTheme),
                  )).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _buildEmptyCard('Gagal memuat lamaran: $e'),
            ),
            const SizedBox(height: 32),

          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _buildQuickActionButton(
          context,
          icon: Icons.search_rounded,
          label: 'Cari Event',
          isPrimary: true,
          onTap: () => ref.read(talentNavIndexProvider.notifier).state = 1,
        ),
        const SizedBox(height: 10),
        _buildQuickActionButton(
          context,
          icon: Icons.manage_accounts_outlined,
          label: 'Edit Profil',
          onTap: () => context.push(TalentProfilePage.routePath),
        ),
        const SizedBox(height: 10),
        _buildQuickActionButton(
          context,
          icon: Icons.mark_email_unread_outlined,
          label: 'Lihat Undangan',
          onTap: () => ref.read(talentNavIndexProvider.notifier).state = 3,
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [AppTheme.highlight, AppTheme.accent],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isPrimary ? null : AppTheme.panel,
          borderRadius: BorderRadius.circular(12),
          border: isPrimary ? null : Border.all(color: AppTheme.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : AppTheme.highlight,
              size: 20,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: isPrimary
                  ? Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : GradientText(
                      label,
                      style: textTheme.labelLarge?.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ) ??
                          const TextStyle(),
                    ),
            ),
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
          child: _buildStatCard(
            context, 
            'AVERAGE RATING', 
            rating, 
            'Berdasarkan perform terakhir',
            Icons.stars_rounded, 
            const Color(0xFFFFD700), // Gold
            isHighlighted: true,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, String hint, IconData icon, Color iconColor, {bool isHighlighted = false}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFF271340) : AppTheme.uiDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted 
              ? const Color(0xFFC48DF6).withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.05)
        ),
        boxShadow: isHighlighted ? [
          BoxShadow(
            color: const Color(0xFFB500FF).withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: iconColor, size: 16),
                  const SizedBox(width: 8),
                  Text(title,
                    style: TextStyle(
                      color: isHighlighted ? const Color(0xFFC48DF6) : Colors.white54, 
                      fontSize: 10, 
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ],
              ),
              if (isHighlighted)
                const Icon(Icons.arrow_forward_ios, color: Color(0xFFC48DF6), size: 10),
            ],
          ),
          const SizedBox(height: 10),
          Text(value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, height: 1.0),
          ),
          const SizedBox(height: 6),
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

  Widget _buildInvitationCard(
    BuildContext context,
    InvitationModel inv,
    TextTheme textTheme,
    WidgetRef ref,
  ) {
    final statusColor = _statusColor(inv.status);
    final statusLabel = _statusLabel(inv.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.uiDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  inv.eventTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _joinNonEmpty([
                    inv.eventDateFormatted,
                    inv.eventVenue,
                    inv.offeredPriceFormatted,
                  ]),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () => ref.read(talentNavIndexProvider.notifier).state = 3,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCardLive(
    BuildContext context,
    BookingModel booking,
    TextTheme textTheme,
  ) {
    final statusColor = _statusColor(booking.status);

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
                child: Text(
                  booking.eventTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusLabel(booking.status),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            booking.eventDateVenueFormatted,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Agreed Price',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              Text(
                booking.agreedPriceFormatted,
                style: const TextStyle(
                  color: Color(0xFF2ECC71),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAppCardLive(
    BuildContext context,
    ApplicationModel app,
    TextTheme textTheme,
  ) {
    final statusColor = _statusColor(app.status);
    final event = app.event;
    final details = event == null
        ? _joinNonEmpty([app.dateFormatted, app.priceFormatted])
        : _joinNonEmpty([
            _formatDate(event.eventDate),
            event.venueName,
            app.priceFormatted,
          ]);

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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  details,
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
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
              _statusLabel(app.status),
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<InvitationModel> _sortInvitationsForHome(
    List<InvitationModel> invitations,
  ) {
    final visible = invitations
        .where((inv) => !_isHiddenInvitationStatus(inv.status))
        .toList();
    visible.sort((a, b) {
      final byCreated = _compareDateDesc(a.createdAt, b.createdAt);
      if (byCreated != 0) return byCreated;
      return _compareDateDesc(a.eventDate, b.eventDate);
    });
    return visible;
  }

  List<BookingModel> _sortBookingsForHome(List<BookingModel> bookings) {
    final copy = [...bookings];
    copy.sort((a, b) {
      final statusOrder = _bookingStatusPriority(a.status)
          .compareTo(_bookingStatusPriority(b.status));
      if (statusOrder != 0) return statusOrder;
      final byEventDate = _compareDateDesc(a.eventDate, b.eventDate);
      if (byEventDate != 0) return byEventDate;
      return _compareDateDesc(a.createdAt, b.createdAt);
    });
    return copy;
  }

  List<ApplicationModel> _sortApplicationsForHome(
      List<ApplicationModel> applications) {
    final copy = [...applications];
    copy.sort((a, b) {
      final byCreated = _compareDateDesc(a.createdAt, b.createdAt);
      if (byCreated != 0) return byCreated;
      return _compareDateDesc(
        a.event?.eventDate ?? '',
        b.event?.eventDate ?? '',
      );
    });
    return copy;
  }

  bool _isDashboardBookingStatus(String status) {
    final value = status.trim().toLowerCase();
    return value == 'confirmed' ||
        value == 'completed' ||
        value == 'dikonfirmasi' ||
        value == 'selesai';
  }

  bool _isHiddenInvitationStatus(String status) {
    final value = status.trim().toLowerCase();
    return value == 'rejected' || value == 'ditolak' || value == 'cancelled';
  }

  int _bookingStatusPriority(String status) {
    final value = status.trim().toLowerCase();
    if (value == 'confirmed' || value == 'dikonfirmasi') return 0;
    if (value == 'completed' || value == 'selesai') return 1;
    return 2;
  }

  int _compareDateDesc(String left, String right) {
    final a = _parseDate(left);
    final b = _parseDate(right);
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return b.compareTo(a);
  }

  DateTime? _parseDate(String raw) {
    if (raw.trim().isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  String _formatDate(String raw) {
    final dt = _parseDate(raw);
    if (dt == null) return raw;
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  String _joinNonEmpty(List<String> values) {
    final filtered = values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty && value != '-')
        .toList();
    return filtered.join(' - ');
  }

  Color _statusColor(String status) {
    final value = status.trim().toLowerCase();
    if (value == 'accepted' ||
        value == 'confirmed' ||
        value == 'diterima' ||
        value == 'dikonfirmasi') {
      return Colors.green;
    }
    if (value == 'completed' || value == 'selesai') {
      return const Color(0xFFB500FF);
    }
    if (value == 'rejected' || value == 'cancelled' || value == 'ditolak') {
      return Colors.redAccent;
    }
    return Colors.orangeAccent;
  }

  String _statusLabel(String status) {
    final value = status.trim();
    if (value.isEmpty) return '-';
    final lower = value.toLowerCase();
    switch (lower) {
      case 'pending':
        return 'Pending';
      case 'accepted':
      case 'diterima':
        return 'Accepted';
      case 'rejected':
      case 'ditolak':
        return 'Rejected';
      case 'confirmed':
      case 'dikonfirmasi':
        return 'Confirmed';
      case 'completed':
      case 'selesai':
        return 'Completed';
      case 'cancelled':
      case 'canceled':
      case 'dibatalkan':
        return 'Cancelled';
      default:
        return '${value[0].toUpperCase()}${value.substring(1)}';
    }
  }
}
