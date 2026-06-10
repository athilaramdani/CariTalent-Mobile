import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/core/widgets/app_shell.dart';
import 'package:caritalent_mobile/core/widgets/gradient_text.dart';
import 'package:caritalent_mobile/features/auth/application/auth_controller.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/pages/talent_reviews_page.dart';
import 'package:caritalent_mobile/features/public/presentation/pages/public_home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TalentProfilePage extends ConsumerWidget {
  const TalentProfilePage({super.key});

  static const routePath = '/talent-profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final user = ref.watch(authControllerProvider).user;

    // Data based on image 1
    final stageName = user?.name ?? 'The Rotten Bandung';
    const city = 'Bandung';
    const bio = 'Band pop punk asal Bandung dengan 5 tahun pengalaman di berbagai event lokal maupun nasional.';
    final genres = ['Pop Punk', 'Alternative Rock'];
    const priceMin = 'Rp 1.000.000';
    const priceMax = 'Rp 3.000.000';
    const portfolioLink = 'https://youtube.com/therottenbandung';
    const isVerified = true;
    const rating = 4.8;
    const reviews = 12;

    return AppShell(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Profil Talent',
          style: textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Avatar & Info
            _buildHeader(stageName, city, isVerified, rating, reviews, textTheme, context),
            const SizedBox(height: 24),

            // Bio
            _buildSection(
              title: 'Bio',
              child: Text(
                bio,
                style: textTheme.bodyMedium?.copyWith(color: Colors.white70, height: 1.5),
              ),
              textTheme: textTheme,
            ),
            const SizedBox(height: 16),

            // Genres
            _buildSection(
              title: 'Genre',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: genres.map((g) => _buildGenreChip(g, textTheme)).toList(),
              ),
              textTheme: textTheme,
            ),
            const SizedBox(height: 16),

            // Price Range
            _buildSection(
              title: 'Tarif Harga (Range)',
              child: Row(
                children: [
                   ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppTheme.highlight, AppTheme.accent],
                    ).createShader(bounds),
                    child: const Icon(Icons.payments_outlined, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  GradientText(
                    '$priceMin - $priceMax',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              textTheme: textTheme,
            ),
            const SizedBox(height: 16),

            // Portfolio
            _buildSection(
              title: 'Portfolio',
              child: InkWell(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.link, color: Colors.blueAccent, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          portfolioLink,
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.blueAccent,
                            decoration: TextDecoration.underline,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.open_in_new, size: 14, color: Colors.white38),
                    ],
                  ),
                ),
              ),
              textTheme: textTheme,
            ),
            const SizedBox(height: 16),

            // Reviews Card
            _buildReviewsCard(context, rating, reviews, textTheme),
            const SizedBox(height: 24),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit Profil'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                debugPrint('Logout button pressed');
                // Force logout flow locally even if server is unreachable
                try {
                  // We attempt a logout but don't block navigation on failure
                  ref.read(authControllerProvider.notifier).logout();
                  
                  // Wait a tiny bit for the state change to propagate
                  await Future.delayed(const Duration(milliseconds: 500));
                  
                  if (context.mounted) {
                    debugPrint('Navigating to landing page...');
                    context.go(PublicHomePage.routePath);
                  }
                } catch (e) {
                  debugPrint('Logout handled with navigation: $e');
                  if (context.mounted) context.go(PublicHomePage.routePath);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                foregroundColor: Colors.redAccent,
                elevation: 0,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.redAccent, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout_rounded, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Keluar (Logout)',
                    style: textTheme.labelLarge?.copyWith(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String name, String city, bool verified, double rating, int reviews, TextTheme textTheme, BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppTheme.highlight, AppTheme.accent],
                ),
              ),
              child: const CircleAvatar(
                radius: 48,
                backgroundColor: Color(0xFF1B0E2A),
                child: Icon(Icons.person_rounded, size: 50, color: Colors.white54),
              ),
            ),
            if (verified)
              Positioned(
                bottom: 0,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified, size: 14, color: Colors.white),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on_outlined, size: 14, color: Colors.white54),
            const SizedBox(width: 4),
            Text(city, style: textTheme.bodyMedium?.copyWith(color: Colors.white54)),
            const SizedBox(width: 16),
            InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TalentReviewsPage())),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '$rating ($reviews ulasan)',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.white54,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required Widget child, required TextTheme textTheme}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16152B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildGenreChip(String label, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        label,
        style: textTheme.bodySmall?.copyWith(color: const Color(0xFFC48DF6)),
      ),
    );
  }

  Widget _buildReviewsCard(BuildContext context, double rating, int reviews, TextTheme textTheme) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TalentReviewsPage())),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF16152B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFB500FF), Color(0xFFDE33A2)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.star_rate_rounded, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Talent Reviews',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      ...List.generate(5, (i) => Icon(
                        i < rating.floor() ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: Colors.amber,
                        size: 14,
                      )),
                      const SizedBox(width: 6),
                      Text(
                        '$rating · $reviews ulasan',
                        style: textTheme.bodySmall?.copyWith(color: Colors.white38),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
          ],
        ),
      ),
    );
  }
}
