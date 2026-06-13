import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:caritalent_mobile/core/widgets/gradient_text.dart';
import 'package:caritalent_mobile/features/dashboard/application/dashboard_providers.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/pages/talent_profile_page.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/pages/notifications_page.dart';
import 'package:go_router/go_router.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GradientText(
          'CariTalent',
          style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900, fontSize: 22) ??
              const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_outlined, color: Colors.white),
                  onPressed: () => context.push(NotificationsPage.routePath),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IgnorePointer(
                    child: Consumer(
                      builder: (ctx, ref, _) {
                        // Watch the unread count
                        final count = ref.watch(unreadNotificationCountProvider);
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
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => context.push(TalentProfilePage.routePath),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFB500FF), Color(0xFFDE33A2)],
                  ),
                ),
                child: const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.transparent,
                  child: Icon(Icons.person_outline, size: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
