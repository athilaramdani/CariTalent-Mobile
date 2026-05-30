import 'package:flutter/material.dart';
import 'package:caritalent_mobile/core/widgets/app_header.dart';

class TalentInvitationsTab extends StatefulWidget {
  const TalentInvitationsTab({super.key});

  @override
  State<TalentInvitationsTab> createState() => _TalentInvitationsTabState();
}

class _TalentInvitationsTabState extends State<TalentInvitationsTab> {
  String _selectedFilter = 'All';

  final List<_InvitationItem> _allInvitations = [
    _InvitationItem(
      title: 'Kenapa?',
      organizer: 'Kenapa?',
      description:
          'Kamu diundang untuk tampil di acara ini. Kami sangat senang jika kamu bisa bergabung sebagai performer utama.',
      offer: 'Rp 2.000.000',
      date: '17 Des 2005 • 08:00 PM',
      kota: 'asaas, asas',
      venue: 'asas',
      budget: 'Rp 10.000',
      sentTime: '10 Mei 2026',
      status: 'Pending',
    ),
    _InvitationItem(
      title: 'tesdt',
      organizer: 'Organizer belum diatur',
      description:
          'Undangan untuk tampil di acara kami. Segera konfirmasi kehadiran kamu sebelum batas waktu.',
      offer: 'Rp 2.000.000',
      date: '16 Jul 1000 • 07:00 PM',
      kota: 'appaan, asa',
      venue: 'asa',
      budget: 'Rp 10.000',
      sentTime: '10 Mei 2026',
      status: 'Pending',
    ),
    _InvitationItem(
      title: 'Opening Cafe Baru',
      organizer: 'Budi Management',
      description:
          'Kami mengundang kamu untuk tampil di grand opening cafe kami. Kesempatan bagus untuk menampilkan bakat kamu.',
      offer: 'Rp 1.500.000',
      date: '20 Agust 2026 • 06:00 PM',
      kota: 'Bandung',
      venue: 'Gedung Sate',
      budget: 'Rp 1.500.000',
      sentTime: '12 Mei 2026',
      status: 'Accepted',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    List<String> filters = ['All', 'Pending', 'Accepted', 'Declined'];

    final filtered = _allInvitations.where((e) {
      if (_selectedFilter == 'All') return true;
      return e.status == _selectedFilter;
    }).toList();

    final total = _allInvitations.length;
    final acceptedCount = _allInvitations.where((e) => e.status == 'Accepted').length;
    final pendingCount = _allInvitations.where((e) => e.status == 'Pending').length;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const AppHeader(),
                  const SizedBox(height: 32),

                  // Page Title
                  Text(
                    'Event Invitations',
                    style: textTheme.labelMedium?.copyWith(
                      color: Colors.white54,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFB500FF), Color(0xFFDE33A2)],
                    ).createShader(bounds),
                    child: Text(
                      'Invitations',
                      style: textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Review and respond to event invitations',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.white54,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Stats Row
                  Row(
                    children: [
                      _buildStatBox('$total', 'TOTAL', const Color(0xFFC48DF6), textTheme),
                      const SizedBox(width: 8),
                      _buildStatBox('$acceptedCount', 'ACCEPTED', Colors.greenAccent, textTheme),
                      const SizedBox(width: 8),
                      _buildStatBox('$pendingCount', 'PENDING', Colors.amber, textTheme),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Filter Pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: filters.map((f) {
                        final isSelected = _selectedFilter == f;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedFilter = f),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? const LinearGradient(
                                        colors: [Color(0xFFB500FF), Color(0xFFDE33A2)],
                                      )
                                    : null,
                                color: isSelected ? null : Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : Colors.white.withValues(alpha: 0.12),
                                ),
                              ),
                              child: Text(
                                f,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white60,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),

          // Invitation Cards
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: filtered.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            const Icon(Icons.mail_outline, size: 52, color: Colors.white24),
                            const SizedBox(height: 16),
                            Text('Tidak ada undangan',
                                style: textTheme.bodyMedium?.copyWith(color: Colors.white38)),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _InvitationCard(item: filtered[index]),
                      childCount: filtered.length,
                    ),
                  ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 48)),
        ],
      ),
    );
  }

  Widget _buildStatBox(String value, String label, Color color, TextTheme textTheme) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Column(children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 30,
              fontWeight: FontWeight.w300,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(color: Colors.white38, fontSize: 9, letterSpacing: 1.5)),
        ]),
      ),
    );
  }
}

// ─── Invitation Card ──────────────────────────────────────────────────────────

class _InvitationCard extends StatelessWidget {
  final _InvitationItem item;
  const _InvitationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isPending = item.status == 'Pending';

    Color badgeColor;
    Color badgeBg;
    if (item.status == 'Pending') {
      badgeColor = Colors.amber;
      badgeBg = Colors.amber.withValues(alpha: 0.15);
    } else if (item.status == 'Accepted') {
      badgeColor = Colors.greenAccent;
      badgeBg = Colors.greenAccent.withValues(alpha: 0.12);
    } else {
      badgeColor = Colors.redAccent;
      badgeBg = Colors.redAccent.withValues(alpha: 0.12);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF13112B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header: Mail Icon + Title + Badge ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB500FF), Color(0xFFDE33A2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.mail_outline, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: badgeBg,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  item.status,
                                  style: TextStyle(
                                    color: badgeColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          RichText(
                            text: TextSpan(
                              style: textTheme.bodySmall?.copyWith(color: Colors.white54),
                              children: [
                                const TextSpan(text: 'Organizer: '),
                                TextSpan(
                                  text: item.organizer,
                                  style: const TextStyle(color: Color(0xFFC48DF6)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Offer Price ──
                RichText(
                  text: TextSpan(
                    style: textTheme.bodySmall?.copyWith(color: Colors.white54),
                    children: [
                      const TextSpan(text: 'Offer: '),
                      TextSpan(
                        text: item.offer,
                        style: const TextStyle(
                          color: Color(0xFFC48DF6),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Two-column detail grid (web layout) ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: Jadwal, Kota, Dikirim
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _GridDetailRow(label: 'Jadwal event', value: item.date),
                          const SizedBox(height: 6),
                          _GridDetailRow(label: 'Kota', value: item.kota),
                          const SizedBox(height: 6),
                          _GridDetailRow(label: 'Dikirim', value: item.sentTime),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Right: Venue, Budget event
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _GridDetailRow(label: 'Venue', value: item.venue),
                          const SizedBox(height: 6),
                          _GridDetailRow(label: 'Budget event', value: item.budget),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Lihat Lokasi Button ──
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.location_on_outlined, size: 15, color: Color(0xFF81D4FA)),
                  label: const Text(
                    'Lihat Lokasi',
                    style: TextStyle(color: Color(0xFF81D4FA), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF81D4FA)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),

          // ── Accept / Reject Buttons ──
          if (isPending)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: 'Accept',
                      icon: Icons.check_circle_outline,
                      color: const Color(0xFF22C55E),
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      label: 'Reject',
                      icon: Icons.cancel_outlined,
                      color: Colors.redAccent,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _GridDetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _GridDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 12, height: 1.4),
        children: [
          TextSpan(text: '$label: ', style: const TextStyle(color: Colors.white38)),
          TextSpan(
            text: value,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.6)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Data Model ───────────────────────────────────────────────────────────────

class _InvitationItem {
  final String title;
  final String organizer;
  final String description;
  final String offer;
  final String date;
  final String kota;
  final String venue;
  final String budget;
  final String sentTime;
  final String status;

  const _InvitationItem({
    required this.title,
    required this.organizer,
    required this.description,
    required this.offer,
    required this.date,
    required this.kota,
    required this.venue,
    required this.budget,
    required this.sentTime,
    required this.status,
  });
}
