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

class EoEventsTab extends ConsumerStatefulWidget {
  const EoEventsTab({super.key});

  @override
  ConsumerState<EoEventsTab> createState() => _EoEventsTabState();
}

class _EoEventsTabState extends ConsumerState<EoEventsTab> {
  String _selectedFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final eventsAsync = ref.watch(myEventsProvider);

    return SafeArea(
      child: eventsAsync.when(
        data: (events) {
          // Filter chips data — status values dari API: open, closed, draft, completed, cancelled
          final total = events.length;
          final open =
              events.where((e) => e.status.toLowerCase() == 'open').length;
          final closed =
              events.where((e) => e.status.toLowerCase() == 'closed').length;
          final draft =
              events.where((e) => e.status.toLowerCase() == 'draft').length;
          final completed =
              events.where((e) => e.status.toLowerCase() == 'completed').length;
          final cancelled = events
              .where((e) => e.status.toLowerCase() == 'cancelled')
              .length;

          final filtered = _selectedFilter == 'Semua'
              ? events
              : events
                  .where((e) => e.status.toLowerCase() ==
                      _selectedFilter.toLowerCase())
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
                          'Event Organizer Dashboard',
                          style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold, letterSpacing: 1.0),
                        ),
                        const SizedBox(height: 4),
                        GradientText(
                          'My Events',
                          style: textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ) ??
                              const TextStyle(),
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
                    _buildFilterChip(context, 'Semua', '$total'),
                    _buildFilterChip(context, 'Open', '$open'),
                    _buildFilterChip(context, 'Closed', '$closed'),
                    _buildFilterChip(context, 'Draft', '$draft'),
                    _buildFilterChip(context, 'Completed', '$completed'),
                    _buildFilterChip(context, 'Cancelled', '$cancelled'),
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

  Widget _buildFilterChip(BuildContext context, String label, String count) {
    final textTheme = Theme.of(context).textTheme;
    final isActive = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
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
            Text(label, style: textTheme.labelLarge),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.black38,
                shape: BoxShape.circle,
              ),
              child: Text(
                count,
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

class _EventCard extends ConsumerStatefulWidget {
  final EventModel event;
  final VoidCallback? onDelete;

  const _EventCard({required this.event, this.onDelete});

  @override
  ConsumerState<_EventCard> createState() => _EventCardState();
}

class _EventCardState extends ConsumerState<_EventCard> {
  bool _deleted = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final event = widget.event;
    final statusLower = _deleted ? 'deleted' : event.status.toLowerCase();
    final statusDisplay = _deleted ? 'DELETED' : event.statusLabel.toUpperCase();

    Color statusBgColor;
    Color statusTextColor;
    if (statusLower == 'open') {
      statusBgColor = Colors.green.withValues(alpha: 0.15);
      statusTextColor = Colors.green;
    } else if (statusLower == 'cancelled' || statusLower == 'deleted') {
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
                          _deleted ? TextDecoration.lineThrough : null),
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
                  if (!_deleted && event.latitude != null) {
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
                        _deleted || event.latitude == null
                            ? Icons.location_off_outlined
                            : Icons.location_on_outlined,
                        size: 16,
                        color: AppTheme.highlight),
                    const SizedBox(width: 6),
                    Text(
                      _deleted
                          ? 'Dihapus'
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
              if (!_deleted) ...[
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
                      setState(() => _deleted = true);
                      widget.onDelete?.call();
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
