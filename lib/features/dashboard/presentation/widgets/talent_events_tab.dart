import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/features/dashboard/application/dashboard_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TalentEventsTab extends ConsumerWidget {
  const TalentEventsTab({super.key});

  static const List<_EventItem> _allEvents = [
    _EventItem(
      title: 'Punk Night Vol. 3',
      description: 'Malam punk rock terbaik di Bandung. Membutuhkan band pembuka beraliran punk/rock.',
      budget: 'Rp 3.000.000',
      date: '15 Apr 2026',
      venue: 'Kafe Kota Bandung',
      city: 'Bandung',
      status: 'Dibuka',
      statusColor: Colors.green,
      totalApplicants: 12,
    ),
    _EventItem(
      title: 'Braga Jazz Evening',
      description: 'Acara musik jazz mingguan di jalan Braga. Mencari band akustik atau penyanyi solo untuk menemani malam minggu.',
      budget: 'Rp 1.500.000',
      date: '12 Mar 2025',
      venue: 'Braga Art Square',
      city: 'Bandung',
      status: 'Dibuka',
      statusColor: Colors.green,
      totalApplicants: 5,
    ),
    _EventItem(
      title: 'Konser Amal Tahunan',
      description: 'Konser penggalangan dana untuk panti asuhan. Kuota talent sudah penuh.',
      budget: 'Rp 5.000.000',
      date: '01 Jun 2025',
      venue: 'Gedung Sate',
      city: 'Bandung',
      status: 'Ditutup',
      statusColor: Colors.red,
      totalApplicants: 24,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final searchQuery = ref.watch(eventSearchQueryProvider);

    // Filter events based on search query
    final filteredEvents = _allEvents.where((event) {
      if (searchQuery.isEmpty) return true;
      final query = searchQuery.toLowerCase();
      return event.title.toLowerCase().contains(query) ||
          event.description.toLowerCase().contains(query) ||
          event.venue.toLowerCase().contains(query) ||
          event.city.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.neutralDark,
      appBar: AppBar(
        title: Text('Cari Event', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppTheme.uiDark,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppTheme.border, height: 1.0),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                ref.read(eventSearchQueryProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                hintText: 'Cari event musik, festival, dll...',
                hintStyle: textTheme.bodyMedium?.copyWith(color: AppTheme.neutralMedium),
                prefixIcon: const Icon(Icons.search, color: AppTheme.neutralMedium),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppTheme.neutralMedium),
                        onPressed: () {
                          ref.read(eventSearchQueryProvider.notifier).state = '';
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
          
          // Event List
          Expanded(
            child: filteredEvents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off_rounded, size: 64, color: AppTheme.neutralMedium),
                        const SizedBox(height: 16),
                        Text(
                          'Event tidak ditemukan',
                          style: textTheme.titleMedium?.copyWith(color: AppTheme.neutralMedium),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = filteredEvents[index];
                      return _buildEventCard(
                        context: context,
                        title: event.title,
                        description: event.description,
                        budget: event.budget,
                        date: event.date,
                        venue: event.venue,
                        city: event.city,
                        status: event.status,
                        statusColor: event.statusColor,
                        totalApplicants: event.totalApplicants,
                        textTheme: textTheme,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard({
    required BuildContext context,
    required String title,
    required String description,
    required String budget,
    required String date,
    required String venue,
    required String city,
    required String status,
    required Color statusColor,
    required int totalApplicants,
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
                  status,
                  style: textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: textTheme.bodySmall?.copyWith(color: AppTheme.neutralMedium),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(budget, style: textTheme.labelSmall?.copyWith(color: AppTheme.highlight, fontWeight: FontWeight.bold)),
              const Spacer(),
              const Icon(Icons.people_outline, size: 14, color: AppTheme.neutralMedium),
              const SizedBox(width: 4),
              Text('$totalApplicants Pelamar', style: textTheme.bodySmall),
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
                child: Text('$venue, $city', style: textTheme.bodySmall, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EventItem {
  final String title;
  final String description;
  final String budget;
  final String date;
  final String venue;
  final String city;
  final String status;
  final Color statusColor;
  final int totalApplicants;

  const _EventItem({
    required this.title,
    required this.description,
    required this.budget,
    required this.date,
    required this.venue,
    required this.city,
    required this.status,
    required this.statusColor,
    required this.totalApplicants,
  });
}
