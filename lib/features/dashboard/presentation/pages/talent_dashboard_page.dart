import 'package:caritalent_mobile/features/dashboard/presentation/pages/dashboard_scaffold.dart';
import 'package:flutter/material.dart';

class TalentDashboardPage extends StatelessWidget {
  const TalentDashboardPage({super.key});

  static const routePath = '/talent';

  @override
  Widget build(BuildContext context) {
    return const DashboardScaffold(
      title: 'Talent',
      subtitle: 'Kelola event, lamaran, undangan, booking, dan review kamu.',
      stats: [
        DashboardStat(
          title: 'Applications',
          value: '-',
          hint: 'Lamaran terkirim',
          icon: Icons.assignment,
        ),
        DashboardStat(
          title: 'Invitations',
          value: '-',
          hint: 'Undangan EO',
          icon: Icons.mail,
        ),
        DashboardStat(
          title: 'Bookings',
          value: '-',
          hint: 'Jadwal tampil',
          icon: Icons.calendar_month,
        ),
        DashboardStat(
          title: 'Rating',
          value: '- / 5',
          hint: 'Rata-rata review',
          icon: Icons.star,
        ),
      ],
      items: [
        DashboardItem(
          title: 'Cari Event',
          caption: 'Lihat event publik',
          icon: Icons.event_available,
        ),
        DashboardItem(
          title: 'Lamaran',
          caption: 'Status application',
          icon: Icons.assignment,
        ),
        DashboardItem(
          title: 'Undangan',
          caption: 'Invitation dari EO',
          icon: Icons.mail,
        ),
        DashboardItem(
          title: 'Booking',
          caption: 'Jadwal tampil',
          icon: Icons.calendar_month,
        ),
        DashboardItem(
          title: 'Review',
          caption: 'Rating dan ulasan',
          icon: Icons.star,
        ),
        DashboardItem(
          title: 'Profil',
          caption: 'Portofolio talent',
          icon: Icons.person,
        ),
      ],
    );
  }
}
