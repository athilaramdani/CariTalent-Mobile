import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/core/widgets/app_card.dart';
import 'package:caritalent_mobile/core/widgets/gradient_text.dart';
import 'package:caritalent_mobile/features/auth/application/auth_controller.dart';
import 'package:caritalent_mobile/features/dashboard/application/dashboard_providers.dart';
import 'package:caritalent_mobile/features/dashboard/domain/booking_model.dart';
import 'package:caritalent_mobile/features/dashboard/domain/event_model.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/widgets/create_event_modal.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/widgets/view_location_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class EoHomeTab extends ConsumerWidget {
  const EoHomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final user = ref.watch(authControllerProvider).user;
    final name = user?.name ?? 'Event Organizer';

    final eventsAsync = ref.watch(myEventsProvider);
    final bookingsAsync = ref.watch(myBookingsProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Text(
            'Event Organizer Dashboard',
            style: textTheme.bodySmall
                ?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          GradientText(
            name,
            style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 32,
                ) ??
                const TextStyle(),
          ),
          const SizedBox(height: 8),
          Text(
            'Kelola event, lihat pelamar, dan temukan\ntalent terbaik',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final useWideLayout = constraints.maxWidth >= 560;
              final buttons = [
                _buildQuickActionButton(
                  context,
                  icon: Icons.add_circle_outline,
                  label: 'Buat Event Baru',
                  onTap: () => CreateEventModal.show(context),
                  isPrimary: true,
                ),
                _buildQuickActionButton(
                  context,
                  icon: Icons.calendar_month_outlined,
                  label: 'Lihat Semua Event',
                  onTap: () => ref.read(eoNavIndexProvider.notifier).state = 1,
                ),
                _buildQuickActionButton(
                  context,
                  icon: Icons.book_online_outlined,
                  label: 'Kelola Booking',
                  onTap: () => ref.read(eoNavIndexProvider.notifier).state = 2,
                ),
              ];

              if (useWideLayout) {
                return Row(
                  children: [
                    for (var i = 0; i < buttons.length; i++) ...[
                      Expanded(child: buttons[i]),
                      if (i != buttons.length - 1) const SizedBox(width: 12),
                    ],
                  ],
                );
              }

              return Column(
                children: [
                  for (var i = 0; i < buttons.length; i++) ...[
                    buttons[i],
                    if (i != buttons.length - 1) const SizedBox(height: 10),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Stats Cards — from real data
          eventsAsync.when(
            data: (events) {
              final totalEvents = events.length;
              final activeEvents = events.where((e) => e.isOpen).length;
              return bookingsAsync.when(
                data: (bookings) {
                  final totalBookings = bookings.length;
                  final completed = bookings
                      .where((b) => b.status == 'completed')
                      .length;
                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: _buildStatCard(
                                  context,
                                  'Total Events',
                                  '$totalEvents',
                                  'Semua event yang dibuat',
                                  Icons.calendar_today_outlined)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _buildStatCard(
                                  context,
                                  'Active Events',
                                  '$activeEvents',
                                  'Event sedang dibuka',
                                  Icons.event_available_outlined)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: _buildStatCard(
                                  context,
                                  'Total Bookings',
                                  '$totalBookings',
                                  'Semua booking aktif',
                                  Icons.handshake_outlined)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _buildStatCard(
                                  context,
                                  'Completed',
                                  '$completed',
                                  'Booking selesai',
                                  Icons.verified_outlined)),
                        ],
                      ),
                    ],
                  );
                },
                loading: () => _buildStatsLoading(context),
                error: (_, __) => _buildStatsLoading(context),
              );
            },
            loading: () => _buildStatsLoading(context),
            error: (_, __) => _buildStatsLoading(context),
          ),
          const SizedBox(height: 32),

          // Recent Events
          _buildSectionTitle(context, 'My Events', 'Ringkasan event terbaru',
              () => ref.read(eoNavIndexProvider.notifier).state = 1),
          const SizedBox(height: 16),
          eventsAsync.when(
            data: (events) {
              if (events.isEmpty) {
                return _buildEmpty(context, 'Belum ada event');
              }
              final recent = events.take(3).toList();
              return Column(
                children: [
                  for (final e in recent) ...[
                    _buildEventCard(context, e),
                    const SizedBox(height: 12),
                  ],
                ],
              );
            },
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e',
                style: const TextStyle(color: Colors.redAccent)),
          ),
          const SizedBox(height: 32),

          // Recent Bookings
          _buildSectionTitle(
              context, 'Bookings', 'Ringkasan booking terkini', null),
          const SizedBox(height: 16),
          bookingsAsync.when(
            data: (bookings) {
              if (bookings.isEmpty) {
                return _buildEmpty(context, 'Belum ada booking');
              }
              final recent = bookings.take(3).toList();
              return Column(
                children: [
                  for (final b in recent) ...[
                    _buildBookingCard(context, b),
                    const SizedBox(height: 12),
                  ],
                ],
              );
            },
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e',
                style: const TextStyle(color: Colors.redAccent)),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildStatsLoading(BuildContext context) {
    return const SizedBox(
      height: 120,
      child: Center(child: CircularProgressIndicator()),
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
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : GradientText(
                      label,
                      style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ) ??
                          const TextStyle(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(msg,
            style: const TextStyle(color: Colors.white38, fontSize: 14)),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      String hint, IconData icon) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.highlight),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: AppTheme.neutralMedium),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold, color: Colors.white, fontSize: 28),
          ),
          const SizedBox(height: 2),
          Text(
            hint,
            style: textTheme.bodySmall?.copyWith(fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, String subtitle,
      VoidCallback? onSeeAll) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppTheme.highlight,
              ),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: textTheme.bodyMedium),
          ],
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.highlight.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    'Lihat Semua',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppTheme.highlight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward,
                      size: 14, color: AppTheme.highlight),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEventCard(BuildContext context, EventModel event) {
    final textTheme = Theme.of(context).textTheme;
    final isOpen = event.isOpen;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOpen
                          ? Colors.green.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      event.statusLabel,
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isOpen ? Colors.green : Colors.white70,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.highlight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppTheme.highlight.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      event.budgetFormatted,
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('${event.eventDate} • ${event.venueName}',
              style: textTheme.bodySmall),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.people_outline,
                  size: 16, color: Colors.white70),
              const SizedBox(width: 4),
              Text('${event.totalApplicants} pelamar',
                  style: textTheme.bodySmall
                      ?.copyWith(color: Colors.white70)),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  if (event.latitude != null) {
                    ViewLocationModal.show(
                      context,
                      eventName: event.title,
                      displayAddress: '${event.venueName}, ${event.city}',
                      location: LatLng(event.latitude!, event.longitude!),
                    );
                  }
                },
                child: Row(
                  children: [
                    Icon(
                        event.latitude == null
                            ? Icons.location_off_outlined
                            : Icons.location_on_outlined,
                        size: 16,
                        color: AppTheme.highlight),
                    const SizedBox(width: 4),
                    Text(
                      'Lihat Lokasi',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppTheme.highlight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingModel booking) {
    final textTheme = Theme.of(context).textTheme;
    Color statusColor;
    final s = booking.status.toLowerCase();
    if (s == 'confirmed') {
      statusColor = Colors.green;
    } else if (s == 'completed') {
      statusColor = AppTheme.highlight;
    } else {
      statusColor = Colors.orangeAccent;
    }

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  booking.eventTitle,
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  booking.statusCapitalized,
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(booking.eventDateVenueFormatted,
              style: textTheme.bodySmall),
        ],
      ),
    );
  }
}
