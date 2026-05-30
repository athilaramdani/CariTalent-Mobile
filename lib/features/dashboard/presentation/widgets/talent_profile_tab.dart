import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/features/auth/application/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:caritalent_mobile/core/widgets/gradient_text.dart';
import 'package:caritalent_mobile/core/widgets/app_header.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/pages/talent_reviews_page.dart';

class TalentProfileTab extends ConsumerWidget {
  const TalentProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final user = ref.watch(authControllerProvider).user;

    // Mock data based on GET /talents/my API Spec
    final stageName = user?.name ?? 'Talent';
    final city = 'Bandung';
    final bio = 'Band pop punk asal Bandung dengan 5 tahun pengalaman di berbagai event lokal maupun nasional.';
    final genres = ['Pop Punk', 'Alternative Rock'];
    final priceMin = 'Rp 1.000.000';
    final priceMax = 'Rp 3.000.000';
    final portfolioLink = 'https://youtube.com/thebrokenstrings';
    final isVerified = true;
    final rating = 4.8;
    final reviews = 12;

    return Scaffold(
      backgroundColor: AppTheme.neutralDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── App Header ──
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: AppHeader(),
              ),

              // Header Profile
              Container(
              color: AppTheme.uiDark,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.neutralDark,
                          border: Border.all(color: AppTheme.highlight, width: 2),
                        ),
                        child: const Center(
                          child: Icon(Icons.person, size: 50, color: AppTheme.neutralMedium),
                        ),
                      ),
                      if (isVerified)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.verified, size: 16, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    stageName,
                    style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, size: 14, color: AppTheme.neutralMedium),
                      const SizedBox(width: 4),
                      Text(city, style: textTheme.bodyMedium?.copyWith(color: AppTheme.neutralMedium)),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const TalentReviewsPage()));
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.star, size: 14, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text('$rating ($reviews ulasan)', style: textTheme.bodyMedium?.copyWith(color: AppTheme.neutralMedium, decoration: TextDecoration.underline)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Info Section
            Container(
              color: AppTheme.uiDark,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Bio', textTheme),
                  Text(
                    bio,
                    style: textTheme.bodyMedium?.copyWith(color: AppTheme.neutralMedium, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('Genre', textTheme),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: genres.map((genre) => _buildGenreChip(genre, textTheme)).toList(),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('Tarif Harga (Range)', textTheme),
                  Row(
                    children: [
                      const Icon(Icons.payments_outlined, color: AppTheme.highlight),
                      const SizedBox(width: 12),
                      Text(
                        '$priceMin - $priceMax',
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.highlight),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  _buildSectionTitle('Portfolio', textTheme),
                  InkWell(
                    onTap: () {
                      // TODO: Implement portfolio link launching
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.neutralDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.link, color: Colors.blue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              portfolioLink,
                              style: textTheme.bodyMedium?.copyWith(color: Colors.blue, decoration: TextDecoration.underline),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.open_in_new, size: 16, color: AppTheme.neutralMedium),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Talent Reviews Card (Entry Point) ──
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TalentReviewsPage()));
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 0),
                color: AppTheme.uiDark,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  children: [
                    // Icon gradient box
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB500FF), Color(0xFFDE33A2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.star_rate_outlined, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 16),
                    // Text info
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
                              ...List.generate(
                                5,
                                (i) => Icon(
                                  i < rating.floor() ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 12,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$rating · $reviews ulasan',
                                style: textTheme.bodySmall?.copyWith(color: AppTheme.neutralMedium),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Arrow
                    const Icon(Icons.arrow_forward_ios, color: AppTheme.neutralMedium, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(24.0),
              color: AppTheme.uiDark,
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profil'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: AppTheme.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {
                        ref.read(authControllerProvider.notifier).logout();
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Keluar (Logout)'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildGenreChip(String label, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.neutralDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Text(
        label,
        style: textTheme.bodySmall?.copyWith(color: AppTheme.neutralMedium),
      ),
    );
  }
}
