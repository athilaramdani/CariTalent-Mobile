import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/widgets/talent_bookings_tab.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/widgets/talent_events_tab.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/widgets/talent_home_tab.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/widgets/talent_invitations_tab.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/widgets/talent_applications_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:caritalent_mobile/features/dashboard/application/dashboard_providers.dart';

class TalentDashboardPage extends ConsumerWidget {
  const TalentDashboardPage({super.key});

  static const routePath = '/talent';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(talentNavIndexProvider);

    return Scaffold(
      backgroundColor: AppTheme.neutralDark,
      body: IndexedStack(
        index: currentIndex,
        children: const [
          TalentHomeTab(),
          TalentEventsTab(),
          TalentApplicationsTab(),
          TalentInvitationsTab(),
          TalentBookingsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => ref.read(talentNavIndexProvider.notifier).state = index,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.uiDark,
        selectedItemColor: AppTheme.highlight,
        unselectedItemColor: AppTheme.neutralMedium,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.description_outlined), activeIcon: Icon(Icons.description), label: 'Applications'),
          BottomNavigationBarItem(icon: Icon(Icons.mail_outline), activeIcon: Icon(Icons.mail), label: 'Invitations'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_outline), activeIcon: Icon(Icons.bookmark), label: 'Bookings'),
        ],
      ),
    );
  }
}

