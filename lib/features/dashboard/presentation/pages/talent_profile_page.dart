import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/core/widgets/gradient_text.dart';
import 'package:caritalent_mobile/features/auth/application/auth_controller.dart';
import 'package:caritalent_mobile/features/dashboard/application/dashboard_providers.dart';
import 'package:caritalent_mobile/features/dashboard/domain/talent_model.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/pages/talent_change_password_page.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/pages/talent_edit_profile_page.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/pages/talent_reviews_page.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/widgets/profile_logout_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TalentProfilePage extends ConsumerWidget {
  const TalentProfilePage({super.key});

  static const routePath = '/talent-profile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final talentAsync = ref.watch(myTalentProvider);

    return Scaffold(
      backgroundColor: AppTheme.uiDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Profil Talent',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: talentAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.highlight),
        ),
        error: (e, _) => _buildErrorState(context, ref, e.toString()),
        data: (talent) =>
            _buildContent(context, ref, user, talent),
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Gagal memuat profil',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style:
                  const TextStyle(color: Colors.white54, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(myTalentProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.highlight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref,
      dynamic user, TalentModel talent) {
    final displayName = talent.fullName ?? user?.name ?? 'Talent';
    final email = talent.email ?? user?.email ?? '-';
    final phone = talent.phone ?? user?.phone ?? '-';
    final initials =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'T';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // ─── Profile Card ────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF16152B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.07)),
            ),
            child: Column(
              children: [
                // Avatar
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
                      child: CircleAvatar(
                        radius: 42,
                        backgroundColor: const Color(0xFF1B0E2A),
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                        ),
                      ),
                    ),
                    if (talent.verified)
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.verified,
                              size: 14, color: Colors.white),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 13),
                ),
                const SizedBox(height: 4),
                GradientText(
                  phone,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                if (talent.verified) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border:
                          Border.all(color: Colors.green.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, color: Colors.green, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'Terverifikasi',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // Edit Profil Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        context.push(TalentEditProfilePage.routePath),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit Profil'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.2)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ─── Talent Info Summary ─────────────────────────────────────
          _buildInfoCard(
            children: [
              _buildInfoRow(
                  icon: Icons.badge_outlined,
                  label: 'Nama Panggung',
                  value: talent.stageName.isNotEmpty
                      ? talent.stageName
                      : '-'),
              const Divider(color: Colors.white12),
              _buildInfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Kota',
                  value:
                      talent.city.isNotEmpty ? talent.city : '-'),
              const Divider(color: Colors.white12),
              _buildVerificationRow(talent.verified),
              if (talent.genre.isNotEmpty) ...[
                const Divider(color: Colors.white12),
                _buildGenreRow(talent.genre),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // ─── Harga ───────────────────────────────────────────────────
          if (talent.priceMin != null || talent.priceMax != null)
            _buildInfoCard(
              children: [
                _buildPriceRow(talent),
              ],
            ),
          if (talent.priceMin != null || talent.priceMax != null)
            const SizedBox(height: 16),

          // ─── Bio ─────────────────────────────────────────────────────
          if (talent.bio != null && talent.bio!.isNotEmpty)
            _buildInfoCard(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.article_outlined,
                        color: Color(0xFFC48DF6), size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bio',
                            style: TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            talent.bio!,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          if (talent.bio != null && talent.bio!.isNotEmpty)
            const SizedBox(height: 16),

          // ─── Portfolio ───────────────────────────────────────────────
          if (talent.portfolioLink != null &&
              talent.portfolioLink!.isNotEmpty)
            _buildInfoCard(
              children: [
                _buildInfoRow(
                    icon: Icons.link,
                    label: 'Portofolio',
                    value: talent.portfolioLink!,
                    isLink: true),
              ],
            ),
          if (talent.portfolioLink != null &&
              talent.portfolioLink!.isNotEmpty)
            const SizedBox(height: 16),

          // ─── Rating & Reviews Card ───────────────────────────────────
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const TalentReviewsPage()),
            ),
            borderRadius: BorderRadius.circular(16),
            child: _buildInfoCard(
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFB500FF),
                            Color(0xFFDE33A2)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.star_rate_rounded,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rating & Ulasan',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              ...List.generate(
                                  5,
                                  (i) => Icon(
                                        i <
                                                talent.averageRating
                                                    .floor()
                                            ? Icons.star_rounded
                                            : Icons
                                                .star_outline_rounded,
                                        color: Colors.amber,
                                        size: 14,
                                      )),
                              const SizedBox(width: 6),
                              Text(
                                '${talent.averageRating.toStringAsFixed(1)} · ${talent.totalReviews} ulasan',
                                style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        color: Colors.white24, size: 14),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ─── Keamanan Akun ───────────────────────────────────────────
          _buildInfoCard(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline,
                        color: Color(0xFFC48DF6), size: 18),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Keamanan Akun',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Ubah password untuk menjaga keamanan akun kamu',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'PASSWORD SAAT INI',
                style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                '● ● ● ● ● ● ● ●',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFB500FF), Color(0xFFE94057)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () => context
                        .push(TalentChangePasswordPage.routePath),
                    icon: const Icon(Icons.lock_reset,
                        color: Colors.white, size: 18),
                    label: const Text(
                      'Ubah Password',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ─── Logout ──────────────────────────────────────────────────
          const ProfileLogoutButton(
            dashboardName: 'Talent Dashboard',
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF16152B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isLink = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFC48DF6), size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: isLink ? Colors.blueAccent : Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  decoration: isLink
                      ? TextDecoration.underline
                      : TextDecoration.none,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGenreRow(List<String> genres) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.music_note_outlined,
            color: Color(0xFFC48DF6), size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'GENRE',
                style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: genres.map((g) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB500FF)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFFB500FF)
                              .withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      g,
                      style: const TextStyle(
                          color: Color(0xFFC48DF6),
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationRow(bool verified) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.verified_user_outlined,
            color: Color(0xFFC48DF6), size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'VERIFIKASI',
                style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: verified
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: verified
                        ? Colors.green.withValues(alpha: 0.3)
                        : Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  verified ? 'Terverifikasi' : 'Belum Verifikasi',
                  style: TextStyle(
                    color: verified ? Colors.green : Colors.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(TalentModel talent) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppTheme.highlight, AppTheme.accent],
          ).createShader(bounds),
          child: const Icon(Icons.payments_outlined,
              color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TARIF HARGA (RANGE)',
                style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8),
              ),
              const SizedBox(height: 6),
              GradientText(
                talent.priceRangeFormatted,
                style: const TextStyle(
                    fontWeight: FontWeight.w900, fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
