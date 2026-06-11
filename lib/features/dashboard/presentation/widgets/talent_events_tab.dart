import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/core/widgets/gradient_text.dart';
import 'package:caritalent_mobile/core/widgets/app_header.dart';
import 'package:caritalent_mobile/features/dashboard/application/dashboard_providers.dart';
import 'package:caritalent_mobile/features/dashboard/domain/event_model.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/widgets/view_location_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

// ─── Main Tab Widget ──────────────────────────────────────────────────────────

class TalentEventsTab extends ConsumerStatefulWidget {
  const TalentEventsTab({super.key});

  @override
  ConsumerState<TalentEventsTab> createState() => _TalentEventsTabState();
}

class _TalentEventsTabState extends ConsumerState<TalentEventsTab> {
  // Filter local state — driven from this form
  String _status = 'Semua Status';
  String _genre = 'Semua Genre';
  String _city = '';
  String _minBudget = '';
  String _maxBudget = '';

  void _applyFilter({
    required String status,
    required String genre,
    required String city,
    required String minBudget,
    required String maxBudget,
  }) {
    ref.read(publicEventsFiltersProvider.notifier).state = PublicEventsFilters(
      status: status == 'Semua Status' ? null : status,
      city: city.isEmpty ? null : city,
      budgetMin: minBudget.isEmpty
          ? null
          : int.tryParse(minBudget.replaceAll('.', '')),
      budgetMax: maxBudget.isEmpty
          ? null
          : int.tryParse(maxBudget.replaceAll('.', '')),
    );
    setState(() {
      _status = status;
      _genre = genre;
      _city = city;
      _minBudget = minBudget;
      _maxBudget = maxBudget;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final searchQuery = ref.watch(eventSearchQueryProvider);
    final eventsAsync = ref.watch(publicEventsProvider);

    return SafeArea(
      child: eventsAsync.when(
        data: (allEventsRaw) {
          // Ensure no null elements just in case the repository returns them
          var allEvents = allEventsRaw.whereType<EventModel>().toList();

          // FOR DEMO: If empty, use mock data to match the design in Image 2
          if (allEvents.isEmpty) {
            allEvents = [
              const EventModel(
                id: 1,
                organizerId: 101,
                title: 'Single Tech Night Vol.4',
                description:
                    'Join us for a night of cutting-edge electronic music and tech house beats.',
                budget: 3000000,
                eventDate: '15 June 2024',
                venueName: 'Venue TBD',
                city: 'Los Angeles',
                status: 'open',
                genres: ['Electronic'],
                totalApplicants: 12,
              ),
              const EventModel(
                id: 2,
                organizerId: 102,
                title: 'Summer Music Festival',
                description:
                    'A celebration of summer with live music, food, and entertainment for all ages.',
                budget: 5000000,
                eventDate: '20 July 2024',
                venueName: 'Central Park',
                city: 'Bandung',
                status: 'open',
                genres: ['Pop'],
                totalApplicants: 45,
              ),
              const EventModel(
                id: 3,
                organizerId: 103,
                title: 'Corporate Annual Gala',
                description:
                    'Annual corporate gala dinner with entertainment and networking.',
                budget: 8000000,
                eventDate: '5 August 2024',
                venueName: 'Grand Hotel Ballroom',
                city: 'Jakarta',
                status: 'open',
                genres: ['Jazz'],
                totalApplicants: 8,
              ),
            ];
          }

          // Additional local search filter
          final displayed = searchQuery.isEmpty
              ? allEvents
              : allEvents.where((e) {
                  final q = searchQuery.toLowerCase();
                  return e.title.toLowerCase().contains(q) ||
                      e.description.toLowerCase().contains(q) ||
                      e.venueName.toLowerCase().contains(q) ||
                      e.city.toLowerCase().contains(q);
                }).toList();

          // Additional genre filter (local, because API might not support it)
          final genreFiltered = _genre == 'Semua Genre'
              ? displayed
              : displayed.where((e) => e.genres.any(
                  (g) => g.toLowerCase() == _genre.toLowerCase())).toList();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppHeader(),
                      const SizedBox(height: 32),
                      const Text('Find Opportunities',
                          style: TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      GradientText(
                        'Browse Events',
                        style: textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5) ??
                            const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      Text('Discover and apply to open events',
                          style: textTheme.bodySmall
                              ?.copyWith(color: Colors.white38)),
                      const SizedBox(height: 24),

                      // Design-matched Filter Bar
                      GestureDetector(
                        onTap: () {
                          // Show filter bottom sheet or navigate
                          _showFilterModal(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.uiDark,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.tune_rounded,
                                  size: 18, color: Color(0xFFC48DF6)),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text('Filter Events',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                              ),
                              const Icon(Icons.chevron_right_rounded,
                                  size: 20, color: Colors.white54),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Open Events',
                              style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          Text('View All',
                              style: textTheme.labelMedium?.copyWith(
                                  color: const Color(0xFFC48DF6),
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                          'Browse through available events and apply to those that match your skills',
                          style: textTheme.bodySmall),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Event List
              genreFiltered.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off_rounded,
                                size: 64, color: AppTheme.neutralMedium),
                            const SizedBox(height: 16),
                            Text('Event tidak ditemukan',
                                style: textTheme.titleMedium
                                    ?.copyWith(color: AppTheme.neutralMedium)),
                            const SizedBox(height: 8),
                            Text('Coba ubah filter pencarian',
                                style: textTheme.bodySmall
                                    ?.copyWith(color: Colors.white38)),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                              _EventCard(event: genreFiltered[index]),
                          childCount: genreFiltered.length,
                        ),
                      ),
                    ),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              Text('Gagal memuat events: $e',
                  style: const TextStyle(color: Colors.white54)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(publicEventsProvider),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterSection(
        initialStatus: _status,
        initialGenre: _genre,
        initialCity: _city,
        initialMinBudget: _minBudget,
        initialMaxBudget: _maxBudget,
        onApply: _applyFilter,
        onReset: () => _applyFilter(
          status: 'Semua Status',
          genre: 'Semua Genre',
          city: '',
          minBudget: '',
          maxBudget: '',
        ),
      ),
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}

// ─── Filter Section ───────────────────────────────────────────────────────────

typedef _OnApply = void Function({
  required String status,
  required String genre,
  required String city,
  required String minBudget,
  required String maxBudget,
});

class _FilterSection extends StatefulWidget {
  final String initialStatus;
  final String initialGenre;
  final String initialCity;
  final String initialMinBudget;
  final String initialMaxBudget;
  final _OnApply onApply;
  final VoidCallback onReset;

  const _FilterSection({
    required this.initialStatus,
    required this.initialGenre,
    required this.initialCity,
    required this.initialMinBudget,
    required this.initialMaxBudget,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<_FilterSection> createState() => _FilterSectionState();
}

class _FilterSectionState extends State<_FilterSection> {
  bool _isExpanded = true;
  late TextEditingController _cityCtrl;
  late TextEditingController _minBudgetCtrl;
  late TextEditingController _maxBudgetCtrl;
  late String _selectedStatus;
  late String _selectedGenre;

  static const _statuses = ['Semua Status', 'Dibuka', 'Ditutup'];
  static const _genres = [
    'Semua Genre',
    'Rock',
    'Jazz',
    'Pop',
    'Electronic',
    'Indie',
    'Folk',
    'Classical',
    'Acoustic',
    'Hip-Hop',
    'R&B',
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus;
    _selectedGenre = widget.initialGenre;
    _cityCtrl = TextEditingController(text: widget.initialCity);
    _minBudgetCtrl = TextEditingController(text: widget.initialMinBudget);
    _maxBudgetCtrl = TextEditingController(text: widget.initialMaxBudget);
  }

  @override
  void dispose() {
    _cityCtrl.dispose();
    _minBudgetCtrl.dispose();
    _maxBudgetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.tune_rounded,
                      size: 18, color: Color(0xFFC48DF6)),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Filter Events',
                          style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Text('Saring event sesuai kebutuhanmu.',
                          style: textTheme.labelSmall
                              ?.copyWith(color: Colors.white54)),
                    ],
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.white54),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 280),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _FilterDropdown(
                          value: _selectedStatus,
                          items: _statuses,
                          onChanged: (v) =>
                              setState(() => _selectedStatus = v ?? 'Semua Status'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _FilterDropdown(
                          value: _selectedGenre,
                          items: _genres,
                          onChanged: (v) =>
                              setState(() => _selectedGenre = v ?? 'Semua Genre'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _FilterTextField(
                    controller: _cityCtrl,
                    hint: 'Kota',
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _FilterTextField(
                          controller: _minBudgetCtrl,
                          hint: 'Min budget',
                          icon: Icons.money_outlined,
                          isNumber: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _FilterTextField(
                          controller: _maxBudgetCtrl,
                          hint: 'Max budget',
                          icon: Icons.money_outlined,
                          isNumber: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedStatus = 'Semua Status';
                            _selectedGenre = 'Semua Genre';
                            _cityCtrl.clear();
                            _minBudgetCtrl.clear();
                            _maxBudgetCtrl.clear();
                          });
                          widget.onReset();
                        },
                        icon: const Icon(Icons.refresh_rounded,
                            size: 16, color: Colors.white54),
                        label: const Text('Reset',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 13)),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => widget.onApply(
                          status: _selectedStatus,
                          genre: _selectedGenre,
                          city: _cityCtrl.text,
                          minBudget: _minBudgetCtrl.text,
                          maxBudget: _maxBudgetCtrl.text,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFB500FF), Color(0xFFDE33A2)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.tune_rounded,
                                  size: 15, color: Colors.white),
                              SizedBox(width: 6),
                              Text('Terapkan Filter',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
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
        ],
      ),
    );
  }
}

// ─── Filter Input Helpers ─────────────────────────────────────────────────────

class _FilterTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isNumber;

  const _FilterTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.isNumber = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters:
          isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
        prefixIcon: Icon(icon, size: 16, color: Colors.white38),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFFB500FF), width: 1.5),
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: const Color(0xFF1A1A2E),
        style: const TextStyle(color: Colors.white, fontSize: 13),
        icon: const Icon(Icons.keyboard_arrow_down_rounded,
            color: Colors.white54, size: 18),
        items: items
            .map((s) => DropdownMenuItem(
                  value: s,
                  child: Text(s,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13)),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

// ─── Event Card ───────────────────────────────────────────────────────────────

class _EventCard extends ConsumerWidget {
  final EventModel event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final isClosed = !event.isOpen;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.uiDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title + Price + Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(event.title,
                    style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      event.statusLabel,
                      style: const TextStyle(
                          color: Color(0xFF4CAF50),
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(event.budgetFormatted,
                      style: const TextStyle(
                          color: Color(0xFFC48DF6),
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Organizer',
              style: TextStyle(color: Colors.white38, fontSize: 13)),
          const SizedBox(height: 12),

          // Genre Tag
          if (event.genres.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(event.genres.first,
                  style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ),
          const SizedBox(height: 16),

          // Details List
          _buildInfoRow(Icons.calendar_today_outlined, 'Jadwal:', event.eventDate),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on_outlined, 'Lokasi:',
              '${event.venueName}, ${event.city}'),
          const SizedBox(height: 16),

          Text(
            event.description,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),

          // Action Button
          Align(
            alignment: Alignment.centerRight,
            child: _ApplyButton(event: event),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white54),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(value,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class _ApplyButton extends ConsumerStatefulWidget {
  final EventModel event;
  const _ApplyButton({required this.event});

  @override
  ConsumerState<_ApplyButton> createState() => _ApplyButtonState();
}

class _ApplyButtonState extends ConsumerState<_ApplyButton> {
  bool _loading = false;
  bool _applied = false;

  @override
  Widget build(BuildContext context) {
    if (_applied) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        ),
        alignment: Alignment.center,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
                color: Colors.green, size: 16),
            SizedBox(width: 6),
            Text('Lamaran Dikirim',
                style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: _loading ? null : () => _apply(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFB500FF), Color(0xFFDE33A2)],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: _loading
            ? const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send_outlined, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  const Text('Swaftu Sekarang',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                ],
              ),
      ),
    );
  }

  Future<void> _apply() async {
    setState(() => _loading = true);
    try {
      await ref.read(applicationRepositoryProvider).applyEvent(
            eventId: widget.event.id,
            proposedPrice: widget.event.budget,
          );
      if (mounted) setState(() => _applied = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal melamar: $e'),
          backgroundColor: Colors.redAccent,
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
