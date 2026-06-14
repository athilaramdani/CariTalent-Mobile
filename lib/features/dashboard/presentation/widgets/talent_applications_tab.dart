import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/core/widgets/app_header.dart';
import 'package:caritalent_mobile/core/widgets/gradient_text.dart';
import 'package:caritalent_mobile/features/dashboard/application/dashboard_providers.dart';
import 'package:caritalent_mobile/features/dashboard/domain/application_model.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/widgets/event_map_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

String? _applicationStatusValue(String label) {
  switch (label) {
    case 'Menunggu':
      return 'pending';
    case 'Diterima':
      return 'accepted';
    case 'Ditolak':
      return 'rejected';
    default:
      return null;
  }
}

String _applicationStatusLabel(String status) {
  switch (status.trim().toLowerCase()) {
    case 'pending':
      return 'Menunggu';
    case 'accepted':
      return 'Diterima';
    case 'rejected':
      return 'Ditolak';
    default:
      return status.isEmpty
          ? '-'
          : '${status[0].toUpperCase()}${status.substring(1)}';
  }
}

class TalentApplicationsTab extends ConsumerStatefulWidget {
  const TalentApplicationsTab({super.key});

  @override
  ConsumerState<TalentApplicationsTab> createState() =>
      _TalentApplicationsTabState();
}

class _TalentApplicationsTabState extends ConsumerState<TalentApplicationsTab> {
  String _selectedFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final applicationsAsync = ref.watch(myApplicationsProvider);

    return SafeArea(
      child: applicationsAsync.when(
        data: (applications) {
          final pending =
              applications.where((a) => a.status == 'pending').length;
          final accepted =
              applications.where((a) => a.status == 'accepted').length;
          final rejected =
              applications.where((a) => a.status == 'rejected').length;

          final selectedStatus = _applicationStatusValue(_selectedFilter);
          final filtered = selectedStatus == null
              ? applications
              : applications.where((a) => a.status == selectedStatus).toList();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(myApplicationsProvider);
              await ref.read(myApplicationsProvider.future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
              const AppHeader(),
              const SizedBox(height: 32),
              GradientText(
                'Lamaran Terbaru',
                style: GoogleFonts.syne(
                  textStyle: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Semua event yang kamu lamar\nbeserta status terkini',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // Stats
              Row(
                children: [
                  _buildStatCard(
                    context,
                    '${applications.length}',
                    'Semua',
                    null,
                  ),
                  const SizedBox(width: 8),
                  _buildStatCard(
                    context,
                    '$pending',
                    'Menunggu',
                    Colors.orangeAccent,
                  ),
                  const SizedBox(width: 8),
                  _buildStatCard(
                    context,
                    '$accepted',
                    'Diterima',
                    Colors.greenAccent,
                  ),
                  const SizedBox(width: 8),
                  _buildStatCard(
                    context,
                    '$rejected',
                    'Ditolak',
                    Colors.redAccent,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      context,
                      'Semua',
                      '${applications.length}',
                    ),
                    _buildFilterChip(context, 'Menunggu', '$pending'),
                    _buildFilterChip(context, 'Diterima', '$accepted'),
                    _buildFilterChip(context, 'Ditolak', '$rejected'),
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
                        const Icon(
                          Icons.inbox_outlined,
                          size: 52,
                          color: Colors.white24,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada lamaran',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                for (final app in filtered) ...[
                  _ApplicationCard(
                    application: app,
                    onCancel: () => _cancelApplication(app.id),
                  ),
                  const SizedBox(height: 16),
                ],

              const SizedBox(height: 48),
            ],
          ),
        );
      },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (e, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.redAccent,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Gagal memuat lamaran: $e',
                    style: const TextStyle(color: Colors.white54),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(myApplicationsProvider),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Future<void> _cancelApplication(int id) async {
    try {
      await ref.read(applicationRepositoryProvider).cancelApplication(id);
      ref.invalidate(myApplicationsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membatalkan: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Widget _buildStatCard(
    BuildContext context,
    String value,
    String label,
    Color? valueColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppTheme.uiDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w400,
                color: valueColor ?? Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white54,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String count) {
    final isActive = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient:
              isActive
                  ? const LinearGradient(
                    colors: [Color(0xFFB500FF), Color(0xFFE94057)],
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
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Application Card ─────────────────────────────────────────────────────────

class _ApplicationCard extends StatefulWidget {
  final ApplicationModel application;
  final VoidCallback onCancel;

  const _ApplicationCard({required this.application, required this.onCancel});

  @override
  State<_ApplicationCard> createState() => _ApplicationCardState();
}

class _ApplicationCardState extends State<_ApplicationCard> {
  bool _cancelling = false;

  @override
  Widget build(BuildContext context) {
    final app = widget.application;
    final textTheme = Theme.of(context).textTheme;
    final isPending = app.status == 'pending';

    Color statusColor;
    if (app.status == 'accepted') {
      statusColor = Colors.greenAccent;
    } else if (app.status == 'rejected') {
      statusColor = Colors.redAccent;
    } else {
      statusColor = Colors.orangeAccent;
    }

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
                  app.event?.title ?? 'Event',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _applicationStatusLabel(app.status),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            app.status == 'accepted'
                ? 'Lamaran diterima organizer'
                : app.status == 'rejected'
                    ? 'Lamaran ditolak organizer'
                    : 'Lamaran sedang ditinjau organizer',
            style: TextStyle(
              color: statusColor.withValues(alpha: 0.8),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          if (app.event != null) ...[
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Colors.white54,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${app.event!.venueName} · ${app.event!.city}',
                    style: textTheme.bodySmall?.copyWith(color: Colors.white54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                EventMapButton(
                  eventName: app.event!.title,
                  displayAddress: '${app.event!.venueName}, ${app.event!.city}',
                  latitude: app.event!.latitude,
                  longitude: app.event!.longitude,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 12,
                  color: Colors.white54,
                ),
                const SizedBox(width: 4),
                Text(
                  app.event!.eventDate,
                  style: textTheme.bodySmall?.copyWith(color: Colors.white54),
                ),
              ],
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Divider(
              height: 1,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'HARGA DITAWARKAN',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    app.priceFormatted,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFE879F9),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'DIKIRIM',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    app.dateFormatted,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap:
                  _cancelling
                      ? null
                      : () async {
                        setState(() => _cancelling = true);
                        widget.onCancel();
                        if (mounted) setState(() => _cancelling = false);
                      },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.redAccent.withValues(alpha: 0.4),
                  ),
                ),
                alignment: Alignment.center,
                child:
                    _cancelling
                        ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.redAccent,
                          ),
                        )
                        : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cancel_outlined,
                              color: Colors.redAccent,
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Batalkan Lamaran',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
