import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/core/widgets/gradient_text.dart';
import 'package:caritalent_mobile/features/dashboard/application/dashboard_providers.dart';
import 'package:caritalent_mobile/features/dashboard/domain/invitation_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class EoInvitationsTab extends ConsumerStatefulWidget {
  const EoInvitationsTab({super.key});

  @override
  ConsumerState<EoInvitationsTab> createState() => _EoInvitationsTabState();
}

class _EoInvitationsTabState extends ConsumerState<EoInvitationsTab> {
  String _selectedFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final invitationsAsync = ref.watch(sentInvitationsProvider);

    return SafeArea(
      child: invitationsAsync.when(
        data: (invitations) {
          final accepted =
              invitations.where((i) => i.status == 'accepted').length;
          final pending =
              invitations.where((i) => i.status == 'pending').length;

          final filtered = _selectedFilter == 'Semua'
              ? invitations
              : invitations.where((i) {
                  switch (_selectedFilter) {
                    case 'Menunggu':
                      return i.status == 'pending';
                    case 'Diterima':
                      return i.status == 'accepted';
                    default:
                      return true;
                  }
                }).toList();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              GradientText(
                'Undangan Terkirim',
                style: GoogleFonts.syne(
                  textStyle: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Daftar talent yang kamu undang\nsecara langsung ke event kamu',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // Metric Cards
              Row(
                children: [
                  _buildMetricCard(
                      context, '${invitations.length}', 'TOTAL', AppTheme.highlight),
                  const SizedBox(width: 12),
                  _buildMetricCard(
                      context, '$accepted', 'DITERIMA', Colors.greenAccent),
                  const SizedBox(width: 12),
                  _buildMetricCard(
                      context, '$pending', 'MENUNGGU', Colors.orangeAccent),
                ],
              ),
              const SizedBox(height: 24),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(context, 'Semua', '${invitations.length}'),
                    _buildFilterChip(context, 'Menunggu', '$pending'),
                    _buildFilterChip(context, 'Diterima', '$accepted'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (filtered.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        const Icon(Icons.mail_outline,
                            size: 52, color: Colors.white24),
                        const SizedBox(height: 16),
                        Text('Tidak ada undangan',
                            style: textTheme.bodyMedium
                                ?.copyWith(color: Colors.white38)),
                      ],
                    ),
                  ),
                )
              else
                for (final inv in filtered) ...[
                  _buildInvitationCard(context: context, inv: inv),
                  const SizedBox(height: 16),
                ],

              const SizedBox(height: 48),
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
              Text('Gagal memuat undangan: $e',
                  style: const TextStyle(color: Colors.white54),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(sentInvitationsProvider),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
      BuildContext context, String value, String label, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppTheme.uiDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w400, color: valueColor),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white54,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String count) {
    final isActive = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFFB500FF), Color(0xFFE94057)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isActive ? null : Colors.transparent,
          border: isActive ? null : Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Text(label,
                style: TextStyle(
                    color: isActive ? Colors.white : Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Text(count,
                  style: TextStyle(
                      color: isActive ? Colors.white : Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  String _invStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'accepted':
        return 'Diterima';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  Widget _buildInvitationCard({
    required BuildContext context,
    required InvitationModel inv,
  }) {
    final talent = inv.talent;
    final name = talent?.stageName ?? 'Talent';
    final location = talent?.city ?? '';
    final rating = talent?.averageRating.toStringAsFixed(1) ?? '0.0';
    final verified = talent?.verified ?? false;
    final genres = talent?.genre ?? [];

    Color statusColor;
    Color statusBorder;
    if (inv.status == 'pending') {
      statusColor = const Color(0xFFF59E0B);
      statusBorder = const Color(0xFFF59E0B);
    } else if (inv.status == 'accepted') {
      statusColor = Colors.greenAccent;
      statusBorder = Colors.greenAccent;
    } else {
      statusColor = Colors.redAccent;
      statusBorder = Colors.redAccent;
    }

    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: statusBorder.withValues(alpha: 0.5)),
                ),
                child: Text(
                  _invStatusLabel(inv.status),
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(location,
                  style: const TextStyle(fontSize: 13, color: Colors.white70)),
              const SizedBox(width: 8),
              const Icon(Icons.star, color: Color(0xFFF59E0B), size: 14),
              const SizedBox(width: 4),
              Text(
                rating,
                style: const TextStyle(
                    color: Color(0xFFF59E0B),
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              if (verified)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified, color: Colors.green, size: 10),
                      SizedBox(width: 4),
                      Text('VERIFIED',
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 8,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (genres.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: genres
                    .take(4)
                    .map((genre) => Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: Text(
                            genre,
                            style: TextStyle(
                                color: const Color(0xFFC026D3)
                                    .withValues(alpha: 0.9),
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ))
                    .toList(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(
                color: Colors.white.withValues(alpha: 0.05), height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('HARGA DITAWARKAN',
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(
                    inv.offeredPriceFormatted,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('DIKIRIM',
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(
                    inv.dateFormatted,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
