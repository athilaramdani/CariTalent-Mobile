import 'package:flutter/material.dart';
import 'package:caritalent_mobile/core/widgets/app_header.dart';
class TalentBookingsTab extends StatefulWidget {
  const TalentBookingsTab({super.key});

  @override
  State<TalentBookingsTab> createState() => _TalentBookingsTabState();
}

class _TalentBookingsTabState extends State<TalentBookingsTab> {
  String _selectedFilter = 'All';

  static const List<_BookingItem> _allBookings = [
    _BookingItem(
      title: 'tesdt',
      dateVenue: '16 Jul 1000 • asa',
      agreedPrice: 'Rp 2.000.000',
      createdDate: '30 Mei 2026',
      source: 'Dari invitation',
      status: 'Confirmed',
    ),
    _BookingItem(
      title: 'Braga Punk Night Vol.4',
      dateVenue: '15 Mar 2026 • Kafe Braga Permai',
      agreedPrice: 'Rp 1.500.000',
      createdDate: '22 Feb 2026',
      source: 'Apply langsung',
      status: 'Completed',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final filters = ['All', 'Confirmed', 'Completed', 'Cancelled'];

    final filtered = _allBookings.where((b) {
      if (_selectedFilter == 'All') return true;
      return b.status == _selectedFilter;
    }).toList();

    final total = _allBookings.length;
    final confirmedCount = _allBookings.where((b) => b.status == 'Confirmed').length;
    final completedCount = _allBookings.where((b) => b.status == 'Completed').length;

    // Calculate total earnings from completed bookings
    double totalEarned = 0;
    for (final b in _allBookings) {
      if (b.status == 'Completed') {
        final numStr = b.agreedPrice
            .replaceAll('Rp ', '')
            .replaceAll('.', '')
            .replaceAll(',', '');
        totalEarned += double.tryParse(numStr) ?? 0;
      }
    }
    final earnedFormatted = _formatCurrency(totalEarned);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top Nav ──
                  const AppHeader(),
                  const SizedBox(height: 32),

                  // ── Page Title ──
                  Text(
                    'Talent Dashboard',
                    style: textTheme.labelMedium?.copyWith(
                      color: Colors.white54,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFB500FF), Color(0xFFDE33A2)],
                    ).createShader(bounds),
                    child: Text(
                      'Tim Planner Booking',
                      style: textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'View your bookings and earnings',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.white54,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Stats Row ──
                  Row(
                    children: [
                      _buildStatBox(
                        '$total',
                        'Total\nBookings',
                        const Color(0xFFC48DF6),
                        Icons.calendar_today_outlined,
                        textTheme,
                      ),
                      const SizedBox(width: 8),
                      _buildStatBox(
                        '$confirmedCount',
                        'Upcoming\nEvents',
                        Colors.greenAccent,
                        Icons.event_available_outlined,
                        textTheme,
                      ),
                      const SizedBox(width: 8),
                      _buildStatBox(
                        earnedFormatted,
                        'Earned\nThis month',
                        const Color(0xFF64B5F6),
                        Icons.attach_money_outlined,
                        textTheme,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Filter Pills ──
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: filters.map((f) {
                        final isSelected = _selectedFilter == f;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedFilter = f),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? const LinearGradient(
                                        colors: [Color(0xFFB500FF), Color(0xFFDE33A2)],
                                      )
                                    : null,
                                color: isSelected ? null : Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : Colors.white.withValues(alpha: 0.12),
                                ),
                              ),
                              child: Text(
                                f,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white60,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Section Title ──
                  Text(
                    'Upcoming Bookings',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Detail booking event, harga deal, dan metadata jadwal',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.white54,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ── Booking Cards ──
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: filtered.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            const Icon(Icons.event_busy_outlined, size: 52, color: Colors.white24),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada booking',
                              style: textTheme.bodyMedium?.copyWith(color: Colors.white38),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _BookingCard(item: filtered[index]),
                      childCount: filtered.length,
                    ),
                  ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 48)),
        ],
      ),
    );
  }

  Widget _buildStatBox(
    String value,
    String label,
    Color color,
    IconData icon,
    TextTheme textTheme,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 9,
                letterSpacing: 0.3,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      final val = amount / 1000000;
      return 'Rp ${val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1)}jt';
    } else if (amount >= 1000) {
      final val = amount / 1000;
      return 'Rp ${val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1)}rb';
    }
    return 'Rp ${amount.toStringAsFixed(0)}';
  }
}

// ─── Booking Card ─────────────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  final _BookingItem item;
  const _BookingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Color badgeColor;
    Color badgeBg;
    if (item.status == 'Confirmed') {
      badgeColor = Colors.greenAccent;
      badgeBg = Colors.greenAccent.withValues(alpha: 0.12);
    } else if (item.status == 'Completed') {
      badgeColor = const Color(0xFFC48DF6);
      badgeBg = const Color(0xFFC48DF6).withValues(alpha: 0.12);
    } else {
      badgeColor = Colors.redAccent;
      badgeBg = Colors.redAccent.withValues(alpha: 0.12);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF13112B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: Title + Status Badge ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFB500FF), Color(0xFFDE33A2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.event_note_outlined, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item.status,
                              style: TextStyle(
                                color: badgeColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Date & Venue
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 11, color: Colors.white38),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.dateVenue,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                                height: 1.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Divider ──
            Divider(color: Colors.white.withValues(alpha: 0.07), height: 1),
            const SizedBox(height: 16),

            // ── Two-column detail grid ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailRow(
                        icon: Icons.monetization_on_outlined,
                        label: 'Harga deal',
                        value: item.agreedPrice,
                        valueColor: const Color(0xFF2ECC71),
                        isBold: true,
                      ),
                      const SizedBox(height: 10),
                      _DetailRow(
                        icon: Icons.date_range_outlined,
                        label: 'Dibuat',
                        value: item.createdDate,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailRow(
                        icon: Icons.source_outlined,
                        label: 'Sumber',
                        value: item.source,
                        valueColor: const Color(0xFFC48DF6),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Detail Row Widget ────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: Colors.white38),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 10,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.white70,
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Data Model ───────────────────────────────────────────────────────────────

class _BookingItem {
  final String title;
  final String dateVenue;
  final String agreedPrice;
  final String createdDate;
  final String source;
  final String status;

  const _BookingItem({
    required this.title,
    required this.dateVenue,
    required this.agreedPrice,
    required this.createdDate,
    required this.source,
    required this.status,
  });
}
