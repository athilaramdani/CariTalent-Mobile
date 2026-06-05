import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/core/widgets/gradient_text.dart';
import 'package:caritalent_mobile/features/dashboard/application/dashboard_providers.dart';
import 'package:caritalent_mobile/features/dashboard/domain/booking_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TalentBookingsTab extends ConsumerStatefulWidget {
  const TalentBookingsTab({super.key});

  @override
  ConsumerState<TalentBookingsTab> createState() => _TalentBookingsTabState();
}

class _TalentBookingsTabState extends ConsumerState<TalentBookingsTab> {
  String _selectedFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bookingsAsync = ref.watch(myBookingsProvider);

    return SafeArea(
      child: bookingsAsync.when(
        data: (bookings) {
          final confirmed =
              bookings.where((b) => b.status == 'confirmed').length;
          final completed =
              bookings.where((b) => b.status == 'completed').length;
          final totalEarnings = bookings
              .where((b) => b.status == 'completed')
              .fold<double>(0, (sum, b) => sum + b.agreedPrice);

          final filtered = _selectedFilter == 'Semua'
              ? bookings
              : bookings
                  .where((b) => b.status == _selectedFilter.toLowerCase())
                  .toList();

          final formattedEarnings = _formatCurrency(totalEarnings);

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              GradientText(
                'My Bookings',
                style: textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w900) ??
                    const TextStyle(),
              ),
              const SizedBox(height: 8),
              Text(
                'Booking terkonfirmasi dan selesai\nbeserta detail event dan harga deal',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // Stats
              Row(
                children: [
                  _buildStatCard(
                      context, '${bookings.length}', 'TOTAL', null),
                  const SizedBox(width: 12),
                  _buildStatCard(
                      context, '$confirmed', 'CONFIRMED', AppTheme.highlight),
                  const SizedBox(width: 12),
                  _buildStatCard(
                      context, '$completed', 'SELESAI', Colors.greenAccent),
                ],
              ),
              const SizedBox(height: 16),

              // Earnings card
              if (completed > 0)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.withValues(alpha: 0.3),
                        Colors.teal.withValues(alpha: 0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.green.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined,
                          color: Colors.greenAccent, size: 28),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Penghasilan',
                              style: TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                          Text(
                            formattedEarnings,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(context, 'Semua', '${bookings.length}'),
                    _buildFilterChip(context, 'Confirmed', '$confirmed'),
                    _buildFilterChip(context, 'Completed', '$completed'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (filtered.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        const Icon(Icons.event_busy_outlined,
                            size: 52, color: Colors.white24),
                        const SizedBox(height: 16),
                        Text('Tidak ada booking',
                            style: textTheme.bodyMedium
                                ?.copyWith(color: Colors.white38)),
                      ],
                    ),
                  ),
                )
              else
                for (final booking in filtered) ...[
                  _BookingCard(
                    booking: booking,
                    onCancel: booking.status == 'confirmed'
                        ? () => _cancelBooking(booking.id)
                        : null,
                  ),
                  const SizedBox(height: 16),
                ],

              const SizedBox(height: 48),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              Text('Gagal memuat bookings: $e',
                  style: const TextStyle(color: Colors.white54)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(myBookingsProvider),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _cancelBooking(int id) async {
    try {
      await ref.read(bookingRepositoryProvider).cancelBooking(id);
      ref.invalidate(myBookingsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal membatalkan booking: $e'),
          backgroundColor: Colors.redAccent,
        ));
      }
    }
  }

  String _formatCurrency(double amount) {
    final n = amount.toInt();
    final s = n
        .toString()
        .replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return 'Rp $s';
  }

  Widget _buildStatCard(
      BuildContext context, String value, String label, Color? valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppTheme.uiDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    color: valueColor ?? Colors.white)),
            const SizedBox(height: 10),
            Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white54,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String count) {
    final isActive = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFFB500FF), Color(0xFFE94057)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isActive ? null : Colors.transparent,
          border: isActive ? null : Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Text(label,
                style: TextStyle(
                    color: isActive ? Colors.white : Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Text(count,
                  style: TextStyle(
                      color: isActive ? Colors.white : Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Booking Card ─────────────────────────────────────────────────────────────

class _BookingCard extends StatefulWidget {
  final BookingModel booking;
  final VoidCallback? onCancel;

  const _BookingCard({required this.booking, this.onCancel});

  @override
  State<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<_BookingCard> {
  bool _cancelling = false;

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final textTheme = Theme.of(context).textTheme;
    final s = booking.status.toLowerCase();

    Color statusColor;
    if (s == 'confirmed') {
      statusColor = AppTheme.highlight;
    } else if (s == 'completed') {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.white70;
    }

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
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(booking.eventTitle,
                    style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: statusColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  booking.statusCapitalized,
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.event_outlined, size: 13, color: statusColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(booking.eventDateVenueFormatted,
                    style: textTheme.bodySmall
                        ?.copyWith(color: Colors.white54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Divider(
                height: 1, color: Colors.white.withValues(alpha: 0.05)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('HARGA DEAL',
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(booking.agreedPriceFormatted,
                      style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFFE879F9),
                          fontWeight: FontWeight.w900)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('SUMBER',
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(booking.sourceLabel,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
          if (widget.onCancel != null && s == 'confirmed') ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _cancelling
                  ? null
                  : () async {
                      setState(() => _cancelling = true);
                      widget.onCancel!();
                      if (mounted) setState(() => _cancelling = false);
                    },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: Colors.redAccent.withValues(alpha: 0.4)),
                ),
                alignment: Alignment.center,
                child: _cancelling
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.redAccent))
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cancel_outlined,
                              color: Colors.redAccent, size: 16),
                          SizedBox(width: 6),
                          Text('Batalkan Booking',
                              style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
