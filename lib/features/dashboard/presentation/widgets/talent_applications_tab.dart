import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/core/widgets/gradient_text.dart';
import 'package:caritalent_mobile/core/widgets/app_header.dart';
import 'package:flutter/material.dart';

class TalentApplicationsTab extends StatelessWidget {
  const TalentApplicationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Header Row
                  const AppHeader(),
                  const SizedBox(height: 32),

                  // Page Title Section
                  const Text('Talent Management', style: TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  GradientText(
                    'Recent Applications',
                    style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5) ?? const TextStyle(),
                  ),
                  const SizedBox(height: 8),
                  Text('Riwayat lamaran event dengan detail status, lokasi, dan harga', style: textTheme.bodySmall?.copyWith(color: AppTheme.neutralMedium, height: 1.5)),
                  const SizedBox(height: 24),

                  // Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Total',
                          value: '8',
                          subtitle: 'Applications',
                          valueColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Pending',
                          value: '3',
                          subtitle: 'Review',
                          valueColor: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Accepted',
                          value: '5',
                          subtitle: 'This week',
                          valueColor: Colors.greenAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Pending Applications Section
                  Text('Pending Review', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 16),
                  
                  _ApplicationCard(
                    title: 'Braga Punk Night Vol.5',
                    subtitle: 'Menunggu respons organizer',
                    initials: 'BP',
                    avatarColor: const Color(0xFFDE33A2),
                    badgeText: 'Pending',
                    badgeColor: Colors.amber,
                    price: 'Rp 1.500.000',
                    date: '10 Mei 2026',
                    kota: 'Bandung',
                    venue: 'Kafe Braga Permai',
                    appliedDate: '2 Apr 2026',
                    source: 'Apply langsung',
                    showCancelButton: true,
                  ),

                  const SizedBox(height: 24),

                  // Recently Accepted/Rejected Section
                  Text('History Applications', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 16),

                  _ApplicationCard(
                    title: 'Pasar Bandoeng Weekend Vibes',
                    subtitle: 'Lamaran ditolak organizer',
                    initials: 'PB',
                    avatarColor: const Color(0xFFB500FF),
                    badgeText: 'Rejected',
                    badgeColor: Colors.redAccent,
                    price: 'Rp 1.000.000',
                    date: '17 Mei 2026',
                    kota: 'Bandung',
                    venue: 'Pasar Bandoeng - Kota Baru Parahyangan',
                    appliedDate: '2 Apr 2026',
                    source: 'Apply langsung',
                    showCancelButton: false,
                  ),
                  
                  const SizedBox(height: 16),

                  _ApplicationCard(
                    title: 'Braga Jazz Evening',
                    subtitle: 'Lamaran diterima organizer',
                    initials: 'BJ',
                    avatarColor: Colors.greenAccent.shade700,
                    badgeText: 'Accepted',
                    badgeColor: Colors.greenAccent,
                    price: 'Rp 2.500.000',
                    date: '20 Jun 2026',
                    kota: 'Bandung',
                    venue: 'Braga Art Square',
                    appliedDate: '15 Mar 2026',
                    source: 'Undangan langsung',
                    showCancelButton: false,
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 40),
          )
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color valueColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.uiDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: valueColor, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String initials;
  final Color avatarColor;
  final String badgeText;
  final Color badgeColor;
  final String price;
  final String date;
  final String kota;
  final String venue;
  final String appliedDate;
  final String source;
  final bool showCancelButton;

  const _ApplicationCard({
    required this.title,
    required this.subtitle,
    required this.initials,
    required this.avatarColor,
    required this.badgeText,
    required this.badgeColor,
    required this.price,
    required this.date,
    required this.kota,
    required this.venue,
    required this.appliedDate,
    required this.source,
    required this.showCancelButton,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
          // Header: Avatar, Title, Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: avatarColor,
                child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: textTheme.bodySmall?.copyWith(color: Colors.white54)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                ),
                child: Text(badgeText, style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Applied for / Price
          Text('Harga tawaran:', style: textTheme.labelMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(price, style: textTheme.bodyMedium?.copyWith(color: const Color(0xFFC48DF6))),
          
          const SizedBox(height: 16),

          // Details grid — two-column layout (web style)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column: Jadwal, Kota, Dikirim
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Jadwal event',
                      value: date,
                    ),
                    const SizedBox(height: 8),
                    _DetailRow(
                      icon: Icons.location_city_outlined,
                      label: 'Kota',
                      value: kota,
                      valueBold: true,
                    ),
                    const SizedBox(height: 8),
                    _DetailRow(
                      icon: Icons.access_time,
                      label: 'Dikirim',
                      value: appliedDate,
                      valueBold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Right column: Venue, Sumber
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailRow(
                      icon: Icons.store_outlined,
                      label: 'Venue',
                      value: venue,
                    ),
                    const SizedBox(height: 8),
                    _DetailRow(
                      icon: Icons.send_outlined,
                      label: 'Sumber',
                      value: source,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          // Description / Extra info if needed
          Text(
            '"I perform full energetic set, ready to bring the hype to your event. Provide my own instrument cable and effects."',
            style: textTheme.bodySmall?.copyWith(color: Colors.white54, fontStyle: FontStyle.italic),
          ),

          if (showCancelButton) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF81D4FA)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.location_on, size: 14, color: Color(0xFF81D4FA)),
                        SizedBox(width: 6),
                        Text('Lihat Lokasi', style: TextStyle(color: Color(0xFF81D4FA), fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Cancel Application', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Detail Row Helper ────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool valueBold;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: Colors.white38),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: textTheme.bodySmall?.copyWith(color: Colors.white54),
              children: [
                TextSpan(text: '$label: '),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: valueBold ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
