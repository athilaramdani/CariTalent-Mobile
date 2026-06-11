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
  // Show dialog to get agreed_price then call accept API
  Future<void> _handleAccept(ApplicationModel app) async {
    final proposedPrice = app.proposedPrice;
    final agreedPrice = await showDialog<double>(
      context: context,
      builder: (_) => _AcceptWithPriceDialog(
        talentName: app.talent?.stageName ?? 'Talent',
        proposedPrice: proposedPrice,
      ),
    );
    if (agreedPrice == null) return;
    await _updateStatus(app.id, 'accepted', agreedPrice: agreedPrice);
  }

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
                                  onAccept: () => _handleAccept(filtered[i]),
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

  Future<void> _updateStatus(int applicationId, String status, {double? agreedPrice}) async {
    try {
      await ref.read(applicationRepositoryProvider).updateApplicationStatus(
            id: applicationId,
            status: status,
            agreedPrice: agreedPrice,
          );
      ref.invalidate(eventApplicationsProvider(widget.eventId));
      ref.invalidate(myBookingsProvider);
      if (mounted) {
        if (status == 'accepted') {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFF22C55E), width: 2),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 64),
                  const SizedBox(height: 20),
                  const Text(
                    'Berhasil!',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Data sudah masuk ke dalam sistem.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Lamaran ditolak.'),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 3),
          ));
        }
      }
    } catch (e) {
      if (mounted) {
        String errMsg = e.toString();
        if (errMsg.contains('Exception:')) {
          errMsg = errMsg.split('Exception:').last.trim();
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal: $errMsg'),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 4),
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

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ApplicantDetailModal(
        application: widget.application,
        onAccept: widget.onAccept,
        onReject: widget.onReject,
      ),
    );
  }

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

    Color statusColor;
    if (app.status == 'accepted') {
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
                child: GestureDetector(
                  onTap: () => _showDetail(context),
                  child: Text(
                    name,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD8B4FE),
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFFD8B4FE)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
            // Detail button below Terima/Tolak
            if (!_loading) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _showDetail(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD8B4FE).withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_search_outlined,
                          color: Color(0xFFD8B4FE), size: 16),
                      SizedBox(width: 6),
                      Text('Detail',
                          style: TextStyle(
                              color: Color(0xFFD8B4FE),
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
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
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _showDetail(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD8B4FE).withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_search_outlined,
                        color: Color(0xFFD8B4FE), size: 16),
                    SizedBox(width: 6),
                    Text('Detail',
                        style: TextStyle(
                            color: Color(0xFFD8B4FE),
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],

          if (app.status == 'accepted') ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              alignment: Alignment.center,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 6),
                  Text('Telah Diterima',
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _showDetail(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD8B4FE).withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_search_outlined,
                        color: Color(0xFFD8B4FE), size: 16),
                    SizedBox(width: 6),
                    Text('Detail',
                        style: TextStyle(
                            color: Color(0xFFD8B4FE),
                            fontSize: 13,
                            fontWeight: FontWeight.bold)),
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

// ─── Applicant Detail Modal ────────────────────────────────────────────────────

class _ApplicantDetailModal extends StatefulWidget {
  final ApplicationModel application;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _ApplicantDetailModal({
    required this.application,
    required this.onAccept,
    required this.onReject,
  });

  @override
  State<_ApplicantDetailModal> createState() => _ApplicantDetailModalState();
}

class _ApplicantDetailModalState extends State<_ApplicantDetailModal> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final app = widget.application;
    final talent = app.talent;
    final name = talent?.stageName ?? 'Talent';
    final city = talent?.city ?? '-';
    final isVerified = talent?.verified ?? false;
    final genres = talent?.genre ?? [];
    final rating = talent?.averageRating ?? 0.0;
    final priceRange = talent?.priceRangeFormatted ?? '-';
    final portfolio = talent?.portfolioLink;
    final bio = talent?.bio;
    final isPending = app.status == 'pending';

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E1A2E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (isVerified) ...[
                                const Icon(Icons.verified,
                                    color: Colors.green, size: 14),
                                const SizedBox(width: 4),
                                const Text('Verified',
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ] else
                                const Text('Belum Terverifikasi',
                                    style: TextStyle(
                                        color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Profil lengkap talent pelamar',
                            style: TextStyle(
                                color: Colors.white38, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white70, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),

              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Grid info cards
                    Row(
                      children: [
                        Expanded(
                          child: _InfoCard(
                            label: 'NAMA LENGKAP',
                            value: name,
                            icon: Icons.person_outline,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoCard(
                            label: 'KOTA ASAL',
                            icon: Icons.location_on_outlined,
                            value: city,
                            iconColor: Colors.orangeAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _InfoCard(
                            label: 'ESTIMASI TARIF',
                            icon: Icons.monetization_on_outlined,
                            value: priceRange,
                            iconColor: const Color(0xFFD8B4FE),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoCard(
                            label: 'AVERAGE RATING',
                            icon: Icons.star,
                            value: '${rating.toStringAsFixed(1)} / 5.0',
                            iconColor: Colors.orangeAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Genres
                    if (genres.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'GENRE MUSIK',
                              style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 10,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: genres
                                  .map((g) => Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFD8B4FE)
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                              color: const Color(0xFFD8B4FE)
                                                  .withValues(alpha: 0.3)),
                                        ),
                                        child: Text(g,
                                            style: const TextStyle(
                                                color: Color(0xFFD8B4FE),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600)),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Portfolio
                    if (portfolio != null && portfolio.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'LINK PORTOFOLIO',
                              style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 10,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.link,
                                    size: 16, color: Color(0xFF60A5FA)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    portfolio,
                                    style: const TextStyle(
                                        color: Color(0xFF60A5FA),
                                        fontSize: 13),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Bio
                    if (bio != null && bio.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'DESKRIPSI / BIO',
                              style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 10,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              bio,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Application details
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DETAIL LAMARAN',
                            style: TextStyle(
                                color: Colors.white54,
                                fontSize: 10,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Harga Ditawarkan',
                                      style: TextStyle(
                                          color: Colors.white54, fontSize: 11)),
                                  const SizedBox(height: 4),
                                  Text(app.priceFormatted,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('Tanggal Kirim',
                                      style: TextStyle(
                                          color: Colors.white54, fontSize: 11)),
                                  const SizedBox(height: 4),
                                  Text(app.dateFormatted,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                          if (app.message != null && app.message!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Divider(color: Colors.white10),
                            const SizedBox(height: 8),
                            const Text('Pesan',
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 11)),
                            const SizedBox(height: 4),
                            Text(app.message!,
                                style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    height: 1.4)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action buttons in modal  
                    if (isPending) ...[
                      _loading
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () async {
                                          setState(() => _loading = true);
                                          widget.onAccept();
                                          if (mounted) Navigator.of(context).pop();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF22C55E),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.check_circle_outline,
                                                  color: Colors.white, size: 18),
                                              SizedBox(width: 6),
                                              Text('Terima',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold)),
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
                                          if (mounted) Navigator.of(context).pop();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14),
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: const Color(0xFFFCA5A5)
                                                    .withValues(alpha: 0.4)),
                                          ),
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.cancel_outlined,
                                                  color: Color(0xFFFCA5A5),
                                                  size: 18),
                                              SizedBox(width: 6),
                                              Text('Tolak',
                                                  style: TextStyle(
                                                      color: Color(0xFFFCA5A5),
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Info Card helper ──────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _InfoCard({
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor = Colors.white54,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                color: Colors.white54,
                fontSize: 9,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Accept With Price Dialog ─────────────────────────────────────────────────

class _AcceptWithPriceDialog extends StatefulWidget {
  final String talentName;
  final double? proposedPrice;

  const _AcceptWithPriceDialog({
    required this.talentName,
    this.proposedPrice,
  });

  @override
  State<_AcceptWithPriceDialog> createState() => _AcceptWithPriceDialogState();
}

class _AcceptWithPriceDialogState extends State<_AcceptWithPriceDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Pre-fill with proposed price if available
    if (widget.proposedPrice != null) {
      _controller.text = widget.proposedPrice!.toInt().toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatRp(double amount) {
    final n = amount.toInt();
    return 'Rp ${n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(24),
      content: SizedBox(
        width: screenWidth * 0.85,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Terima Lamaran',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF22C55E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tentukan harga yang disepakati untuk ${widget.talentName}.',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              if (widget.proposedPrice != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Harga ajuan talent: ${_formatRp(widget.proposedPrice!)}',
                  style: const TextStyle(
                      color: Color(0xFFD8B4FE),
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ],
              const SizedBox(height: 20),
              const Text(
                'Harga Disepakati (Rp) *',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _controller,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Contoh: 1500000',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: Colors.black26,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFF22C55E)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFF22C55E)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                        color: Color(0xFF4ADE80), width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga disepakati wajib diisi';
                  }
                  final parsed = double.tryParse(value);
                  if (parsed == null || parsed <= 0) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal',
                        style: TextStyle(color: Colors.white54)),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(
                            context, double.parse(_controller.text));
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 16, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Terima & Buat Booking',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
