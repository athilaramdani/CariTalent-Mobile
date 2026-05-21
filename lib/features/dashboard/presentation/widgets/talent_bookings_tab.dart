import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TalentBookingsTab extends ConsumerWidget {
  const TalentBookingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.neutralDark,
      appBar: AppBar(
        title: Text('Daftar Booking', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppTheme.uiDark,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppTheme.border, height: 1.0),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header descriptive text
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Kelola semua jadwal panggung dan konfirmasi harga yang telah disepakati bersama Event Organizer.',
              style: textTheme.bodySmall?.copyWith(color: AppTheme.neutralMedium, height: 1.5),
            ),
          ),
          
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('Semua', true, textTheme),
                _buildFilterChip('Confirmed', false, textTheme),
                _buildFilterChip('Completed', false, textTheme),
                _buildFilterChip('Cancelled', false, textTheme),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Bookings List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildBookingCard(
                  context: context,
                  title: 'Punk Night Vol. 3',
                  agreedPrice: 'Rp 1.500.000',
                  date: '15 Apr 2026',
                  venue: 'Kafe Kota Bandung',
                  status: 'Confirmed',
                  statusColor: Colors.blue,
                  source: 'Apply',
                  textTheme: textTheme,
                ),
                _buildBookingCard(
                  context: context,
                  title: 'Gathering Kantor Tech',
                  agreedPrice: 'Rp 5.000.000',
                  date: '10 Jun 2025',
                  venue: 'Hotel Transylvania',
                  status: 'Confirmed',
                  statusColor: Colors.blue,
                  source: 'Invitation',
                  textTheme: textTheme,
                ),
                _buildBookingCard(
                  context: context,
                  title: 'Pernikahan Budi & Ani',
                  agreedPrice: 'Rp 3.500.000',
                  date: '20 May 2025',
                  venue: 'Gedung Sate Bandung',
                  status: 'Completed',
                  statusColor: Colors.green,
                  source: 'Invitation',
                  textTheme: textTheme,
                ),
                _buildBookingCard(
                  context: context,
                  title: 'Festival Musik Kemerdekaan',
                  agreedPrice: 'Rp 2.000.000',
                  date: '17 Aug 2025',
                  venue: 'Lapangan Gasibu',
                  status: 'Cancelled',
                  statusColor: Colors.red,
                  source: 'Apply',
                  textTheme: textTheme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, TextTheme textTheme) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.highlight : AppTheme.uiDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? AppTheme.highlight : AppTheme.border),
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: isSelected ? Colors.white : AppTheme.neutralMedium,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBookingCard({
    required BuildContext context,
    required String title,
    required String agreedPrice,
    required String date,
    required String venue,
    required String status,
    required Color statusColor,
    required String source,
    required TextTheme textTheme,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.uiDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
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
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.monetization_on_outlined, size: 14, color: AppTheme.highlight),
              const SizedBox(width: 6),
              Text(
                agreedPrice, 
                style: textTheme.labelMedium?.copyWith(color: AppTheme.highlight, fontWeight: FontWeight.bold)
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.neutralDark,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      source == 'Apply' ? Icons.assignment_outlined : Icons.mail_outline, 
                      size: 10, 
                      color: AppTheme.neutralMedium
                    ),
                    const SizedBox(width: 4),
                    Text(
                      source,
                      style: textTheme.labelSmall?.copyWith(color: AppTheme.neutralMedium, fontSize: 9),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppTheme.border, height: 1),
          ),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: AppTheme.neutralMedium),
              const SizedBox(width: 6),
              Text(date, style: textTheme.bodySmall),
              const SizedBox(width: 16),
              const Icon(Icons.location_on, size: 14, color: AppTheme.neutralMedium),
              const SizedBox(width: 6),
              Expanded(
                child: Text(venue, style: textTheme.bodySmall, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
