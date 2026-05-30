import 'package:flutter/material.dart';

class TalentReviewsPage extends StatelessWidget {
  const TalentReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E1F), // dark background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title section
            Text(
              'Your Performance',
              style: textTheme.bodySmall?.copyWith(color: Colors.white54),
            ),
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
              style: textTheme.bodySmall?.copyWith(color: Colors.white54),
            ),
            const SizedBox(height: 24),

            // Card 1: Overall Rating
            _buildOverallRatingCard(textTheme),
            const SizedBox(height: 16),

            // Card 2: Rating Breakdown
            _buildRatingBreakdownCard(textTheme),
            const SizedBox(height: 24),

            // Reviews Title
            Text(
              'Recent Reviews',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Reviews List
            _buildReviewCard(
              context: context,
              organizer: 'Athila Ramdani Saputra',
              event: 'Braga Punk Night Vol.4',
              date: '17 Mar 2026',
              rating: 5,
              review: 'The Rotten Bandung luar biasa. Energi di panggung sangat tinggi, penonton langsung hype dari lagu pertama. Cover Peach dari The Jansen dibawakan dengan sempurna. Pasti kami undang lagi.',
              initials: 'AR',
              avatarColor: const Color(0xFFC48DF6),
              textTheme: textTheme,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallRatingCard(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF271340), Color(0xFF1B0E2A)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.workspace_premium, color: Colors.amber, size: 18),
              const SizedBox(width: 8),
              Text('Overall Rating', style: textTheme.bodyMedium?.copyWith(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '5.0',
                style: textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, left: 4),
                child: Text(
                  '/ 5',
                  style: textTheme.titleLarge?.copyWith(color: Colors.white54),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) => const Icon(Icons.star, color: Colors.amber, size: 20)),
          ),
          const SizedBox(height: 8),
          Text('Based on 1 reviews', style: textTheme.bodySmall?.copyWith(color: Colors.white54)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.trending_up, color: Colors.greenAccent, size: 18),
                      const SizedBox(width: 8),
                      Text('1', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Total Reviews', style: textTheme.bodySmall?.copyWith(color: Colors.white54)),
                ],
              ),
              Column(
                children: [
                  Text('100%', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFFC48DF6))),
                  const SizedBox(height: 4),
                  Text('Positive', style: textTheme.bodySmall?.copyWith(color: Colors.white54)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBreakdownCard(TextTheme textTheme) {
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
          Text('Rating Breakdown', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          _buildProgressBar('5', 1.0, 1, textTheme),
          _buildProgressBar('4', 0.0, 0, textTheme),
          _buildProgressBar('3', 0.0, 0, textTheme),
          _buildProgressBar('2', 0.0, 0, textTheme),
          _buildProgressBar('1', 0.0, 0, textTheme),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String star, double percent, int count, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 32, // Diperlebar dari 20 agar tidak terjadi overflow (2.1 pixel issue)
            child: Row(
              children: [
                Text(star, style: textTheme.bodyMedium?.copyWith(color: Colors.white70)),
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
                widthFactor: percent,
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
              style: textTheme.bodyMedium?.copyWith(color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard({
    required BuildContext context,
    required String organizer,
    required String event,
    required String date,
    required int rating,
    required String review,
    required String initials,
    required Color avatarColor,
    required TextTheme textTheme,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                backgroundColor: avatarColor,
                radius: 18,
                child: Text(
                  initials,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      organizer,
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Event Organizer',
                      style: textTheme.bodySmall?.copyWith(color: Colors.white54),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '"$review"',
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                event,
                style: textTheme.bodySmall?.copyWith(color: Colors.white38),
              ),
              Text(
                date,
                style: textTheme.bodySmall?.copyWith(color: Colors.white38),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
