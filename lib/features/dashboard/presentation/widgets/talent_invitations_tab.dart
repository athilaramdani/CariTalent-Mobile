import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/features/dashboard/application/dashboard_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TalentInvitationsTab extends ConsumerWidget {
  const TalentInvitationsTab({super.key});

  static const List<_InvitationItem> _allInvitations = [
    _InvitationItem(
      title: 'Private Birthday Party',
      offeredPrice: 'Rp 2.000.000',
      date: '25 Dec 2025',
      venue: 'Villa Lembang, Bandung',
      status: 'pending',
      statusColor: Colors.blue,
    ),
    _InvitationItem(
      title: 'Corporate Gathering 2025',
      offeredPrice: 'Rp 5.500.000',
      date: '10 Nov 2025',
      venue: 'Hotel Mulia, Jakarta',
      status: 'accepted',
      statusColor: Colors.green,
    ),
    _InvitationItem(
      title: 'Acara Komunitas Sepeda',
      offeredPrice: 'Rp 1.000.000',
      date: '01 Oct 2025',
      venue: 'Kiara Artha Park, Bandung',
      status: 'rejected',
      statusColor: Colors.red,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final searchQuery = ref.watch(invitationSearchQueryProvider);

    // Filter invitations based on search query
    final filteredInvitations = _allInvitations.where((invitation) {
      if (searchQuery.isEmpty) return true;
      final query = searchQuery.toLowerCase();
      return invitation.title.toLowerCase().contains(query) ||
          invitation.venue.toLowerCase().contains(query) ||
          invitation.status.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.neutralDark,
      appBar: AppBar(
        title: Text('Undangan', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppTheme.uiDark,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: AppTheme.border, height: 1.0),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                ref.read(invitationSearchQueryProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                hintText: 'Cari undangan acara, tempat, dll...',
                hintStyle: textTheme.bodyMedium?.copyWith(color: AppTheme.neutralMedium),
                prefixIcon: const Icon(Icons.search, color: AppTheme.neutralMedium),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppTheme.neutralMedium),
                        onPressed: () {
                          ref.read(invitationSearchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.uiDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppTheme.highlight),
                ),
              ),
              style: textTheme.bodyMedium,
            ),
          ),
          
          // Invitations List
          Expanded(
            child: filteredInvitations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off_rounded, size: 64, color: AppTheme.neutralMedium),
                        const SizedBox(height: 16),
                        Text(
                          'Undangan tidak ditemukan',
                          style: textTheme.titleMedium?.copyWith(color: AppTheme.neutralMedium),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredInvitations.length,
                    itemBuilder: (context, index) {
                      final invitation = filteredInvitations[index];
                      return _buildInvitationCard(
                        context: context,
                        title: invitation.title,
                        offeredPrice: invitation.offeredPrice,
                        date: invitation.date,
                        venue: invitation.venue,
                        status: invitation.status,
                        statusColor: invitation.statusColor,
                        textTheme: textTheme,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationCard({
    required BuildContext context,
    required String title,
    required String offeredPrice,
    required String date,
    required String venue,
    required String status,
    required Color statusColor,
    required TextTheme textTheme,
  }) {
    final isPending = status == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.uiDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
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
                  title,
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: AppTheme.neutralMedium),
              const SizedBox(width: 6),
              Text(date, style: textTheme.bodySmall),
              const SizedBox(width: 16),
              const Icon(Icons.location_on, size: 14, color: AppTheme.neutralMedium),
              const SizedBox(width: 6),
              Expanded(
                child: Text(venue, style: textTheme.bodySmall, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppTheme.border, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Penawaran Harga', style: textTheme.labelSmall?.copyWith(color: AppTheme.neutralMedium)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.local_offer_outlined, size: 14, color: AppTheme.highlight),
                      const SizedBox(width: 6),
                      Text(
                        offeredPrice, 
                        style: textTheme.labelLarge?.copyWith(color: AppTheme.highlight, fontWeight: FontWeight.bold)
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Tolak'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Terima'),
                  ),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }
}

class _InvitationItem {
  final String title;
  final String offeredPrice;
  final String date;
  final String venue;
  final String status;
  final Color statusColor;

  const _InvitationItem({
    required this.title,
    required this.offeredPrice,
    required this.date,
    required this.venue,
    required this.status,
    required this.statusColor,
  });
}
