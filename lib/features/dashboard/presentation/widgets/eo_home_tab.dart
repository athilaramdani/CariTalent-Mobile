import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/core/widgets/app_card.dart';
import 'package:caritalent_mobile/core/widgets/gradient_text.dart';
import 'package:caritalent_mobile/features/auth/application/auth_controller.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/widgets/create_event_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EoHomeTab extends ConsumerWidget {
  const EoHomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final user = ref.watch(authControllerProvider).user;
    final name = user?.name ?? 'Event Organizer';

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Text(
            'Event Organizer Dashboard',
            style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          GradientText(
            name,
            style: textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 32, // Adjusted size based on Image 1
            ) ?? const TextStyle(),
          ),
          const SizedBox(height: 8),
          Text(
            'Kelola event, lihat pelamar, dan temukan\ntalent terbaik',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => CreateEventModal.show(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.highlight, AppTheme.accent],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Buat Event Baru',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.panel,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_month_outlined, color: AppTheme.highlight, size: 20),
                        const SizedBox(width: 8),
                        GradientText(
                          'Lihat Semua Event',
                          style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 13) ?? const TextStyle(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildStatCard(context, 'Total Events', '10', 'Semua event yang dibuat', Icons.calendar_today_outlined)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard(context, 'Active Events', '2', 'Semua event yang dibuat', Icons.event_available_outlined)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildStatCard(context, 'Total Bookings', '2', 'Semua event yang dibuat', Icons.handshake_outlined)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard(context, 'Completed', '2', 'Semua event yang dibuat', Icons.verified_outlined)),
            ],
          ),
          const SizedBox(height: 32),
          _buildSectionTitle(context, 'My Events', 'Ringkasan event terbaru', () {}),
          const SizedBox(height: 16),
          ..._buildFakeEvents(context),
          const SizedBox(height: 32),
          _buildSectionTitle(context, 'Bookings', 'Ringkasan booking terkini', null),
          const SizedBox(height: 16),
          ..._buildFakeBookings(context),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, String hint, IconData icon) {
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
                  style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5, color: AppTheme.neutralMedium),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 28),
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

  Widget _buildSectionTitle(BuildContext context, String title, String subtitle, VoidCallback? onSeeAll) {
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
                color: AppTheme.highlight, // Solid purple instead of gradient
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.highlight.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    'Lihat Semua',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppTheme.highlight, // Purple instead of Pink
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward, size: 14, color: AppTheme.highlight),
                ],
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildFakeEvents(BuildContext context) {
    return [
      _buildEventCard(context, 'HALO', '17 Des 2000 • Jalan Kaca Kaca Wetan', 'RP 50.000', false),
      const SizedBox(height: 12),
      _buildEventCard(context, 'halo', '8 Agu 2008 • Kafe', 'RP 5.000', false),
      const SizedBox(height: 12),
      _buildEventCard(context, 'asas', '8 Des 2004 • blabla', 'RP 5.000', true),
    ];
  }

  Widget _buildEventCard(BuildContext context, String title, String subtitle, String price, bool isOpen) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOpen
                          ? Colors.green.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      isOpen ? 'OPEN' : 'DRAFT',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isOpen ? Colors.green : Colors.white70,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.highlight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.highlight.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      price,
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
          Text(subtitle, style: textTheme.bodySmall),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.people_outline, size: 16, color: Colors.white70),
              const SizedBox(width: 4),
              Text('0 pelamar', style: textTheme.bodySmall?.copyWith(color: Colors.white70)),
              const SizedBox(width: 16),
              const Icon(Icons.location_on_outlined, size: 16, color: Colors.white70),
              const SizedBox(width: 4),
              Text('Lihat Lokasi', style: textTheme.bodySmall?.copyWith(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFakeBookings(BuildContext context) {
    return [
      _buildBookingCard(context, 'Pasar Bandoeng Weekend Vibes', '17 Mei 2026 • Pasar Bandoeng - Kota Baru Parahyangan', 'PENDING'),
      const SizedBox(height: 12),
      _buildBookingCard(context, 'Pasar Bandoeng DJ Night Februari', '22 Feb 2026 • Pasar Bandoeng - Kota Baru Parahyangan', 'COMPLETED'),
    ];
  }

  Widget _buildBookingCard(BuildContext context, String title, String subtitle, String status) {
    final textTheme = Theme.of(context).textTheme;
    Color statusColor;
    if (status == 'PENDING') {
      statusColor = Colors.orange;
    } else if (status == 'COMPLETED') {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.white;
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
                  title,
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  status,
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: textTheme.bodySmall),
        ],
      ),
    );
  }
}
