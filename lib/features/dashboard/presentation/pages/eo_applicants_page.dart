import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/core/widgets/app_card.dart';
import 'package:caritalent_mobile/core/widgets/gradient_text.dart';
import 'package:caritalent_mobile/features/dashboard/application/dashboard_providers.dart';
import 'package:caritalent_mobile/features/dashboard/domain/application_model.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/pages/eo_recommendations_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EoApplicantsPage extends ConsumerStatefulWidget {
  final int eventId;
  const EoApplicantsPage({super.key, required this.eventId});

  static const routePath = '/eo/applicants';

  @override
  ConsumerState<EoApplicantsPage> createState() => _EoApplicantsPageState();
}

class _EoApplicantsPageState extends ConsumerState<EoApplicantsPage> {
  String _selectedFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final applicantsAsync =
        ref.watch(eventApplicationsProvider(widget.eventId));

    return Scaffold(
      backgroundColor: AppTheme.neutralDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: GestureDetector(
                onTap: () => context.pop(),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back_ios,
                        color: Color(0xFFD8B4FE), size: 18),
                    SizedBox(width: 4),
                    Text(
                      'Kembali ke Events',
                      style: TextStyle(
                          color: Color(0xFFD8B4FE),
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            applicantsAsync.when(
              data: (applicants) {
                final total = applicants.length;
                final pending =
                    applicants.where((a) => a.status == 'pending').length;
                final accepted =
                    applicants.where((a) => a.status == 'accepted').length;
                final rejected =
                    applicants.where((a) => a.status == 'rejected').length;

                final filtered = _selectedFilter == 'Semua'
                    ? applicants
                    : applicants.where((a) {
                        switch (_selectedFilter) {
                          case 'Pending':
                            return a.status == 'pending';
                          case 'Accepted':
                            return a.status == 'accepted';
                          case 'Rejected':
                            return a.status == 'rejected';
                          default:
                            return true;
                        }
                      }).toList();

                return Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const GradientText(
                                  'Pelamar Event',
                                  style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Event #${widget.eventId} · $total pelamar',
                                  style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.7),
                                      fontSize: 13),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () => context.pushReplacement(
                                  '${EoRecommendationsPage.routePath}/${widget.eventId}'),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF00BFFF),
                                ),
                                child: const Icon(Icons.auto_awesome,
                                    color: Color(0xFF082F49), size: 24),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            _buildFilterChip('Semua', '$total'),
                            _buildFilterChip('Pending', '$pending'),
                            _buildFilterChip('Accepted', '$accepted'),
                            _buildFilterChip('Rejected', '$rejected'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // List
                      Expanded(
                        child: filtered.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(40),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.inbox_outlined,
                                          size: 52, color: Colors.white24),
                                      const SizedBox(height: 16),
                                      Text('Tidak ada pelamar',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  color: Colors.white38)),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20),
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 16),
                                itemBuilder: (_, i) => _ApplicantCard(
                                  application: filtered[i],
                                  onAccept: () => _updateStatus(
                                      filtered[i].id, 'accepted'),
                                  onReject: () => _updateStatus(
                                      filtered[i].id, 'rejected'),
                                ),
                              ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                );
              },
              loading: () => const Expanded(
                  child: Center(child: CircularProgressIndicator())),
              error: (e, _) => Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.redAccent, size: 48),
                      const SizedBox(height: 16),
                      Text('Gagal memuat: $e',
                          style: const TextStyle(color: Colors.white54)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(
                            eventApplicationsProvider(widget.eventId)),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(int applicationId, String status) async {
    try {
      await ref.read(applicationRepositoryProvider).updateApplicationStatus(
            id: applicationId,
            status: status,
          );
      ref.invalidate(eventApplicationsProvider(widget.eventId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal: $e'),
          backgroundColor: Colors.redAccent,
        ));
      }
    }
  }

  Widget _buildFilterChip(String label, String count) {
    final isActive = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFFB57AFF), Color(0xFFE94057)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isActive ? null : Colors.transparent,
          border: isActive ? null : Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: const BoxDecoration(
                color: Colors.black38,
                shape: BoxShape.circle,
              ),
              child: Text(count,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Applicant Card ───────────────────────────────────────────────────────────

class _ApplicantCard extends StatefulWidget {
  final ApplicationModel application;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _ApplicantCard({
    required this.application,
    required this.onAccept,
    required this.onReject,
  });

  @override
  State<_ApplicantCard> createState() => _ApplicantCardState();
}

class _ApplicantCardState extends State<_ApplicantCard> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final app = widget.application;
    final talent = app.talent;
    final name = talent?.stageName ?? 'Talent';
    final location = talent?.city ?? '';
    final rating = talent?.averageRating.toStringAsFixed(1) ?? '0.0';
    final isVerified = talent?.verified ?? false;
    final genres = talent?.genre ?? [];
    final isPending = app.status == 'pending';
    final isRejected = app.status == 'rejected';
    final isAccepted = app.status == 'accepted';

    Color statusColor;
    if (isAccepted) {
      statusColor = Colors.green;
    } else if (isRejected) {
      statusColor = Colors.redAccent;
    } else {
      statusColor = Colors.orangeAccent;
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
                  name,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${app.status[0].toUpperCase()}${app.status.substring(1)}',
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(location,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 14)),
              const SizedBox(width: 8),
              const Icon(Icons.star, color: Colors.orangeAccent, size: 16),
              const SizedBox(width: 2),
              Text(rating,
                  style: const TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              if (isVerified)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified, color: Colors.green, size: 12),
                      SizedBox(width: 4),
                      Text('VERIFIED',
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (genres.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: genres
                    .map((genre) => Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Text(
                            genre,
                            style: const TextStyle(
                                color: Color(0xFFD8B4FE),
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                          ),
                        ))
                    .toList(),
              ),
            ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('HARGA DITAWARKAN',
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    app.priceFormatted,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('DIKIRIM',
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    app.dateFormatted,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),

          // Action buttons only for pending
          if (isPending) ...[
            const SizedBox(height: 20),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            setState(() => _loading = true);
                            widget.onAccept();
                            if (mounted) setState(() => _loading = false);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline,
                                    color: Colors.white, size: 18),
                                SizedBox(width: 6),
                                Text('Terima',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            setState(() => _loading = true);
                            widget.onReject();
                            if (mounted) setState(() => _loading = false);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFFFCA5A5)
                                      .withValues(alpha: 0.3)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cancel_outlined,
                                    color: Color(0xFFFCA5A5), size: 18),
                                SizedBox(width: 6),
                                Text('Tolak',
                                    style: TextStyle(
                                        color: Color(0xFFFCA5A5),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ],

          if (isRejected) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Text('Telah Ditolak',
                  style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }
}
