import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/core/widgets/app_shell.dart';
import 'package:caritalent_mobile/core/widgets/gradient_text.dart';
import 'package:caritalent_mobile/features/dashboard/application/dashboard_providers.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/widgets/eo_bookings_tab.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/widgets/eo_events_tab.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/widgets/eo_home_tab.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/widgets/eo_invitations_tab.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/widgets/eo_profile_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EoDashboardPage extends ConsumerWidget {
  const EoDashboardPage({super.key});

  static const routePath = '/eo';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(eoNavIndexProvider);

    return AppShell(
      appBar: AppBar(
        title: const GradientText(
          'CariTalent',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
          const CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.uiDark,
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => ref.read(eoNavIndexProvider.notifier).state = index,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.uiDark,
        selectedItemColor: AppTheme.highlight,
        unselectedItemColor: AppTheme.neutralMedium,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.book_online_outlined), activeIcon: Icon(Icons.book_online), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.mail_outline), activeIcon: Icon(Icons.mail), label: 'Invitations'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      child: IndexedStack(
        index: currentIndex,
        children: const [
          EoHomeTab(),
          EoEventsTab(),
          EoBookingsTab(),
          EoInvitationsTab(),
          EoProfileTab(),
        ],
      ),
    );
  }
}
