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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GradientText(
                'CariTalent',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ) ?? const TextStyle(),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.white),
                    onPressed: () {},
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppTheme.highlight, AppTheme.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(Icons.person_outline, color: Colors.white, size: 20),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 32),

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
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w400,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: AppTheme.neutralMedium,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String count, bool isActive) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: isActive
            ? const LinearGradient(
                colors: [AppTheme.highlight, AppTheme.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isActive ? null : Colors.transparent,
        border: isActive ? null : Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: textTheme.labelLarge,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: const BoxDecoration(
              color: Colors.black38,
              shape: BoxShape.circle,
            ),
            child: Text(
              count,
              style: textTheme.labelSmall?.copyWith(fontSize: 10, fontWeight: FontWeight.bold),
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
    final textTheme = Theme.of(context).textTheme;

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
                  name,
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.3)),
                ),
                child: Text(
                  status,
                  style: textTheme.labelSmall?.copyWith(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(location, style: textTheme.bodySmall),
              const SizedBox(width: 8),
              const Icon(Icons.star, color: Colors.orangeAccent, size: 16),
              const SizedBox(width: 2),
              Text(
                rating,
                style: textTheme.labelLarge?.copyWith(color: Colors.orangeAccent, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              if (isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified, color: Colors.green, size: 12),
                      const SizedBox(width: 4),
                      Text('VERIFIED', style: textTheme.labelSmall?.copyWith(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: genres.map((genre) {
                return Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.panel,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Text(
                    genre,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppTheme.highlight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HARGA DITAWARKAN',
                    style: textTheme.labelSmall?.copyWith(color: AppTheme.neutralMedium, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: textTheme.titleMedium,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'DIKIRIM',
                    style: textTheme.labelSmall?.copyWith(color: AppTheme.neutralMedium, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateSubmitted,
                    style: textTheme.titleMedium,
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
