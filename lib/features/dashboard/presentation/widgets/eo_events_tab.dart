import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/core/widgets/app_card.dart';
import 'package:caritalent_mobile/core/widgets/gradient_text.dart';
import 'package:caritalent_mobile/features/dashboard/application/dashboard_providers.dart';
import 'package:caritalent_mobile/features/dashboard/domain/event_model.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/pages/eo_applicants_page.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/pages/eo_recommendations_page.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/widgets/create_event_modal.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/widgets/view_location_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';

const _statusFilters = [
  _EventStatusFilter(label: 'Semua'),
  _EventStatusFilter(label: 'Dibuka', value: 'open'),
  _EventStatusFilter(label: 'Ditutup', value: 'closed'),
  _EventStatusFilter(label: 'Selesai', value: 'completed'),
  _EventStatusFilter(label: 'Dibatalkan', value: 'cancelled'),
];

class _EventStatusFilter {
  final String label;
  final String? value;

  const _EventStatusFilter({required this.label, this.value});
}

class EoEventsTab extends ConsumerStatefulWidget {
  const EoEventsTab({super.key});

  @override
  ConsumerState<EoEventsTab> createState() => _EoEventsTabState();
}

class _EoEventsTabState extends ConsumerState<EoEventsTab> {
  String? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final eventsAsync = ref.watch(myEventsProvider);

    return SafeArea(
      child: eventsAsync.when(
        data: (events) {
          // UI labels use Indonesian text while filter values follow API status values.
          int countByStatus(String? status) {
            if (status == null) return events.length;
            return events
                .where((e) => _normalizeEventStatus(e.status) == status)
                .length;
          }

          final total = countByStatus(null);
          final filtered = _selectedStatus == null
              ? events
              : events
                  .where(
                      (e) => _normalizeEventStatus(e.status) == _selectedStatus)
                  .toList();

          return ListView(
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
                          'Selamat Datang kembali,',
                          style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold, letterSpacing: 1.0),
                        ),
                        const SizedBox(height: 4),
                        GradientText(
                          'Event Saya',
                          style: GoogleFonts.syne(
                            textStyle: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Kelola semua Event yang kamu buat',
                          style: textTheme.bodyMedium,
                        ),
                        Text(
                          '$total Event',
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
                          child:
                              const Icon(Icons.add, color: Colors.white, size: 28),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Buat Event',
                          style: textTheme.labelSmall?.copyWith(
                              color: AppTheme.highlight,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final filter in _statusFilters)
                      _buildFilterChip(
                        context,
                        filter: filter,
                        count: countByStatus(filter.value),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (filtered.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        const Icon(Icons.event_busy_outlined,
                            size: 52, color: Colors.white24),
                        const SizedBox(height: 16),
                        Text('Tidak ada event',
                            style: textTheme.bodyMedium
                                ?.copyWith(color: Colors.white38)),
                      ],
                    ),
                  ),
                )
              else
                for (final event in filtered) ...[
                  _EventCard(
                    key: ValueKey('eo-event-${event.id}'),
                    event: event,
                    onDelete: () async {
                      try {
                        await ref
                            .read(eventRepositoryProvider)
                            .cancelEvent(event.id);
                        ref.invalidate(myEventsProvider);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Gagal menghapus: $e'),
                            backgroundColor: Colors.redAccent,
                          ));
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                ],

              const SizedBox(height: 48),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                const SizedBox(height: 16),
                Text('Gagal memuat events: $e',
                    style: const TextStyle(color: Colors.white54),
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(myEventsProvider),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required _EventStatusFilter filter,
    required int count,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final isActive = _selectedStatus == filter.value;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = filter.value),
      child: Container(
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
            Text(filter.label, style: textTheme.labelLarge),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.black38,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                style: textTheme.labelSmall
                    ?.copyWith(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Event Card ───────────────────────────────────────────────────────────────

String _normalizeEventStatus(String status) {
  switch (status.trim().toLowerCase()) {
    case 'open':
    case 'dibuka':
      return 'open';
    case 'closed':
    case 'ditutup':
      return 'closed';
    case 'completed':
    case 'selesai':
      return 'completed';
    case 'cancelled':
    case 'canceled':
    case 'dibatalkan':
      return 'cancelled';
    case 'draft':
      return 'draft';
    default:
      return status.trim().toLowerCase();
  }
}

String _eventStatusLabel(String status) {
  switch (_normalizeEventStatus(status)) {
    case 'open':
      return 'DIBUKA';
    case 'closed':
      return 'DITUTUP';
    case 'completed':
      return 'SELESAI';
    case 'cancelled':
      return 'DIBATALKAN';
    case 'draft':
      return 'DRAFT';
    default:
      return status.toUpperCase();
  }
}

class _EventCard extends ConsumerStatefulWidget {
  final EventModel event;
  final Future<void> Function()? onDelete;

  const _EventCard({super.key, required this.event, this.onDelete});

  @override
  ConsumerState<_EventCard> createState() => _EventCardState();
}

class _EventCardState extends ConsumerState<_EventCard> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final event = widget.event;
    final statusLower = _normalizeEventStatus(event.status);
    final statusDisplay = _eventStatusLabel(statusLower);
    final canRequestRecommendations = !_isDeleting && statusLower == 'open';

    Color statusBgColor;
    Color statusTextColor;
    if (statusLower == 'open') {
      statusBgColor = Colors.green.withValues(alpha: 0.15);
      statusTextColor = Colors.green;
    } else if (statusLower == 'cancelled') {
      statusBgColor = Colors.redAccent.withValues(alpha: 0.15);
      statusTextColor = Colors.redAccent;
    } else if (statusLower == 'completed') {
      statusBgColor = AppTheme.highlight.withValues(alpha: 0.15);
      statusTextColor = AppTheme.highlight;
    } else {
      // draft, closed, unknown
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
                  event.title,
                  style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      decoration:
                          _isDeleting ? TextDecoration.lineThrough : null),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      statusDisplay,
                      style: textTheme.labelSmall?.copyWith(
                        color: statusTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.highlight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppTheme.highlight.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      event.budgetFormatted,
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${event.eventDate} • ${event.venueName}',
            style: textTheme.bodySmall?.copyWith(color: AppTheme.neutralMedium),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.people_outline, size: 16, color: Colors.white70),
              const SizedBox(width: 6),
              Text('${event.totalApplicants} pelamar',
                  style: textTheme.bodySmall?.copyWith(color: Colors.white70)),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  if (!_isDeleting && event.latitude != null) {
                    ViewLocationModal.show(
                      context,
                      eventName: event.title,
                      displayAddress: '${event.venueName}, ${event.city}',
                      location: LatLng(event.latitude!, event.longitude!),
                    );
                  }
                },
                child: Row(
                  children: [
                    Icon(
                        _isDeleting || event.latitude == null
                            ? Icons.location_off_outlined
                            : Icons.location_on_outlined,
                        size: 16,
                        color: AppTheme.highlight),
                    const SizedBox(width: 6),
                    Text(
                      _isDeleting
                          ? 'Menghapus'
                          : 'Lihat Lokasi',
                      style:
                          textTheme.bodySmall?.copyWith(
                            color: AppTheme.highlight,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (event.genres.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: event.genres
                  .take(3)
                  .map((g) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Text(
                          g,
                          style: textTheme.labelSmall?.copyWith(
                            color: AppTheme.highlight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: GestureDetector(
                  onTap: () =>
                      context.push('${EoApplicantsPage.routePath}/${event.id}'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC48DF6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_search_outlined,
                            size: 16, color: Color(0xFF3B0764)),
                        const SizedBox(width: 6),
                        Text(
                          'Pelamar (${event.totalApplicants})',
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
              if (canRequestRecommendations) ...[
                const SizedBox(width: 8),
                Expanded(
                  flex: 5,
                  child: GestureDetector(
                    onTap: () => context.push(
                        '${EoRecommendationsPage.routePath}/${event.id}'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00BFFF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.auto_awesome,
                              size: 16, color: Color(0xFF001F3F)),
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
              ],
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => CreateEventModal.show(context, event: event),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: const Icon(Icons.edit_outlined,
                      size: 16, color: Colors.white70),
                ),
              ),
              if (!_isDeleting) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: AppTheme.neutralDark,
                        title: const Text('Hapus Event?',
                            style: TextStyle(color: Colors.white)),
                        content: Text(
                            'Event "${event.title}" akan dihapus. Tindakan ini tidak dapat dibatalkan.',
                            style: const TextStyle(color: Colors.white70)),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Batal')),
                          TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Hapus',
                                  style: TextStyle(color: Colors.redAccent))),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      setState(() => _isDeleting = true);
                      await widget.onDelete?.call();
                      if (mounted) {
                        setState(() => _isDeleting = false);
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.redAccent.withValues(alpha: 0.2)),
                    ),
                    child: const Icon(Icons.delete_outline,
                        size: 16, color: Colors.redAccent),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
