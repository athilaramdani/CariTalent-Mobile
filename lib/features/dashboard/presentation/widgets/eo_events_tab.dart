import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/core/widgets/app_card.dart';
import 'package:caritalent_mobile/core/widgets/gradient_text.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/pages/eo_applicants_page.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/pages/eo_recommendations_page.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/widgets/create_event_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EoEventsTab extends ConsumerWidget {
  const EoEventsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Event Organizer Dashboard',
                      style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 4),
                    GradientText(
                      'My Events',
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ) ?? const TextStyle(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kelola semua Event yang kamu buat',
                      style: textTheme.bodyMedium,
                    ),
                    Text(
                      '10 Event',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => CreateEventModal.show(context),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppTheme.highlight, AppTheme.accent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 28),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Buat Event',
                      style: textTheme.labelSmall?.copyWith(color: AppTheme.highlight, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(context, 'Semua', '2', true),
                _buildFilterChip(context, 'Draft', '0', false),
                _buildFilterChip(context, 'Open', '2', false),
                _buildFilterChip(context, 'Closed', '1', false),
                _buildFilterChip(context, 'Completed', '1', false),
                _buildFilterChip(context, 'Cancelled', '3', false),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildEventCardDetail(
            context: context,
            title: 'HALO',
            status: 'DRAFT',
            date: '17 Des 2000',
            location: 'Jalan Kaca Kaca Wetan',
            price: 'Rp 50.000',
            applicants: '0 pelamar',
            genre: 'Solo Singer',
            isDraft: true,
            isCancelled: false,
          ),
          const SizedBox(height: 16),
          _buildEventCardDetail(
            context: context,
            title: 'Naon',
            status: 'OPEN',
            date: '17 Des 2004',
            location: 'Asasa',
            price: 'Rp 300',
            applicants: '1 pelamar',
            genre: 'Acoustic',
            isDraft: false,
            isCancelled: false,
          ),
          const SizedBox(height: 16),
          _buildEventCardDetail(
            context: context,
            title: 'tesdt',
            status: 'CANCELLED',
            date: '16 Jul 1000',
            location: 'Asa',
            price: 'Rp 10.000',
            applicants: '1 pelamar',
            genre: 'Acoustic',
            isDraft: false,
            isCancelled: true,
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String count, bool isActive) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(right: 8),
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
            padding: const EdgeInsets.all(6),
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

  Widget _buildEventCardDetail({
    required BuildContext context,
    required String title,
    required String status,
    required String date,
    required String location,
    required String price,
    required String applicants,
    required String genre,
    required bool isDraft,
    required bool isCancelled,
  }) {
    final textTheme = Theme.of(context).textTheme;

    Color statusBgColor;
    Color statusTextColor;
    if (status == 'OPEN') {
      statusBgColor = Colors.green.withValues(alpha: 0.15);
      statusTextColor = Colors.green;
    } else if (status == 'CANCELLED') {
      statusBgColor = Colors.redAccent.withValues(alpha: 0.15);
      statusTextColor = Colors.redAccent;
    } else {
      statusBgColor = Colors.white.withValues(alpha: 0.1);
      statusTextColor = Colors.white70;
    }

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
                  title,
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      status,
                      style: textTheme.labelSmall?.copyWith(
                        color: statusTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.highlight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.highlight.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      price,
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$date • $location',
            style: textTheme.bodySmall?.copyWith(color: AppTheme.neutralMedium),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.people_outline, size: 16, color: Colors.white70),
              const SizedBox(width: 6),
              Text(applicants, style: textTheme.bodySmall?.copyWith(color: Colors.white70)),
              const SizedBox(width: 20),
              Icon(isCancelled ? Icons.block : Icons.location_on_outlined, size: 16, color: Colors.white70),
              const SizedBox(width: 6),
              Text(
                isCancelled ? 'Event Dibatalkan' : 'Lihat Lokasi',
                style: textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Text(
              genre,
              style: textTheme.labelSmall?.copyWith(
                color: AppTheme.highlight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: GestureDetector(
                  onTap: () => context.push(EoApplicantsPage.routePath),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC48DF6), // Solid Light Purple
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_search_outlined, size: 16, color: Color(0xFF3B0764)),
                        const SizedBox(width: 6),
                        Text(
                          'Pelamar (${applicants.replaceAll(RegExp(r'[^0-9]'), '')})',
                          style: textTheme.labelMedium?.copyWith(
                            color: const Color(0xFF3B0764),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 5,
                child: GestureDetector(
                  onTap: () => context.push(EoRecommendationsPage.routePath),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BFFF), // Solid Cyan
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.auto_awesome, size: 16, color: Color(0xFF001F3F)),
                        const SizedBox(width: 6),
                        Text(
                          'Rekomendasi',
                          style: textTheme.labelMedium?.copyWith(
                            color: const Color(0xFF001F3F),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.border),
                ),
                child: const Icon(Icons.edit_outlined, size: 16, color: Colors.white70),
              )
            ],
          )
        ],
      ),
    );
  }
}
