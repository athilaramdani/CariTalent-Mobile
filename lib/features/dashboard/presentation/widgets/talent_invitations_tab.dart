import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/core/widgets/app_header.dart';
import 'package:caritalent_mobile/core/widgets/gradient_text.dart';
import 'package:caritalent_mobile/features/dashboard/application/dashboard_providers.dart';
import 'package:caritalent_mobile/features/dashboard/domain/invitation_model.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/widgets/event_map_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

String? _invitationStatusValue(String label) {
  switch (label) {
    case 'Menunggu':
      return 'pending';
    case 'Diterima':
      return 'accepted';
    case 'Ditolak':
      return 'rejected';
    default:
      return null;
  }
}

String _invitationStatusLabel(String status) {
  switch (status.trim().toLowerCase()) {
    case 'pending':
      return 'Menunggu';
    case 'accepted':
      return 'Diterima';
    case 'rejected':
      return 'Ditolak';
    default:
      return status.isEmpty
          ? '-'
          : '${status[0].toUpperCase()}${status.substring(1)}';
  }
}

class TalentInvitationsTab extends ConsumerStatefulWidget {
  const TalentInvitationsTab({super.key});

  @override
  ConsumerState<TalentInvitationsTab> createState() =>
      _TalentInvitationsTabState();
}

class _TalentInvitationsTabState extends ConsumerState<TalentInvitationsTab> {
  String _selectedFilter = 'Semua';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final invitationsAsync = ref.watch(myInvitationsProvider);

    return SafeArea(
      child: invitationsAsync.when(
        data: (invitations) {
          final pending =
              invitations.where((i) => i.status == 'pending').length;
          final accepted =
              invitations.where((i) => i.status == 'accepted').length;
          final rejected =
              invitations.where((i) => i.status == 'rejected').length;

          final selectedStatus = _invitationStatusValue(_selectedFilter);
          final filtered = selectedStatus == null
              ? invitations
              : invitations.where((i) => i.status == selectedStatus).toList();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              const AppHeader(),
              const SizedBox(height: 32),
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
                'Undangan langsung dari Event Organizer\nuntuk kamu tampil di event mereka',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // Stats
              Row(
                children: [
                  _buildStatCard(
                    context,
                    '${invitations.length}',
                    'Semua',
                    null,
                  ),
                  const SizedBox(width: 8),
                  _buildStatCard(
                    context,
                    '$pending',
                    'Menunggu',
                    Colors.orangeAccent,
                  ),
                  const SizedBox(width: 8),
                  _buildStatCard(
                    context,
                    '$accepted',
                    'Diterima',
                    Colors.greenAccent,
                  ),
                  const SizedBox(width: 8),
                  _buildStatCard(
                    context,
                    '$rejected',
                    'Ditolak',
                    Colors.redAccent,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(context, 'Semua', '${invitations.length}'),
                    _buildFilterChip(context, 'Menunggu', '$pending'),
                    _buildFilterChip(context, 'Diterima', '$accepted'),
                    _buildFilterChip(context, 'Ditolak', '$rejected'),
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
                        const Icon(
                          Icons.mail_outline,
                          size: 52,
                          color: Colors.white24,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada undangan',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                for (final inv in filtered) ...[
                  _InvitationCard(
                    invitation: inv,
                    onAccept: () => _respond(inv.id, 'accepted'),
                    onReject: () => _respond(inv.id, 'rejected'),
                  ),
                  const SizedBox(height: 16),
                ],

              const SizedBox(height: 48),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (e, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.redAccent,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Gagal memuat undangan: $e',
                    style: const TextStyle(color: Colors.white54),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(myInvitationsProvider),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  Future<void> _respond(int id, String status) async {
    try {
      await ref
          .read(invitationRepositoryProvider)
          .respondInvitation(id: id, status: status);
      ref.invalidate(myInvitationsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Widget _buildStatCard(
    BuildContext context,
    String value,
    String label,
    Color? valueColor,
  ) {
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
                fontSize: 28,
                fontWeight: FontWeight.w400,
                color: valueColor ?? Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white54,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
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
          gradient:
              isActive
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
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Text(
                count,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Invitation Card ──────────────────────────────────────────────────────────

class _InvitationCard extends StatefulWidget {
  final InvitationModel invitation;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _InvitationCard({
    required this.invitation,
    required this.onAccept,
    required this.onReject,
  });

  @override
  State<_InvitationCard> createState() => _InvitationCardState();
}

class _InvitationCardState extends State<_InvitationCard> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final inv = widget.invitation;
    final textTheme = Theme.of(context).textTheme;
    final isPending = inv.status == 'pending';
    final isAccepted = inv.status == 'accepted';

    Color statusColor;
    if (isAccepted) {
      statusColor = Colors.greenAccent;
    } else if (inv.status == 'rejected') {
      statusColor = Colors.redAccent;
    } else {
      statusColor = Colors.orangeAccent;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.uiDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  inv.eventTitle,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _invitationStatusLabel(inv.status),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 12,
                color: Colors.white54,
              ),
              const SizedBox(width: 4),
              Text(
                inv.eventDateFormatted,
                style: textTheme.bodySmall?.copyWith(color: Colors.white54),
              ),
              if (inv.eventVenue.isNotEmpty) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.location_on_outlined,
                  size: 12,
                  color: Colors.white54,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    inv.eventVenue,
                    style: textTheme.bodySmall?.copyWith(color: Colors.white54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const SizedBox(width: 8),
              EventMapButton(
                eventName: inv.eventTitle,
                displayAddress: inv.eventAddress,
                latitude: inv.eventLat,
                longitude: inv.eventLng,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Divider(
              height: 1,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'HARGA DITAWARKAN',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    inv.offeredPriceFormatted,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFE879F9),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'DITERIMA',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    inv.dateFormatted,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Buttons only for pending
          if (isPending) ...[
            const SizedBox(height: 16),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          setState(() => _loading = true);
                          widget.onAccept();
                          if (mounted) setState(() => _loading = false);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Terima',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          setState(() => _loading = true);
                          widget.onReject();
                          if (mounted) setState(() => _loading = false);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.redAccent.withValues(alpha: 0.4),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cancel_outlined,
                                color: Colors.redAccent,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Tolak',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
          ],

          if (isAccepted) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Undangan Diterima',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
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
