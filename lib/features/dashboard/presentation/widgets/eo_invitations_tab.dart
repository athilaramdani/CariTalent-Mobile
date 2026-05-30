import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/core/widgets/app_card.dart';
import 'package:caritalent_mobile/core/widgets/gradient_text.dart';
import 'package:flutter/material.dart';

class EoInvitationsTab extends StatelessWidget {
  const EoInvitationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
// Removed redundant local header

          GradientText(
            'Invitations Terkirim',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ) ?? const TextStyle(),
          ),
          const SizedBox(height: 8),
          Text(
            'Daftar talent yang kamu undang\nsecara langsung ke event kamu',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              _buildMetricCard(context, '7', 'TOTAL', AppTheme.highlight),
              const SizedBox(width: 12),
              _buildMetricCard(context, '0', 'ACCEPTED', Colors.greenAccent),
              const SizedBox(width: 12),
              _buildMetricCard(context, '6', 'PENDING', Colors.orangeAccent),
            ],
          ),
          const SizedBox(height: 24),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(context, 'Semua', '2', true),
                _buildFilterChip(context, 'Pending', '0', false),
                _buildFilterChip(context, 'Accepted', '2', false),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildInvitationCard(
            context: context,
            name: 'Rizky Maulana Acoustic',
            location: 'Bandung',
            rating: '4.0',
            isVerified: true,
            genres: ['Solo Singer', 'Indie Pop', 'Acoustic'],
            status: 'Pending',
            price: 'Rp 30.000',
            dateSubmitted: '13 Mei 2026',
          ),
          const SizedBox(height: 16),
          _buildInvitationCard(
            context: context,
            name: 'DJ Arfz Bdg',
            location: 'Bandung',
            rating: '4.8',
            isVerified: true,
            genres: ['DJ', 'EDM'],
            status: 'Pending',
            price: 'Rp 45.000',
            dateSubmitted: '14 Mei 2026',
          ),
          const SizedBox(height: 16),
          _buildInvitationCard(
            context: context,
            name: 'The Rotten Bandung',
            location: 'Bandung',
            rating: '5.0',
            isVerified: true,
            genres: ['Pop Punk', 'Hardcore', 'Alternative Rock'],
            status: 'Pending',
            price: 'Rp 75.000',
            dateSubmitted: '15 Mei 2026',
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String value, String label, Color valueColor) {
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
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w400,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white54,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String count, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: isActive
            ? const LinearGradient(
                colors: [Color(0xFFB500FF), Color(0xFFE94057)], // Pink-Purple gradient
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: isActive ? null : Colors.transparent,
        border: isActive ? null : Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Text(
              count,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInvitationCard({
    required BuildContext context,
    required String name,
    required String location,
    required String rating,
    required bool isVerified,
    required List<String> genres,
    required String status,
    required String price,
    required String dateSubmitted,
  }) {
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
                  name,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5)), // Amber
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Color(0xFFF59E0B),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(location, style: const TextStyle(fontSize: 13, color: Colors.white70)),
              const SizedBox(width: 8),
              const Icon(Icons.star, color: Color(0xFFF59E0B), size: 14),
              const SizedBox(width: 4),
              Text(
                rating,
                style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              if (isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified, color: Colors.green, size: 10),
                      const SizedBox(width: 4),
                      const Text('VERIFIED', style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: genres.map((genre) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Text(
                    genre,
                    style: TextStyle(
                      color: const Color(0xFFC026D3).withValues(alpha: 0.9), // Subtle Purple
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'HARGA DITAWARKAN',
                    style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    price,
                    style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'DIKIRIM',
                    style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dateSubmitted,
                    style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
