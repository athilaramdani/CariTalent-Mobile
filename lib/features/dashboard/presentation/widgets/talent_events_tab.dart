import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/core/widgets/gradient_text.dart';
import 'package:caritalent_mobile/core/widgets/app_header.dart';
import 'package:caritalent_mobile/features/dashboard/application/dashboard_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Data model ───────────────────────────────────────────────────────────────

class _EventItem {
  final String title;
  final String description;
  final String budgetRaw; // numeric string e.g. "3000000"
  final String date;
  final String venue;
  final String city;
  final String status;
  final String genre;
  final int totalApplicants;

  const _EventItem({
    required this.title,
    required this.description,
    required this.budgetRaw,
    required this.date,
    required this.venue,
    required this.city,
    required this.status,
    required this.genre,
    required this.totalApplicants,
  });

  String get budgetFormatted {
    final n = int.tryParse(budgetRaw) ?? 0;
    // simple thousand-separator
    final s = n.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return 'Rp $s';
  }

  DateTime? get parsedDate {
    try {
      final parts = date.split(' ');
      const months = {
        'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4,
        'Mei': 5, 'Jun': 6, 'Jul': 7, 'Agu': 8,
        'Sep': 9, 'Okt': 10, 'Nov': 11, 'Des': 12,
        'May': 5, 'Aug': 8, 'Oct': 10, 'Dec': 12,
      };
      return DateTime(
        int.parse(parts[2]),
        months[parts[1]] ?? 1,
        int.parse(parts[0]),
      );
    } catch (_) {
      return null;
    }
  }
}

// ─── Static event list ────────────────────────────────────────────────────────

const List<_EventItem> _allEvents = [
  _EventItem(
    title: 'Punk Night Vol. 3',
    description: 'Malam punk rock terbaik di Bandung. Membutuhkan band pembuka beraliran punk/rock.',
    budgetRaw: '3000000',
    date: '15 Apr 2026',
    venue: 'Kafe Kota Bandung',
    city: 'Bandung',
    status: 'Dibuka',
    genre: 'Rock',
    totalApplicants: 12,
  ),
  _EventItem(
    title: 'Braga Jazz Evening',
    description: 'Acara musik jazz mingguan di jalan Braga. Mencari band akustik atau penyanyi solo.',
    budgetRaw: '1500000',
    date: '12 Mar 2025',
    venue: 'Braga Art Square',
    city: 'Bandung',
    status: 'Dibuka',
    genre: 'Jazz',
    totalApplicants: 5,
  ),
  _EventItem(
    title: 'Konser Amal Tahunan',
    description: 'Konser penggalangan dana untuk panti asuhan. Kuota talent sudah penuh.',
    budgetRaw: '5000000',
    date: '01 Jun 2025',
    venue: 'Gedung Sate',
    city: 'Bandung',
    status: 'Ditutup',
    genre: 'Pop',
    totalApplicants: 24,
  ),
  _EventItem(
    title: 'Jakarta EDM Festival',
    description: 'Festival musik elektronik terbesar di Jakarta. Mencari DJ dan performer elektronik.',
    budgetRaw: '8000000',
    date: '20 Jul 2026',
    venue: 'JIExpo Kemayoran',
    city: 'Jakarta',
    status: 'Dibuka',
    genre: 'Electronic',
    totalApplicants: 38,
  ),
  _EventItem(
    title: 'Indie Vibes Yogya',
    description: 'Panggung musik indie lokal Yogyakarta. Terbuka untuk band indie dan folk.',
    budgetRaw: '2000000',
    date: '05 Aug 2026',
    venue: 'Parkir Selatan Prambanan',
    city: 'Yogyakarta',
    status: 'Dibuka',
    genre: 'Indie',
    totalApplicants: 9,
  ),
];

// ─── Main Tab Widget ──────────────────────────────────────────────────────────

class TalentEventsTab extends ConsumerStatefulWidget {
  const TalentEventsTab({super.key});

  @override
  ConsumerState<TalentEventsTab> createState() => _TalentEventsTabState();
}

class _TalentEventsTabState extends ConsumerState<TalentEventsTab> {
  List<_EventItem> _filteredEvents = _allEvents;

  void _applyFilter({
    required String title,
    required String status,
    required String genre,
    required String city,
    required String minBudget,
    required String maxBudget,
    required DateTime? startDate,
    required DateTime? endDate,
  }) {
    setState(() {
      _filteredEvents = _allEvents.where((e) {
        if (title.isNotEmpty &&
            !e.title.toLowerCase().contains(title.toLowerCase())) return false;
        if (status != 'Semua Status' && e.status != status) return false;
        if (genre != 'Semua Genre' && e.genre != genre) return false;
        if (city.isNotEmpty &&
            !e.city.toLowerCase().contains(city.toLowerCase())) return false;
        final budget = int.tryParse(e.budgetRaw) ?? 0;
        final min = int.tryParse(minBudget.replaceAll('.', ''));
        final max = int.tryParse(maxBudget.replaceAll('.', ''));
        if (min != null && budget < min) return false;
        if (max != null && budget > max) return false;
        final d = e.parsedDate;
        if (d != null && startDate != null && d.isBefore(startDate)) return false;
        if (d != null && endDate != null && d.isAfter(endDate)) return false;
        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Also honour global search query
    final searchQuery = ref.watch(eventSearchQueryProvider);
    final displayed = searchQuery.isEmpty
        ? _filteredEvents
        : _filteredEvents.where((e) {
            final q = searchQuery.toLowerCase();
            return e.title.toLowerCase().contains(q) ||
                e.description.toLowerCase().contains(q) ||
                e.venue.toLowerCase().contains(q) ||
                e.city.toLowerCase().contains(q);
          }).toList();

    final openCount = displayed.where((e) => e.status == 'Dibuka').length;
    final closedCount = displayed.where((e) => e.status == 'Ditutup').length;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── App Header ──
                  const AppHeader(),
                  const SizedBox(height: 32),

                  // ── Page Title ──
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
                        const TextStyle(),
                  ),
                  const SizedBox(height: 8),

                  // ── Status Badges + Total ──
                  Row(
                    children: [
                      _StatusBadge(
                          label: 'Open $openCount',
                          color: const Color(0xFF4CAF50)),
                      const SizedBox(width: 8),
                      _StatusBadge(
                          label: 'Closed $closedCount',
                          color: const Color(0xFFEF5350)),
                      const Spacer(),
                      Text('${displayed.length} Total',
                          style: textTheme.labelSmall
                              ?.copyWith(color: Colors.white54)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Filter Panel ──
                  _FilterSection(onApply: _applyFilter),
                  const SizedBox(height: 24),

                  // ── List Header ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Available Events',
                          style: textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
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

          // ── Event List ──
          displayed.isEmpty
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
                          _EventCard(event: displayed[index]),
                      childCount: displayed.length,
                    ),
                  ),
                ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
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
  required String title,
  required String status,
  required String genre,
  required String city,
  required String minBudget,
  required String maxBudget,
  required DateTime? startDate,
  required DateTime? endDate,
});

class _FilterSection extends StatefulWidget {
  final _OnApply onApply;
  const _FilterSection({required this.onApply});

  @override
  State<_FilterSection> createState() => _FilterSectionState();
}

class _FilterSectionState extends State<_FilterSection> {
  bool _isExpanded = true;

  final _titleCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _minBudgetCtrl = TextEditingController();
  final _maxBudgetCtrl = TextEditingController();

  String _selectedStatus = 'Semua Status';
  String _selectedGenre = 'Semua Genre';
  DateTime? _startDate;
  DateTime? _endDate;

  static const _statuses = ['Semua Status', 'Dibuka', 'Ditutup'];
  static const _genres = [
    'Semua Genre', 'Rock', 'Jazz', 'Pop', 'Electronic', 'Indie', 'Folk', 'Classical'
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _cityCtrl.dispose();
    _minBudgetCtrl.dispose();
    _maxBudgetCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFB500FF),
            onPrimary: Colors.white,
            surface: Color(0xFF1A1A2E),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) _startDate = picked;
        else _endDate = picked;
      });
    }
  }

  void _resetFilter() {
    setState(() {
      _titleCtrl.clear();
      _cityCtrl.clear();
      _minBudgetCtrl.clear();
      _maxBudgetCtrl.clear();
      _selectedStatus = 'Semua Status';
      _selectedGenre = 'Semua Genre';
      _startDate = null;
      _endDate = null;
    });
    widget.onApply(
      title: '', status: 'Semua Status', genre: 'Semua Genre',
      city: '', minBudget: '', maxBudget: '',
      startDate: null, endDate: null,
    );
  }

  String _fmt(DateTime? d) {
    if (d == null) return 'dd/mm/yyyy';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
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
          // ── Header ──
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

          // ── Divider ──
          if (_isExpanded)
            Divider(
                height: 1,
                color: Colors.white.withValues(alpha: 0.08)),

          // ── Form ──
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
                  // Row 1: Title | Status
                  Row(
                    children: [
                      Expanded(
                        child: _FilterTextField(
                          controller: _titleCtrl,
                          hint: 'Judul event',
                          icon: Icons.search_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _FilterDropdown(
                          value: _selectedStatus,
                          items: _statuses,
                          onChanged: (v) =>
                              setState(() => _selectedStatus = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Row 2: Genre | City
                  Row(
                    children: [
                      Expanded(
                        child: _FilterDropdown(
                          value: _selectedGenre,
                          items: _genres,
                          onChanged: (v) =>
                              setState(() => _selectedGenre = v!),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _FilterTextField(
                          controller: _cityCtrl,
                          hint: 'Kota',
                          icon: Icons.location_on_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Row 3: Min Budget | Max Budget
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
                  const SizedBox(height: 10),

                  // Row 4: Start Date | End Date
                  Row(
                    children: [
                      Expanded(
                        child: _DatePickerField(
                          label: _fmt(_startDate),
                          onTap: () => _pickDate(true),
                          isSet: _startDate != null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DatePickerField(
                          label: _fmt(_endDate),
                          onTap: () => _pickDate(false),
                          isSet: _endDate != null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Row 5: Reset | Apply
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Reset button
                      TextButton.icon(
                        onPressed: _resetFilter,
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
                      // Apply button
                      GestureDetector(
                        onTap: () => widget.onApply(
                          title: _titleCtrl.text,
                          status: _selectedStatus,
                          genre: _selectedGenre,
                          city: _cityCtrl.text,
                          minBudget: _minBudgetCtrl.text,
                          maxBudget: _maxBudgetCtrl.text,
                          startDate: _startDate,
                          endDate: _endDate,
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

// ─── Filter Input helpers ──────────────────────────────────────────────────────

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
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
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

class _DatePickerField extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isSet;

  const _DatePickerField({
    required this.label,
    required this.onTap,
    required this.isSet,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSet
                ? const Color(0xFFB500FF).withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 14,
                color: isSet ? const Color(0xFFC48DF6) : Colors.white38),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSet ? Colors.white : Colors.white38,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Event Card ───────────────────────────────────────────────────────────────

class _EventCard extends StatelessWidget {
  final _EventItem event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isClosed = event.status.toLowerCase() == 'ditutup';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.uiDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title,
                        style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('Organizer',
                        style: textTheme.bodySmall
                            ?.copyWith(color: Colors.white54)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Text(event.genre,
                          style: textTheme.labelSmall
                              ?.copyWith(color: Colors.white70)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isClosed
                          ? Colors.red.withValues(alpha: 0.15)
                          : Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isClosed ? 'Closed' : 'Open',
                      style: textTheme.labelSmall?.copyWith(
                          color: isClosed ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(event.budgetFormatted,
                      style: textTheme.titleSmall?.copyWith(
                          color: const Color(0xFFC48DF6),
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: Colors.white54),
              const SizedBox(width: 8),
              Text('Jadwal: ',
                  style: textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Text(event.date, style: textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.location_on_outlined,
                    size: 14, color: Colors.white54),
              ),
              const SizedBox(width: 8),
              Text('Lokasi: ',
                  style: textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Expanded(
                child: Text('${event.venue}, ${event.city}',
                    style: textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(event.description,
              style: textTheme.bodySmall
                  ?.copyWith(height: 1.5, color: Colors.white70),
              maxLines: 3,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: isClosed ? null : () {},
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: isClosed
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFFB500FF), Color(0xFFDE33A2)]),
                color: isClosed
                    ? Colors.white.withValues(alpha: 0.05)
                    : null,
                borderRadius: BorderRadius.circular(12),
                border: isClosed
                    ? Border.all(
                        color: Colors.white.withValues(alpha: 0.1))
                    : null,
              ),
              child: Center(
                child: Text(
                  isClosed ? 'Event Ditutup' : 'Daftar Sekarang',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isClosed ? Colors.white38 : Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
