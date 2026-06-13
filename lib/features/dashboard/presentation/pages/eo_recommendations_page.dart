import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/core/network/api_exception.dart';
import 'package:caritalent_mobile/core/widgets/app_card.dart';
import 'package:caritalent_mobile/core/widgets/gradient_text.dart';
import 'package:caritalent_mobile/features/dashboard/application/dashboard_providers.dart';
import 'package:caritalent_mobile/features/dashboard/domain/invitation_model.dart';
import 'package:caritalent_mobile/features/dashboard/domain/recommendation_model.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/pages/eo_applicants_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EoRecommendationsPage extends ConsumerStatefulWidget {
  final int eventId;
  const EoRecommendationsPage({super.key, required this.eventId});

  static const routePath = '/eo/recommendations';

  @override
  ConsumerState<EoRecommendationsPage> createState() =>
      _EoRecommendationsPageState();
}

class _EoRecommendationsPageState
    extends ConsumerState<EoRecommendationsPage> {
  // Track locally invited status for optimistic UI
  final Map<int, bool> _invitedMap = {};

  @override
  Widget build(BuildContext context) {
    final recAsync = ref.watch(recommendationsProvider(widget.eventId));
    final sentInvitations =
        ref.watch(sentInvitationsProvider).valueOrNull ?? const <InvitationModel>[];

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
                    Text('Kembali ke Events',
                        style: TextStyle(
                            color: Color(0xFFD8B4FE),
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

            recAsync.when(
              data: (data) {
                return Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const GradientText(
                                    'Rekomendasi Talent',
                                    style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    data.eventTitle.isNotEmpty
                                        ? data.eventTitle
                                        : 'Event #${widget.eventId}',
                                    style: TextStyle(
                                        color:
                                            Colors.white.withValues(alpha: 0.7),
                                        fontSize: 13),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Top ${data.recommendations.length} talent terbaik berdasarkan match genre, budget, dan lokasi',
                                    style: TextStyle(
                                        color:
                                            Colors.white.withValues(alpha: 0.7),
                                        fontSize: 13,
                                        height: 1.4),
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () => context.pushReplacement(
                                  '${EoApplicantsPage.routePath}/${widget.eventId}'),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF00BFFF),
                                ),
                                child: const Icon(Icons.person_search_outlined,
                                    color: Color(0xFF082F49), size: 24),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      data.recommendations.isEmpty
                          ? const Expanded(
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(40),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.auto_awesome,
                                          size: 52, color: Colors.white24),
                                      SizedBox(height: 16),
                                      Text(
                                          'Belum ada rekomendasi untuk event ini',
                                          style: TextStyle(
                                              color: Colors.white38),
                                          textAlign: TextAlign.center),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Expanded(
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20),
                                itemCount: data.recommendations.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 16),
                                itemBuilder: (_, i) {
                                  final rec = data.recommendations[i];
                                  final isInvited = _isInvited(
                                    rec,
                                    sentInvitations,
                                    data,
                                  );
                                  return _RecommendationCard(
                                    rec: rec,
                                    isInvited: isInvited,
                                    onInvite: () =>
                                        _sendInvitation(rec, widget.eventId),
                                  );
                                },
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
                            recommendationsProvider(widget.eventId)),
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

  Future<void> _sendInvitation(RecommendationModel rec, int eventId) async {
    final price = await showDialog<double>(
      context: context,
      builder: (context) => _InviteTalentDialog(talentName: rec.talent.stageName),
    );

    if (price == null) return;

    try {
      final talentId = rec.talent.userId > 0 ? rec.talent.userId : rec.talent.id;
      await ref.read(invitationRepositoryProvider).sendInvitation(
            eventId: eventId,
            talentId: talentId,
            offeredPrice: price,
          );
      // Optimistic UI: mark as invited immediately
      setState(() => _markInvited(rec));

      // Invalidate to sync with backend for long-term consistency
      ref.invalidate(recommendationsProvider(widget.eventId));
      ref.invalidate(sentInvitationsProvider);
      if (mounted) {
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
      }
    } catch (e) {
      if (mounted) {
        String errorMessage;
        if (e is ApiException) {
          // Try to extract detailed messages from errors map
          final errorsObj = e.errors;
          if (errorsObj is Map) {
            final details = errorsObj.values
                .expand((v) => v is List ? v : [v.toString()])
                .join(', ');
            errorMessage = details.isNotEmpty ? details : e.message;
          } else {
            errorMessage = e.message;
          }
          // Handle common business rule: already invited
          final msg = errorMessage.toLowerCase();
          if (msg.contains('sudah') ||
              msg.contains('already') ||
              msg.contains('diundang') ||
              msg.contains('invited') ||
              msg.contains('duplicate')) {
            // Still mark as invited in UI since invitation already exists
            setState(() => _markInvited(rec));
            ref.invalidate(recommendationsProvider(widget.eventId));
            ref.invalidate(sentInvitationsProvider);

            // Show the same SUCCESS pop-up for already invited to satisfy user's request for confirmation
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
            return; // Don't show the error snackbar
          }
        } else {
          errorMessage = e.toString();
          if (errorMessage.contains('Exception:')) {
            errorMessage = errorMessage.split('Exception:').last.trim();
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 4),
        ));
      }
    }
  }

  bool _isInvited(
    RecommendationModel rec,
    List<InvitationModel> sentInvitations,
    RecommendationsData recommendationsData,
  ) {
    if (_invitedMap[rec.talent.id] == true ||
        _invitedMap[rec.talent.userId] == true ||
        rec.isInvited ||
        recommendationsData.invitedTalentIds.contains(rec.talent.id) ||
        recommendationsData.invitedTalentIds.contains(rec.talent.userId)) {
      return true;
    }

    final talentIds = <int>{rec.talent.id, rec.talent.userId}
      ..removeWhere((id) => id <= 0);
    if (talentIds.isEmpty) return false;

    return sentInvitations.any((invitation) {
      final isSameEvent = invitation.eventId == widget.eventId ||
          (invitation.eventId == null &&
              _sameText(invitation.eventTitle, recommendationsData.eventTitle));
      final status = invitation.status.trim().toLowerCase();
      final isActiveInvitation =
          status != 'rejected' && status != 'cancelled' && status != 'canceled';
      final invitationTalentIds = <int>{
        if (invitation.talentId != null) invitation.talentId!,
        if (invitation.talent != null) invitation.talent!.id,
        if (invitation.talent != null) invitation.talent!.userId,
      }..removeWhere((id) => id <= 0);

      return isSameEvent &&
          isActiveInvitation &&
          invitationTalentIds.any(talentIds.contains);
    });
  }

  void _markInvited(RecommendationModel rec) {
    if (rec.talent.id > 0) _invitedMap[rec.talent.id] = true;
    if (rec.talent.userId > 0) _invitedMap[rec.talent.userId] = true;
  }

  bool _sameText(String left, String right) {
    if (left.isEmpty || right.isEmpty) return false;
    return left.trim().toLowerCase() == right.trim().toLowerCase();
  }
}

// ─── Recommendation Card ──────────────────────────────────────────────────────

class _RecommendationCard extends StatelessWidget {
  final RecommendationModel rec;
  final bool isInvited;
  final VoidCallback onInvite;

  const _RecommendationCard({
    required this.rec,
    required this.isInvited,
    required this.onInvite,
  });

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TalentRecommendationDetailModal(
        rec: rec,
        isInvited: isInvited,
        onInvite: onInvite,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final talent = rec.talent;
    final isTopRank = rec.rank == 1;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isTopRank
                      ? const Color(0xFFC026D3)
                      : Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '#${rec.rank}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => _showDetail(context),
                      child: Text(
                        talent.stageName,
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(talent.city,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13)),
                        const SizedBox(width: 8),
                        const Icon(Icons.star,
                            color: Colors.orangeAccent, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          talent.averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        if (talent.verified)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.verified,
                                    color: Colors.green, size: 10),
                                SizedBox(width: 4),
                                Text('VERIFIED',
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${rec.score}',
                    style: const TextStyle(
                        color: Color(0xFFE9D5FF),
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        height: 1.0),
                  ),
                  const Text('SKOR',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Genres
          if (talent.genre.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: talent.genre
                    .map((g) => Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Text(g,
                              style: const TextStyle(
                                  color: Color(0xFFD8B4FE),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ))
                    .toList(),
              ),
            ),
          const SizedBox(height: 16),

          // Score Breakdown
          Row(
            children: [
              _buildScoreBox('Genre', '${rec.scoreBreakdown.genreScore}'),
              const SizedBox(width: 8),
              _buildScoreBox('Budget', '${rec.scoreBreakdown.budgetScore}'),
              const SizedBox(width: 8),
              _buildScoreBox('Lokasi', '${rec.scoreBreakdown.locationScore}'),
            ],
          ),
          const SizedBox(height: 16),

          // Detail Button
          GestureDetector(
            onTap: () => _showDetail(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFFD8B4FE).withValues(alpha: 0.3)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_search_outlined,
                      color: Color(0xFFD8B4FE), size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Detail talent',
                    style: TextStyle(
                        color: Color(0xFFD8B4FE),
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Action button
          GestureDetector(
            onTap: isInvited ? null : onInvite,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: isInvited
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFFB57AFF), Color(0xFFE94057)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                color: isInvited
                    ? const Color(0xFF22C55E).withValues(alpha: 0.15)
                    : null,
                borderRadius: BorderRadius.circular(12),
                border: isInvited
                    ? Border.all(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.5),
                        width: 1.5)
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isInvited ? Icons.check_circle : Icons.send_outlined,
                    color: isInvited ? const Color(0xFF22C55E) : Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isInvited ? 'Sudah diundang' : 'Undang Talent',
                    style: TextStyle(
                        color: isInvited ? const Color(0xFF22C55E) : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ─── Talent Recommendation Detail Modal ───────────────────────────────────────

class _TalentRecommendationDetailModal extends StatefulWidget {
  final RecommendationModel rec;
  final bool isInvited;
  final VoidCallback onInvite;

  const _TalentRecommendationDetailModal({
    required this.rec,
    required this.isInvited,
    required this.onInvite,
  });

  @override
  State<_TalentRecommendationDetailModal> createState() =>
      _TalentRecommendationDetailModalState();
}

class _TalentRecommendationDetailModalState
    extends State<_TalentRecommendationDetailModal> {
  @override
  Widget build(BuildContext context) {
    final rec = widget.rec;
    final talent = rec.talent;
    final name = talent.stageName;
    final fullName = talent.fullName ?? talent.stageName;
    final city = talent.city;
    final email = talent.email;
    final phone = talent.phone;
    final isVerified = talent.verified;
    final genres = talent.genre;
    final rating = talent.averageRating;
    final priceRange = talent.priceRangeFormatted;
    final portfolio = talent.portfolioLink;
    final bio = talent.bio;

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
                            'Profil lengkap talent rekomendasi',
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
                            value: fullName,
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
                            label: 'EMAIL',
                            value: email?.isNotEmpty == true ? email! : '-',
                            icon: Icons.email_outlined,
                            iconColor: const Color(0xFFD8B4FE),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoCard(
                            label: 'NOMOR HP',
                            value: phone?.isNotEmpty == true ? phone! : '-',
                            icon: Icons.phone_outlined,
                            iconColor: const Color(0xFFD8B4FE),
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

                    // Action button in modal
                    GestureDetector(
                      onTap: widget.isInvited
                          ? null
                          : () {
                              widget.onInvite();
                            },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: widget.isInvited
                              ? null
                              : const LinearGradient(
                                  colors: [Color(0xFFB57AFF), Color(0xFFE94057)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                          color: widget.isInvited
                              ? const Color(0xFF22C55E).withValues(alpha: 0.15)
                              : null,
                          borderRadius: BorderRadius.circular(12),
                          border: widget.isInvited
                              ? Border.all(
                                  color: const Color(0xFF22C55E).withValues(alpha: 0.5),
                                  width: 1.5)
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.isInvited
                                  ? Icons.check_circle
                                  : Icons.send_outlined,
                              color: widget.isInvited
                                  ? const Color(0xFF22C55E)
                                  : Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.isInvited
                                  ? 'Sudah diundang'
                                  : 'Undang Talent',
                              style: TextStyle(
                                  color: widget.isInvited
                                      ? const Color(0xFF22C55E)
                                      : Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),

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

// ─── Invite Talent Dialog ─────────────────────────────────────────────────────

class _InviteTalentDialog extends StatefulWidget {
  final String talentName;

  const _InviteTalentDialog({required this.talentName});

  @override
  State<_InviteTalentDialog> createState() => _InviteTalentDialogState();
}

class _InviteTalentDialogState extends State<_InviteTalentDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                'Undang Talent',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFD8B4FE),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tentukan harga penawaran (offering price) untuk ${widget.talentName}.',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 24),
              const Text(
                'Harga Penawaran (Rp) *',
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
                  hintText: 'Contoh: 2000000',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: Colors.black26,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFB57AFF)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFB57AFF)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Color(0xFFD8B4FE), width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga penawaran wajib diisi';
                  }
                  if (double.tryParse(value) == null) {
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
                        color: const Color(0xFFB57AFF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.send, size: 16, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Kirim Undangan',
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

