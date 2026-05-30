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
// Removed redundant local header

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
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white, height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.highlight.withValues(alpha: 0.5)),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: AppTheme.highlight,
                    fontSize: 9,
                    letterSpacing: 1.0,
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
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     const Text('TALENT', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
                     const SizedBox(height: 6),
                     Row(
                       children: [
                         const Icon(Icons.person_outline, color: AppTheme.highlight, size: 16),
                         const SizedBox(width: 6),
                         Expanded(
                           child: Text(talent, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                         ),
                       ],
                     ),
                     const SizedBox(height: 16),
                     const Text('SUMBER', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
                     const SizedBox(height: 6),
                     Text(source, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                     const Text('HARGA DEAL', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
                     const SizedBox(height: 6),
                     Text(price, style: const TextStyle(fontSize: 15, color: Color(0xFFE879F9), fontWeight: FontWeight.w900)), // Bright magenta/pink
                     const SizedBox(height: 20),
                     const Text('DIBUAT', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
                     const SizedBox(height: 6),
                     Text(createdAt, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
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
