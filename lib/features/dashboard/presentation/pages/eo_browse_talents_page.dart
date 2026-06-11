import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/core/widgets/app_card.dart';
import 'package:caritalent_mobile/core/widgets/gradient_text.dart';
import 'package:caritalent_mobile/features/dashboard/application/dashboard_providers.dart';
import 'package:caritalent_mobile/features/dashboard/domain/talent_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EoBrowseTalentsPage extends ConsumerStatefulWidget {
  const EoBrowseTalentsPage({super.key});

  static const routePath = '/eo/browse-talents';

  @override
  ConsumerState<EoBrowseTalentsPage> createState() =>
      _EoBrowseTalentsPageState();
}

class _EoBrowseTalentsPageState extends ConsumerState<EoBrowseTalentsPage> {
  final _searchController = TextEditingController();
  final _cityController = TextEditingController();
  String? _selectedGenre;

  static const _genres = [
    'Semua',
    'Pop',
    'Jazz',
    'Rock',
    'R&B',
    'Classical',
    'Electronic',
    'Hip-Hop',
    'Folk',
    'Indie',
    'Dangdut',
    'Traditional',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    ref.read(talentListFiltersProvider.notifier).state = TalentListFilters(
      search: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
      city: _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim(),
      genre: (_selectedGenre == null || _selectedGenre == 'Semua')
          ? null
          : _selectedGenre,
    );
  }

  void _clearFilters() {
    _searchController.clear();
    _cityController.clear();
    setState(() => _selectedGenre = null);
    ref.read(talentListFiltersProvider.notifier).state =
        const TalentListFilters();
  }

  @override
  Widget build(BuildContext context) {
    final talentsAsync = ref.watch(talentListProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.neutralDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_back_ios,
                            color: Color(0xFFD8B4FE), size: 18),
                        SizedBox(width: 4),
                        Text(
                          'Kembali',
                          style: TextStyle(
                              color: Color(0xFFD8B4FE),
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _clearFilters,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Reset Filter',
                          style:
                              TextStyle(color: Colors.white54, fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const GradientText(
                    'Browse Talent',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Temukan talent terbaik untuk event kamu',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),

                  // Search bar
                  _buildSearchField(
                    controller: _searchController,
                    hint: 'Cari nama talent...',
                    icon: Icons.search,
                    onChanged: (_) => _applyFilters(),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildSearchField(
                          controller: _cityController,
                          hint: 'Filter kota...',
                          icon: Icons.location_city_outlined,
                          onChanged: (_) => _applyFilters(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildGenreDropdown(textTheme),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            Expanded(
              child: talentsAsync.when(
                data: (talents) {
                  if (talents.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person_search_outlined,
                                size: 60, color: Colors.white24),
                            const SizedBox(height: 20),
                            Text('Tidak ada talent ditemukan',
                                style: textTheme.bodyLarge
                                    ?.copyWith(color: Colors.white38)),
                            const SizedBox(height: 8),
                            Text('Coba ubah filter pencarian',
                                style: textTheme.bodyMedium
                                    ?.copyWith(color: Colors.white24)),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Text('${talents.length} talent ditemukan',
                                style: textTheme.bodySmall?.copyWith(
                                    color: Colors.white54,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 4),
                          itemCount: talents.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (_, i) =>
                              _TalentBrowseCard(talent: talents[i]),
                        ),
                      ),
                    ],
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.redAccent, size: 48),
                        const SizedBox(height: 16),
                        Text('Gagal memuat talent: $e',
                            style: const TextStyle(color: Colors.white54),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              ref.invalidate(talentListProvider),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
          prefixIcon: Icon(icon, color: Colors.white38, size: 18),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildGenreDropdown(TextTheme textTheme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedGenre ?? 'Semua',
          isExpanded: true,
          dropdownColor: const Color(0xFF1E1A2E),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Colors.white38, size: 18),
          hint: const Text('Genre',
              style: TextStyle(color: Colors.white38, fontSize: 13)),
          items: _genres
              .map((g) => DropdownMenuItem(
                    value: g,
                    child: Text(g,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13)),
                  ))
              .toList(),
          onChanged: (val) {
            setState(() => _selectedGenre = val);
            _applyFilters();
          },
        ),
      ),
    );
  }
}

// ─── Talent Browse Card ───────────────────────────────────────────────────────

class _TalentBrowseCard extends StatelessWidget {
  final TalentModel talent;

  const _TalentBrowseCard({required this.talent});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    talent.stageName.isNotEmpty
                        ? talent.stageName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            talent.stageName,
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFD8B4FE)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (talent.verified) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: Colors.green.withValues(alpha: 0.4)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified,
                                    color: Colors.green, size: 10),
                                SizedBox(width: 3),
                                Text('VERIFIED',
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            color: Colors.white38, size: 13),
                        const SizedBox(width: 3),
                        Text(
                            talent.city.isNotEmpty
                                ? talent.city
                                : 'Lokasi tidak diketahui',
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 12)),
                        const SizedBox(width: 12),
                        const Icon(Icons.star,
                            color: Colors.orangeAccent, size: 13),
                        const SizedBox(width: 3),
                        Text(
                          talent.averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        Text('(${talent.totalReviews})',
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Genres
          if (talent.genre.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: talent.genre
                    .take(4)
                    .map((g) => Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
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

          if (talent.bio != null && talent.bio!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              talent.bio!,
              style: const TextStyle(
                  color: Colors.white54, fontSize: 12, height: 1.5),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 12),
          Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ESTIMASI TARIF',
                      style: TextStyle(
                          color: Colors.white38,
                          fontSize: 9,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    talent.priceRangeFormatted,
                    style: const TextStyle(
                        color: Color(0xFFE879F9),
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (talent.portfolioLink != null &&
                  talent.portfolioLink!.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: const Color(0xFFD8B4FE).withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.open_in_new,
                          color: Color(0xFFD8B4FE), size: 13),
                      SizedBox(width: 6),
                      Text('Portfolio',
                          style: TextStyle(
                              color: Color(0xFFD8B4FE),
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
