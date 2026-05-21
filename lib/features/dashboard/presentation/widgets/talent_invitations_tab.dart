import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TalentInvitationsTab extends ConsumerWidget {
  const TalentInvitationsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

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
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Undangan eksklusif dari Event Organizer yang mengundang kamu untuk tampil di acara mereka.',
              style: textTheme.bodySmall?.copyWith(color: AppTheme.neutralMedium, height: 1.5),
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildInvitationCard(
                  context: context,
                  title: 'Private Birthday Party',
                  offeredPrice: 'Rp 2.000.000',
                  date: '25 Dec 2025',
                  venue: 'Villa Lembang, Bandung',
                  status: 'pending',
                  statusColor: Colors.blue,
                  textTheme: textTheme,
                ),
                _buildInvitationCard(
                  context: context,
                  title: 'Corporate Gathering 2025',
                  offeredPrice: 'Rp 5.500.000',
                  date: '10 Nov 2025',
                  venue: 'Hotel Mulia, Jakarta',
                  status: 'accepted',
                  statusColor: Colors.green,
                  textTheme: textTheme,
                ),
                _buildInvitationCard(
                  context: context,
                  title: 'Acara Komunitas Sepeda',
                  offeredPrice: 'Rp 1.000.000',
                  date: '01 Oct 2025',
                  venue: 'Kiara Artha Park, Bandung',
                  status: 'rejected',
                  statusColor: Colors.red,
                  textTheme: textTheme,
                ),
              ],
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
