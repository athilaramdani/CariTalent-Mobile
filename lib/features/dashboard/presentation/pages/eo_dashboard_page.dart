import 'package:caritalent_mobile/app/theme/app_theme.dart';
import 'package:caritalent_mobile/core/widgets/app_shell.dart';
import 'package:caritalent_mobile/core/widgets/gradient_text.dart';
import 'package:caritalent_mobile/features/dashboard/application/dashboard_providers.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/pages/notifications_page.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/widgets/eo_bookings_tab.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/widgets/eo_events_tab.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/widgets/eo_home_tab.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/widgets/eo_invitations_tab.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/widgets/eo_profile_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EoDashboardPage extends ConsumerWidget {
  const EoDashboardPage({super.key});

  static const routePath = '/eo';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(eoNavIndexProvider);

    return AppShell(
      appBar: currentIndex == 4
          ? null // No header on Profile Tab
          : AppBar(
              title: const GradientText(
                'CariTalent',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                // Notification bell with unread badge
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none, color: Colors.white),
                      onPressed: () => context.push(NotificationsPage.routePath),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Consumer(
                        builder: (ctx, r, _) {
                          final count = r.watch(unreadNotificationCountProvider);
                          if (count == 0) return const SizedBox.shrink();
                          return Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                count > 9 ? '9+' : '$count',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFB500FF), Color(0xFFE94057)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(Icons.person_outline, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 20),
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
