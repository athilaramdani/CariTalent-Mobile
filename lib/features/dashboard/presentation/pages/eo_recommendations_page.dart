import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/core/widgets/app_card.dart';
import 'package:caritalent_mobile/core/widgets/gradient_text.dart';
import 'package:caritalent_mobile/features/dashboard/application/dashboard_providers.dart';
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
                                  final isInvited = _invitedMap[rec.talent.id] ??
                                      rec.isInvited;
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

  Future<void> _sendInvitation(
      RecommendationModel rec, int eventId) async {
    // Use talent's price_min as default offer, fallback to 0
    final offeredPrice = rec.talent.priceMin ?? 0;
    try {
      await ref.read(invitationRepositoryProvider).sendInvitation(
            eventId: eventId,
            talentId: rec.talent.id,
            offeredPrice: offeredPrice,
          );
      setState(() => _invitedMap[rec.talent.id] = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Undangan berhasil dikirim!'),
          backgroundColor: Colors.green,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal mengirim undangan: $e'),
          backgroundColor: Colors.redAccent,
        ));
      }
    }
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
                    Text(
                      talent.stageName,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                color: isInvited ? const Color(0xFF16A34A) : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isInvited ? Icons.verified : Icons.send_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isInvited ? 'Sudah Diundang' : 'Undang Talent',
                    style: const TextStyle(
                        color: Colors.white,
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
