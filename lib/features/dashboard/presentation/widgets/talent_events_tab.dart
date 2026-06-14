import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/core/widgets/gradient_text.dart';
import 'package:caritalent_mobile/core/widgets/app_header.dart';
import 'package:caritalent_mobile/features/dashboard/application/dashboard_providers.dart';
import 'package:caritalent_mobile/features/dashboard/domain/event_model.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/widgets/event_map_button.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/widgets/event_location_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

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
  String _searchTitle = '';
  String _minBudget = '';
  String _maxBudget = '';
  String _dateFrom = '';
  String _dateTo = '';

  void _applyFilter({
    required String status,
    required String genre,
    required String city,
    required String searchTitle,
    required String minBudget,
    required String maxBudget,
    required String dateFrom,
    required String dateTo,
  }) {
    ref.read(publicEventsFiltersProvider.notifier).state = PublicEventsFilters(
      status: status == 'Semua Status' ? null : status,
      city: city.isEmpty ? null : city,
      search: searchTitle.isEmpty ? null : searchTitle,
      genre: genre == 'Semua Genre' ? null : genre,
      budgetMin: minBudget.isEmpty
          ? null
          : int.tryParse(minBudget.replaceAll('.', '')),
      budgetMax: maxBudget.isEmpty
          ? null
          : int.tryParse(maxBudget.replaceAll('.', '')),
      dateFrom: dateFrom.isEmpty ? null : dateFrom,
      dateTo: dateTo.isEmpty ? null : dateTo,
    );
    setState(() {
      _status = status;
      _genre = genre;
      _city = city;
      _searchTitle = searchTitle;
      _minBudget = minBudget;
      _maxBudget = maxBudget;
      _dateFrom = dateFrom;
      _dateTo = dateTo;
    });
  }

  int _countEventsByStatus(List<EventModel> events, Set<String> statuses) {
    return events
        .where((event) => statuses.contains(event.status.trim().toLowerCase()))
        .length;
  }

  Widget _buildEventStatusOverview(List<EventModel> events) {
    final opened = _countEventsByStatus(events, {'open', 'dibuka'});
    final closed = _countEventsByStatus(events, {'closed', 'ditutup'});
    final completed = _countEventsByStatus(events, {'completed', 'selesai'});

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _EventStatusInfoChip(
            label: 'Total',
            count: events.length,
            color: const Color(0xFF38BDF8),
          ),
          const SizedBox(width: 8),
          _EventStatusInfoChip(
            label: 'Dibuka',
            count: opened,
            color: Colors.greenAccent,
          ),
          const SizedBox(width: 8),
          _EventStatusInfoChip(
            label: 'Ditutup',
            count: closed,
            color: Colors.redAccent,
          ),
          const SizedBox(width: 8),
          _EventStatusInfoChip(
            label: 'Selesai',
            count: completed,
            color: const Color(0xFFC48DF6),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final searchQuery = ref.watch(eventSearchQueryProvider);
    final eventsAsync = ref.watch(publicEventsProvider);
    final applicationsAsync = ref.watch(myApplicationsProvider);

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
                organizerName: 'Athila Ramdani Saputra',
                title: 'Braga Punk Night Vol.5',
                description:
                    'Malam punk rock bulanan di Kafe Braga Permai. Kami mencari band energetik yang siap mengguncang panggung. Setlist wajib ada cover The Jansen dan Neck Deep.',
                budget: 2000000,
                eventDate: '10 Mei 2026',
                venueName: 'Kafe Braga Permai',
                city: 'Bandung',
                address: 'Jl. Braga No. 58, Sumur Bandung',
                status: 'open',
                genres: ['Pop Punk'],
                totalApplicants: 12,
              ),
              const EventModel(
                id: 2,
                organizerId: 102,
                organizerName: 'Summer Fest EO',
                title: 'Summer Music Festival',
                description:
                    'A celebration of summer with live music, food, and entertainment for all ages.',
                budget: 5000000,
                eventDate: '20 July 2024',
                venueName: 'Central Park',
                city: 'Bandung',
                address: 'Central Park Area, Dago',
                status: 'open',
                genres: ['Pop'],
                totalApplicants: 45,
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
          final appliedEventIds = applicationsAsync.maybeWhen(
            data: (applications) => applications
                .map((application) =>
                    application.eventId ?? application.event?.id)
                .whereType<int>()
                .toSet(),
            orElse: () => <int>{},
          );

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(publicEventsProvider);
              ref.invalidate(myApplicationsProvider);
              
              await Future.wait([
                ref.read(publicEventsProvider.future),
                ref.read(myApplicationsProvider.future),
              ]);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
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
                       const Text('Temukan Peluang',
                          style: TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      GradientText(
                        'Event Saya',
                        style: GoogleFonts.syne(
                          textStyle: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Temukan dan lamar event yang dibuka',
                          style: textTheme.bodySmall
                              ?.copyWith(color: Colors.white38)),
                      const SizedBox(height: 16),
                      _buildEventStatusOverview(allEvents),
                      const SizedBox(height: 24),

                      // Inline Expandable Filter
                      _FilterSection(
                        initialStatus: _status,
                        initialGenre: _genre,
                        initialCity: _city,
                        initialSearchTitle: _searchTitle,
                        initialMinBudget: _minBudget,
                        initialMaxBudget: _maxBudget,
                        initialDateFrom: _dateFrom,
                        initialDateTo: _dateTo,
                        onApply: _applyFilter,
                        onReset: () => _applyFilter(
                          status: 'Semua Status',
                          genre: 'Semua Genre',
                          city: '',
                          searchTitle: '',
                          minBudget: '',
                          maxBudget: '',
                          dateFrom: '',
                          dateTo: '',
                        ),
                      ),
                      const SizedBox(height: 32),

                      Text('Event Dibuka',
                          style: GoogleFonts.syne(
                            textStyle: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          )),
                      const SizedBox(height: 4),
                      Text(
                          'Telusuri event yang tersedia dan lamar yang sesuai dengan keahlian Anda',
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
                          (context, index) {
                            final event = genreFiltered[index];
                            return _EventCard(
                              event: event,
                              isApplied: appliedEventIds.contains(event.id),
                            );
                          },
                          childCount: genreFiltered.length,
                        ),
                      ),
                    ),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
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
}

class _EventStatusInfoChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _EventStatusInfoChip({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        '$label $count',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

typedef _OnApply = void Function({
  required String status,
  required String genre,
  required String city,
  required String searchTitle,
  required String minBudget,
  required String maxBudget,
  required String dateFrom,
  required String dateTo,
});

class _FilterSection extends StatefulWidget {
  final String initialStatus;
  final String initialGenre;
  final String initialCity;
  final String initialSearchTitle;
  final String initialMinBudget;
  final String initialMaxBudget;
  final String initialDateFrom;
  final String initialDateTo;
  final _OnApply onApply;
  final VoidCallback onReset;

  const _FilterSection({
    required this.initialStatus,
    required this.initialGenre,
    required this.initialCity,
    required this.initialSearchTitle,
    required this.initialMinBudget,
    required this.initialMaxBudget,
    required this.initialDateFrom,
    required this.initialDateTo,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<_FilterSection> createState() => _FilterSectionState();
}

class _FilterSectionState extends State<_FilterSection> {
  bool _isExpanded = false;
  late TextEditingController _cityCtrl;
  late TextEditingController _searchTitleCtrl;
  late TextEditingController _minBudgetCtrl;
  late TextEditingController _maxBudgetCtrl;
  late TextEditingController _dateFromCtrl;
  late TextEditingController _dateToCtrl;
  late String _selectedStatus;
  late String _selectedGenre;

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
    _searchTitleCtrl = TextEditingController(text: widget.initialSearchTitle);
    _minBudgetCtrl = TextEditingController(text: widget.initialMinBudget);
    _maxBudgetCtrl = TextEditingController(text: widget.initialMaxBudget);
    _dateFromCtrl = TextEditingController(text: widget.initialDateFrom);
    _dateToCtrl = TextEditingController(text: widget.initialDateTo);
  }

  @override
  void dispose() {
    _cityCtrl.dispose();
    _searchTitleCtrl.dispose();
    _minBudgetCtrl.dispose();
    _maxBudgetCtrl.dispose();
    _dateFromCtrl.dispose();
    _dateToCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFC48DF6),
              onPrimary: Colors.black,
              surface: Color(0xFF1A1A2E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.uiDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.tune_rounded, size: 18, color: Color(0xFFC48DF6)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Filter Events',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                        Text('Saring event sesuai kebutuhanmu.',
                            style: TextStyle(color: Colors.white38, fontSize: 11)),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white54),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Row 1: Search Title
                  _FilterTextField(
                    controller: _searchTitleCtrl,
                    hint: 'Judul event',
                    icon: Icons.search_rounded,
                  ),
                  const SizedBox(height: 12),
                  
                  // Row 2: Genre
                  _FilterDropdown(
                    value: _selectedGenre,
                    items: _genres,
                    onChanged: (v) =>
                        setState(() => _selectedGenre = v ?? 'Semua Genre'),
                  ),
                  const SizedBox(height: 12),

                  // Row 3: City
                  _FilterTextField(
                    controller: _cityCtrl,
                    hint: 'Kota',
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 12),

                  // Row 4: Budget Min & Max
                  Row(
                    children: [
                      Expanded(
                        child: _FilterTextField(
                          controller: _minBudgetCtrl,
                          hint: 'Min budget',
                          icon: Icons.account_balance_wallet_outlined,
                          isNumber: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FilterTextField(
                          controller: _maxBudgetCtrl,
                          hint: 'Max budget',
                          icon: Icons.account_balance_wallet_outlined,
                          isNumber: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Row 5: Date Range
                  Row(
                    children: [
                      Expanded(
                        child: _FilterTextField(
                          controller: _dateFromCtrl,
                          hint: 'Tanggal Dari',
                          icon: Icons.calendar_today_rounded,
                          readOnly: true,
                          onTap: () => _selectDate(context, _dateFromCtrl),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FilterTextField(
                          controller: _dateToCtrl,
                          hint: 'Tanggal Hingga',
                          icon: Icons.calendar_today_rounded,
                          readOnly: true,
                          onTap: () => _selectDate(context, _dateToCtrl),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedStatus = 'Semua Status';
                            _selectedGenre = 'Semua Genre';
                            _cityCtrl.clear();
                            _searchTitleCtrl.clear();
                            _minBudgetCtrl.clear();
                            _maxBudgetCtrl.clear();
                            _dateFromCtrl.clear();
                            _dateToCtrl.clear();
                          });
                          widget.onReset();
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.white54),
                        label: const Text('Reset', style: TextStyle(color: Colors.white54, fontSize: 13)),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => widget.onApply(
                          status: _selectedStatus,
                          genre: _selectedGenre,
                          city: _cityCtrl.text,
                          searchTitle: _searchTitleCtrl.text,
                          minBudget: _minBudgetCtrl.text,
                          maxBudget: _maxBudgetCtrl.text,
                          dateFrom: _dateFromCtrl.text,
                          dateTo: _dateToCtrl.text,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFB500FF), Color(0xFFDE33A2)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.tune_rounded, size: 16, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Terapkan Filter',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
  final bool readOnly;
  final VoidCallback? onTap;

  const _FilterTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.isNumber = false,
    this.readOnly = false,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
        prefixIcon: Icon(icon, size: 16, color: Colors.white38),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
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
  final bool isApplied;

  const _EventCard({
    required this.event,
    required this.isApplied,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

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
                      color: event.statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      event.statusLabel,
                      style: TextStyle(
                          color: event.statusColor,
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
          Text(event.organizerLabel,
              style: const TextStyle(color: Colors.white38, fontSize: 13)),
          const SizedBox(height: 12),

          // Genre Tags
          if (event.genres.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: event.genres.map((genre) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(genre,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 11)),
                );
              }).toList(),
            ),
          const SizedBox(height: 16),

          // Details List
          _buildInfoRow(Icons.calendar_today_outlined, 'Jadwal:', event.eventDate),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildInfoRow(
                  Icons.location_on_outlined,
                  'Lokasi:',
                  '${event.venueName}, ${event.city}',
                ),
              ),
              const SizedBox(width: 8),
              EventMapButton(
                eventName: event.title,
                displayAddress: '${event.venueName}, ${event.city}',
                latitude: event.latitude,
                longitude: event.longitude,
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            event.description,
            style: const TextStyle(color: Colors.white54, fontSize: 13),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),

          // Action Buttons: Detail + Melamar
          Row(
            children: [
              TextButton.icon(
                onPressed: () => _showDetail(context, ref),
                icon: const Icon(Icons.visibility_outlined, size: 18, color: Colors.white70),
                label: const Text('Detail', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.03),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: _ApplyButton(event: event, isApplied: isApplied)),
            ],
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

  void _showDetail(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E), // Dark matching the theme
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('DETAIL EVENT',
                                style: TextStyle(
                                    color: Color(0xFFC48DF6),
                                    fontSize: 10,
                                    letterSpacing: 1.0,
                                    fontWeight: FontWeight.w900)),
                            const SizedBox(height: 8),
                            Text(event.title,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.white54, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      )
                    ],
                  ),
                ),

                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Organizer Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC48DF6).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.business_rounded,
                                    color: Color(0xFFC48DF6), size: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('PENYELENGGARA (EO)',
                                        style: TextStyle(
                                            color: Colors.white38,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(event.organizerLabel,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              _StatusLabel(
                                label: event.statusLabel,
                                color: event.statusColor as Color,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Stats Grid (Budget & Date)
                        Row(
                          children: [
                            Expanded(
                              child: _InfoBox(
                                label: 'ANGGARAN (BUDGET)',
                                value: event.budgetFormatted,
                                valueColor: const Color(0xFFC48DF6),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _InfoBox(
                                label: 'TANGGAL & WAKTU',
                                value: event.eventDate,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        const Text('DESKRIPSI ACARA',
                            style: TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5)),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            event.description,
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                height: 1.5),
                          ),
                        ),

                        const SizedBox(height: 24),

                        const Text('LOKASI & VENUE',
                            style: TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5)),
                        const SizedBox(height: 12),
                        EventLocationPanel(
                          venueName: event.venueName,
                          displayAddress: event.city,
                          latitude: event.latitude,
                          longitude: event.longitude,
                        ),

                        const SizedBox(height: 24),

                        const Text('GENRE YANG DIBUTUHKAN',
                            style: TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5)),
                        const SizedBox(height: 12),
                        if (event.genres.isEmpty)
                          const Text(
                            'Genre belum ditentukan',
                            style: TextStyle(
                                color: Colors.white38, fontSize: 12),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: event.genres.map((genre) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7C3AED)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFF9D7BFF)
                                        .withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Text(
                                  genre,
                                  style: const TextStyle(
                                    color: Color(0xFFC4B5FD),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ),

                // Footer Actions
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(
                            color: Colors.white.withValues(alpha: 0.05))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Tutup',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: isApplied
                            ? const _AppliedBadge(height: 50)
                            : GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  _showApplyModal(context, ref, event);
                                },
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [
                                      Color(0xFF31255A),
                                      Color(0xFF261D41)
                                    ]),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.white
                                            .withValues(alpha: 0.05)),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text('Melamar',
                                      style: TextStyle(
                                          color: Color(0xFFC48DF6),
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Apply Modal ──────────────────────────────────────────────────────────────

void _showApplyModal(BuildContext context, WidgetRef ref, EventModel event) {
  showDialog(
    context: context,
    builder: (context) => _ApplyDialog(event: event),
  );
}

class _ApplyDialog extends ConsumerStatefulWidget {
  final EventModel event;
  const _ApplyDialog({required this.event});

  @override
  ConsumerState<_ApplyDialog> createState() => _ApplyDialogState();
}

class _ApplyDialogState extends ConsumerState<_ApplyDialog> {
  final _messageCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _priceCtrl.text = widget.event.budget.toInt().toString();
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('LAMARAN EVENT',
                          style: TextStyle(
                              color: Colors.white38,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0)),
                      SizedBox(height: 8),
                      Text('Ajukan Lamaran',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white54, size: 20),
                  )
                ],
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Lengkapi pesan dan penawaran terbaikmu.',
                        style: TextStyle(color: Colors.white54, fontSize: 13)),
                    const SizedBox(height: 32),

                    // Message Field
                    _buildLabel('Pesan', required: true),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _messageCtrl,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: _inputDecoration('Ceritakan kenapa kamu cocok untuk event ini...'),
                    ),

                    const SizedBox(height: 24),

                    // Price Field
                    _buildLabel('Harga yang Diajukan (Rp)', required: true),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _priceCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: _inputDecoration('0'),
                    ),
                    const SizedBox(height: 8),
                    const Text('Sertakan detail nilai tambah jika perlu.',
                        style: TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.05))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Batal',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _submitting ? null : _submit,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [
                            Color(0xFFB500FF),
                            Color(0xFFDE33A2)
                          ]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: _submitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text('Kirim Lamaran',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return Row(
      children: [
        Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold)),
        if (required)
          const Text(' *',
              style: TextStyle(color: Colors.redAccent, fontSize: 14)),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.03),
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFC48DF6), width: 1.5),
      ),
    );
  }

  Future<void> _submit() async {
    if (_messageCtrl.text.isEmpty || _priceCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harap lengkapi semua field required')));
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref.read(applicationRepositoryProvider).applyEvent(
            eventId: widget.event.id,
            proposedPrice: double.tryParse(_priceCtrl.text) ?? widget.event.budget,
            message: _messageCtrl.text,
          );
      ref.invalidate(myApplicationsProvider);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Lamaran berhasil dikirim'),
            backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Gagal mengirim lamaran: $e'),
            backgroundColor: Colors.redAccent));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

// ─── Helper Widgets ──────────────────────────────────────────────────────────

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoBox({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 9,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: valueColor ?? Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class _AppliedBadge extends StatelessWidget {
  final double? height;

  const _AppliedBadge({this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withValues(alpha: 0.35)),
      ),
      alignment: Alignment.center,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
          SizedBox(width: 6),
          Text('Sudah dilamar',
              style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ],
      ),
    );
  }
}

class _ApplyButton extends ConsumerWidget {
  final EventModel event;
  final bool isApplied;

  const _ApplyButton({
    required this.event,
    required this.isApplied,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isApplied) {
      return const _AppliedBadge();
    }

    if (event.isClosed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
        ),
        alignment: Alignment.center,
        child: const Text('Event Ditutup',
            style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 13)),
      );
    }

    if (event.isCompleted) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        alignment: Alignment.center,
        child: const Text('Event Selesai',
            style: TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.bold,
                fontSize: 13)),
      );
    }

    return GestureDetector(
      onTap: () => _showApplyModal(context, ref, event),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFB500FF), Color(0xFFDE33A2)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send_outlined, size: 16, color: Colors.white),
            SizedBox(width: 6),
            Text('Melamar Sekarang',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
