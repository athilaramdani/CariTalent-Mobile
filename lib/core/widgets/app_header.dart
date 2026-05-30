import 'package:flutter/material.dart';
import 'package:caritalent_mobile/core/widgets/gradient_text.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/pages/talent_profile_page.dart';
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
            const Icon(Icons.notifications_none_outlined, color: Colors.white),
            const SizedBox(width: 16),
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
