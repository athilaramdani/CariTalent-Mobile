import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/core/widgets/app_card.dart';
import 'package:caritalent_mobile/core/widgets/gradient_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EoRecommendationsPage extends StatelessWidget {
  const EoRecommendationsPage({super.key});

  static const routePath = '/eo/recommendations';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neutralDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Internal App Bar / Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: GestureDetector(
                onTap: () => context.pop(),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back_ios, color: Color(0xFFD8B4FE), size: 18),
                    SizedBox(width: 4),
                    Text(
                      'Kembali ke Events',
                      style: TextStyle(
                        color: Color(0xFFD8B4FE), // Light purple
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
            ),

            // Title Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Top 5 talent terbaik berdasarkan match genre, budget, dan lokasi',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, height: 1.4),
                          maxLines: 2,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => context.pushReplacement('/eo/applicants'),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF00BFFF), // Cyan Blue
                      ),
                      child: const Icon(Icons.person_search_outlined, color: Color(0xFF082F49), size: 24),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // List of Recommendations
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildRecommendationCard(
                    context,
                    rank: 1,
                    name: 'Rizky Maulana Acoustic',
                    location: 'Bandung',
                    rating: '4.0',
                    isVerified: true,
                    totalScore: '20',
                    genres: ['Solo Singer', 'Indie Pop', 'Acoustic'],
                    scoreGenre: '0',
                    scoreBudget: '30',
                    scoreLokasi: '20',
                    isInvited: false,
                  ),
                  const SizedBox(height: 16),
                  _buildRecommendationCard(
                    context,
                    rank: 2,
                    name: 'DJ Arfz Bdg',
                    location: 'Bandung',
                    rating: '4.0', // from image
                    isVerified: true,
                    totalScore: '70',
                    genres: ['Solo Singer', 'Indie Pop', 'Acoustic'], // from image
                    scoreGenre: '0',
                    scoreBudget: '30',
                    scoreLokasi: '20',
                    isInvited: true,
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context, {
    required int rank,
    required String name,
    required String location,
    required String rating,
    required bool isVerified,
    required String totalScore,
    required List<String> genres,
    required String scoreGenre,
    required String scoreBudget,
    required String scoreLokasi,
    required bool isInvited,
  }) {
    final isTopRank = rank == 1;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               // Rank Badge
               Container(
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(
                   color: isTopRank ? const Color(0xFFC026D3) : Colors.white.withValues(alpha: 0.2), // Bright purple for #1, grey for others
                   borderRadius: BorderRadius.circular(10),
                 ),
                 child: Text(
                   '#$rank',
                   style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                 ),
               ),
               const SizedBox(width: 12),
               // Info Details
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      Text(
                        name,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            location,
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.star, color: Colors.orangeAccent, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            rating,
                            style: const TextStyle(color: Colors.orangeAccent, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          if (isVerified)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.verified, color: Colors.green, size: 10),
                                  SizedBox(width: 4),
                                  Text('VERIFIED', style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                        ],
                      ),
                   ],
                 ),
               ),
               const SizedBox(width: 8),
               // Total Score
               Column(
                 crossAxisAlignment: CrossAxisAlignment.center,
                 children: [
                    Text(
                      totalScore,
                      style: const TextStyle(color: Color(0xFFE9D5FF), fontSize: 24, fontWeight: FontWeight.w900, height: 1.0), // Light magenta/pink
                    ),
                    const Text(
                      'SKOR',
                      style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                    )
                 ],
               )
            ],
          ),
          const SizedBox(height: 16),
          // Genres
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: genres.map((genre) {
                return Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    genre,
                    style: const TextStyle(
                      color: Color(0xFFD8B4FE), // Light purple
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          // Score Breakdown
          Row(
            children: [
              _buildScoreBox('Genre', scoreGenre),
              const SizedBox(width: 8),
              _buildScoreBox('Budget', scoreBudget),
              const SizedBox(width: 8),
              _buildScoreBox('Lokasi', scoreLokasi),
            ],
          ),
          const SizedBox(height: 16),
          // Action Button
          Container(
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
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
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
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
