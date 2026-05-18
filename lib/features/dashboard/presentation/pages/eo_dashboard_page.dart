import 'package:caritalent_mobile/features/dashboard/presentation/pages/dashboard_scaffold.dart';
import 'package:flutter/material.dart';

class EoDashboardPage extends StatelessWidget {
  const EoDashboardPage({super.key});

  static const routePath = '/eo';

  @override
  Widget build(BuildContext context) {
    return const DashboardScaffold(
      title: 'Event Organizer',
      subtitle: 'Kelola event, applicant, rekomendasi talent, dan booking.',
      stats: [
        DashboardStat(
          title: 'Events',
          value: '-',
          hint: 'Semua event',
          icon: Icons.event,
        ),
        DashboardStat(
          title: 'Active',
          value: '-',
          hint: 'Event open',
          icon: Icons.event_available,
        ),
        DashboardStat(
          title: 'Bookings',
          value: '-',
          hint: 'Booking berjalan',
          icon: Icons.handshake,
        ),
        DashboardStat(
          title: 'Completed',
          value: '-',
          hint: 'Booking selesai',
          icon: Icons.verified,
        ),
      ],
      items: [
        DashboardItem(
          title: 'Event Saya',
          caption: 'Buat dan edit event',
          icon: Icons.event,
        ),
        DashboardItem(
          title: 'Applicant',
          caption: 'Review pendaftar',
          icon: Icons.groups,
        ),
        DashboardItem(
          title: 'Rekomendasi',
          caption: 'Matchmaking talent',
          icon: Icons.auto_awesome,
        ),
        DashboardItem(
          title: 'Undangan',
          caption: 'Talent yang diundang',
          icon: Icons.outgoing_mail,
        ),
        DashboardItem(
          title: 'Booking',
          caption: 'Kontrak berjalan',
          icon: Icons.handshake,
        ),
        DashboardItem(
          title: 'Profil',
          caption: 'Data organizer',
          icon: Icons.business,
        ),
      ],
    );
  }
}
