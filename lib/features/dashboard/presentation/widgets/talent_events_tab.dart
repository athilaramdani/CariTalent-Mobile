import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TalentEventsTab extends ConsumerWidget {
  const TalentEventsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

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
              decoration: InputDecoration(
                hintText: 'Cari event musik, festival, dll...',
                hintStyle: textTheme.bodyMedium?.copyWith(color: AppTheme.neutralMedium),
                prefixIcon: const Icon(Icons.search, color: AppTheme.neutralMedium),
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
          
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('Semua', true, textTheme),
                _buildFilterChip('Bandung', false, textTheme),
                _buildFilterChip('Jakarta', false, textTheme),
                _buildFilterChip('Pop', false, textTheme),
                _buildFilterChip('Jazz', false, textTheme),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Event List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildEventCard(
                  context: context,
                  title: 'Punk Night Vol. 3',
                  description: 'Malam punk rock terbaik di Bandung. Membutuhkan band pembuka beraliran punk/rock.',
                  budget: 'Rp 3.000.000',
                  date: '15 Apr 2026',
                  venue: 'Kafe Kota Bandung',
                  city: 'Bandung',
                  status: 'Dibuka',
                  statusColor: Colors.green,
                  totalApplicants: 12,
                  textTheme: textTheme,
                ),
                _buildEventCard(
                  context: context,
                  title: 'Braga Jazz Evening',
                  description: 'Acara musik jazz mingguan di jalan Braga. Mencari band akustik atau penyanyi solo untuk menemani malam minggu.',
                  budget: 'Rp 1.500.000',
                  date: '12 Mar 2025',
                  venue: 'Braga Art Square',
                  city: 'Bandung',
                  status: 'Dibuka',
                  statusColor: Colors.green,
                  totalApplicants: 5,
                  textTheme: textTheme,
                ),
                _buildEventCard(
                  context: context,
                  title: 'Konser Amal Tahunan',
                  description: 'Konser penggalangan dana untuk panti asuhan. Kuota talent sudah penuh.',
                  budget: 'Rp 5.000.000',
                  date: '01 Jun 2025',
                  venue: 'Gedung Sate',
                  city: 'Bandung',
                  status: 'Ditutup',
                  statusColor: Colors.red,
                  totalApplicants: 24,
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
