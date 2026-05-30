import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/core/widgets/app_card.dart';
import 'package:caritalent_mobile/core/widgets/gradient_text.dart';
import 'package:flutter/material.dart';

class EoBookingsTab extends StatelessWidget {
  const EoBookingsTab({super.key});

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
            'My Bookings',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ) ?? const TextStyle(),
          ),
          const SizedBox(height: 8),
          Text(
            'Detail booking event beserta talent, harga deal,\ndan status',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '2 booking · 0 confirmed · 2 completed',
            style: textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(context, 'Semua', '2', true),
                _buildFilterChip(context, 'Confirmed', '0', false),
                _buildFilterChip(context, 'Completed', '2', false),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildBookingCard(
            context: context,
            title: 'Pasar Bandoeng Weekend Vibes',
            status: 'COMPLETED',
            dateLocation: '17 Mei 2026 · Pasar Bandoeng - Parahyangan',
            talent: 'DJ Arfz Bdg',
            price: 'Rp 2.500.000',
            source: 'Apply Langsung',
            createdAt: '3 Apr 2026',
          ),
          const SizedBox(height: 16),
          _buildBookingCard(
            context: context,
            title: 'Pasar Bandoeng DJ Night Februari',
            status: 'COMPLETED',
            dateLocation: '22 Feb 2026 · Pasar Bandoeng',
            talent: 'DJ Arfz Bdg',
            price: 'Rp 2.500.000',
            source: 'Apply Langsung',
            createdAt: '27 Jan 2026',
          ),
          const SizedBox(height: 48),
        ],
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

  Widget _buildBookingCard({
    required BuildContext context,
    required String title,
    required String status,
    required String dateLocation,
    required String talent,
    required String price,
    required String source,
    required String createdAt,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.highlight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.highlight.withValues(alpha: 0.3)),
                ),
                child: Text(
                  status,
                  style: textTheme.labelSmall?.copyWith(
                    color: AppTheme.highlight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: AppTheme.highlight, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  dateLocation,
                  style: textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: AppTheme.border, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text('TALENT', style: textTheme.labelSmall?.copyWith(color: AppTheme.neutralMedium, letterSpacing: 1.0)),
                     const SizedBox(height: 6),
                     Row(
                       children: [
                         const Icon(Icons.person_outline, color: AppTheme.highlight, size: 14),
                         const SizedBox(width: 6),
                         Expanded(
                           child: Text(talent, style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                         ),
                       ],
                     ),
                     const SizedBox(height: 16),
                     Text('SUMBER', style: textTheme.labelSmall?.copyWith(color: AppTheme.neutralMedium, letterSpacing: 1.0)),
                     const SizedBox(height: 6),
                     Text(source, style: textTheme.labelLarge),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                     Text('HARGA DEAL', style: textTheme.labelSmall?.copyWith(color: AppTheme.neutralMedium, letterSpacing: 1.0)),
                     const SizedBox(height: 6),
                     Text(price, style: textTheme.titleMedium?.copyWith(color: AppTheme.highlight, fontWeight: FontWeight.bold)),
                     const SizedBox(height: 20),
                     Text('DIBUAT', style: textTheme.labelSmall?.copyWith(color: AppTheme.neutralMedium, letterSpacing: 1.0)),
                     const SizedBox(height: 6),
                     Text(createdAt, style: textTheme.labelLarge),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
