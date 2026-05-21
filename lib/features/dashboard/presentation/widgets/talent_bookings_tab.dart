import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/features/dashboard/application/dashboard_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TalentBookingsTab extends ConsumerWidget {
  const TalentBookingsTab({super.key});

  static const List<_BookingItem> _allBookings = [
    _BookingItem(
      title: 'Punk Night Vol. 3',
      agreedPrice: 'Rp 1.500.000',
      date: '15 Apr 2026',
      venue: 'Kafe Kota Bandung',
      status: 'Confirmed',
      statusColor: Colors.blue,
      source: 'Apply',
    ),
    _BookingItem(
      title: 'Gathering Kantor Tech',
      agreedPrice: 'Rp 5.000.000',
      date: '10 Jun 2025',
      venue: 'Hotel Transylvania',
      status: 'Confirmed',
      statusColor: Colors.blue,
      source: 'Invitation',
    ),
    _BookingItem(
      title: 'Pernikahan Budi & Ani',
      agreedPrice: 'Rp 3.500.000',
      date: '20 May 2025',
      venue: 'Gedung Sate Bandung',
      status: 'Completed',
      statusColor: Colors.green,
      source: 'Invitation',
    ),
    _BookingItem(
      title: 'Festival Musik Kemerdekaan',
      agreedPrice: 'Rp 2.000.000',
      date: '17 Aug 2025',
      venue: 'Lapangan Gasibu',
      status: 'Cancelled',
      statusColor: Colors.red,
      source: 'Apply',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final searchQuery = ref.watch(bookingSearchQueryProvider);

    // Filter bookings based on search query
    final filteredBookings = _allBookings.where((booking) {
      if (searchQuery.isEmpty) return true;
      final query = searchQuery.toLowerCase();
      return booking.title.toLowerCase().contains(query) ||
          booking.venue.toLowerCase().contains(query) ||
          booking.status.toLowerCase().contains(query) ||
          booking.source.toLowerCase().contains(query);
    }).toList();

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


          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                ref.read(bookingSearchQueryProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                hintText: 'Cari nama acara, tempat, dll...',
                hintStyle: textTheme.bodyMedium?.copyWith(color: AppTheme.neutralMedium),
                prefixIcon: const Icon(Icons.search, color: AppTheme.neutralMedium),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppTheme.neutralMedium),
                        onPressed: () {
                          ref.read(bookingSearchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.uiDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppTheme.highlight),
                ),
              ),
              style: textTheme.bodyMedium,
            ),
          ),
          
          // Bookings List
          Expanded(
            child: filteredBookings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off_rounded, size: 64, color: AppTheme.neutralMedium),
                        const SizedBox(height: 16),
                        Text(
                          'Booking tidak ditemukan',
                          style: textTheme.titleMedium?.copyWith(color: AppTheme.neutralMedium),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredBookings.length,
                    itemBuilder: (context, index) {
                      final booking = filteredBookings[index];
                      return _buildBookingCard(
                        context: context,
                        title: booking.title,
                        agreedPrice: booking.agreedPrice,
                        date: booking.date,
                        venue: booking.venue,
                        status: booking.status,
                        statusColor: booking.statusColor,
                        source: booking.source,
                        textTheme: textTheme,
                      );
                    },
                  ),
          ),
        ],
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

class _BookingItem {
  final String title;
  final String agreedPrice;
  final String date;
  final String venue;
  final String status;
  final Color statusColor;
  final String source;

  const _BookingItem({
    required this.title,
    required this.agreedPrice,
    required this.date,
    required this.venue,
    required this.status,
    required this.statusColor,
    required this.source,
  });
}
