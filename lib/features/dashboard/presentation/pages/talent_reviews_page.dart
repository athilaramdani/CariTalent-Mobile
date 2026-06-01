import 'package:caritalent_mobile/features/dashboard/application/dashboard_providers.dart';
import 'package:caritalent_mobile/features/dashboard/domain/review_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TalentReviewsPage extends ConsumerWidget {
  const TalentReviewsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final reviewsAsync = ref.watch(myReviewsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: reviewsAsync.when(
        data: (data) {
          final avg = data.averageRating;
          final total = data.totalReviews;
          final reviews = data.reviews;

          // Breakdown counts
          final breakdown = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
          for (final r in reviews) {
            final star = r.rating.round().clamp(1, 5);
            breakdown[star] = (breakdown[star] ?? 0) + 1;
          }

          final positiveCount =
              reviews.where((r) => r.rating >= 4).length;
          final positivePercent = total > 0
              ? '${((positiveCount / total) * 100).toStringAsFixed(0)}%'
              : '0%';

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Performance',
                    style:
                        textTheme.bodySmall?.copyWith(color: Colors.white54)),
                const SizedBox(height: 4),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFB500FF), Color(0xFFDE33A2)],
                  ).createShader(bounds),
                  child: Text(
                    'Talent Reviews',
                    style: textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontSize: 32,
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'See what event organizers say about you',
                  style:
                      textTheme.bodySmall?.copyWith(color: Colors.white54),
                ),
                const SizedBox(height: 24),

                // Overall Rating Card
                _buildOverallRatingCard(
                  textTheme: textTheme,
                  avg: avg,
                  total: total,
                  positivePercent: positivePercent,
                ),
                const SizedBox(height: 16),

                // Rating Breakdown Card
                _buildRatingBreakdownCard(
                  textTheme: textTheme,
                  breakdown: breakdown,
                  total: total,
                ),
                const SizedBox(height: 24),

                Text(
                  'Recent Reviews',
                  style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 16),

                if (reviews.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          const Icon(Icons.star_outline,
                              size: 52, color: Colors.white24),
                          const SizedBox(height: 16),
                          Text('Belum ada ulasan',
                              style: textTheme.bodyMedium
                                  ?.copyWith(color: Colors.white38)),
                        ],
                      ),
                    ),
                  )
                else
                  for (final review in reviews) ...[
                    _buildReviewCard(
                        context: context,
                        review: review,
                        textTheme: textTheme),
                    const SizedBox(height: 16),
                  ],

                const SizedBox(height: 40),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              Text('Gagal memuat ulasan: $e',
                  style: const TextStyle(color: Colors.white54)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(myReviewsProvider),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverallRatingCard({
    required TextTheme textTheme,
    required double avg,
    required int total,
    required String positivePercent,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF271340), Color(0xFF1B0E2A)],
        ),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.workspace_premium,
                  color: Colors.amber, size: 18),
              const SizedBox(width: 8),
              Text('Overall Rating',
                  style: textTheme.bodyMedium
                      ?.copyWith(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                avg.toStringAsFixed(1),
                style: textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: 8.0, left: 4),
                child: Text(
                  '/ 5',
                  style: textTheme.titleLarge
                      ?.copyWith(color: Colors.white54),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (i) => Icon(
                i < avg.round()
                    ? Icons.star
                    : Icons.star_border,
                color: Colors.amber,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('Based on $total review${total == 1 ? '' : 's'}',
              style:
                  textTheme.bodySmall?.copyWith(color: Colors.white54)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.trending_up,
                          color: Colors.greenAccent, size: 18),
                      const SizedBox(width: 8),
                      Text('$total',
                          style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Total Reviews',
                      style: textTheme.bodySmall
                          ?.copyWith(color: Colors.white54)),
                ],
              ),
              Column(
                children: [
                  Text(
                    positivePercent,
                    style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFC48DF6)),
                  ),
                  const SizedBox(height: 4),
                  Text('Positive',
                      style: textTheme.bodySmall
                          ?.copyWith(color: Colors.white54)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBreakdownCard({
    required TextTheme textTheme,
    required Map<int, int> breakdown,
    required int total,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16152B),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rating Breakdown',
              style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          for (int star = 5; star >= 1; star--)
            _buildProgressBar(
              '$star',
              total > 0 ? (breakdown[star] ?? 0) / total : 0,
              breakdown[star] ?? 0,
              textTheme,
            ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(
      String star, double percent, int count, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Row(
              children: [
                Text(star,
                    style: textTheme.bodyMedium
                        ?.copyWith(color: Colors.white70)),
                const SizedBox(width: 4),
                const Icon(Icons.star, color: Colors.amber, size: 10),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percent.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFB500FF), Color(0xFFDE33A2)],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 20,
            child: Text(
              '$count',
              textAlign: TextAlign.right,
              style: textTheme.bodyMedium
                  ?.copyWith(color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard({
    required BuildContext context,
    required ReviewModel review,
    required TextTheme textTheme,
  }) {
    final initials = review.organizerName.isNotEmpty
        ? review.organizerName
            .split(' ')
            .take(2)
            .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
            .join()
        : 'EO';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16152B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFC48DF6),
                radius: 18,
                child: Text(
                  initials,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.organizerName,
                      style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Event Organizer',
                      style: textTheme.bodySmall
                          ?.copyWith(color: Colors.white54),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < review.rating.round()
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '"${review.comment ?? 'Tidak ada komentar'}"',
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  review.eventTitle,
                  style:
                      textTheme.bodySmall?.copyWith(color: Colors.white38),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                review.dateFormatted,
                style:
                    textTheme.bodySmall?.copyWith(color: Colors.white38),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
