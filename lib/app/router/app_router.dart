import 'package:caritalent_mobile/core/constants/user_roles.dart';
import 'package:caritalent_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:caritalent_mobile/features/auth/presentation/pages/register_page.dart';
import 'package:caritalent_mobile/features/auth/presentation/pages/splash_page.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/pages/eo_dashboard_page.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/pages/talent_dashboard_page.dart';
import 'package:caritalent_mobile/features/public/presentation/pages/public_home_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: SplashPage.routePath,
    routes: [
      GoRoute(
        path: SplashPage.routePath,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: PublicHomePage.routePath,
        builder: (context, state) => const PublicHomePage(),
      ),
      GoRoute(
        path: LoginPage.routePath,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RegisterPage.routePath,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: TalentDashboardPage.routePath,
        builder: (context, state) => const TalentDashboardPage(),
      ),
      GoRoute(
        path: EoDashboardPage.routePath,
        builder: (context, state) => const EoDashboardPage(),
      ),
    ],
  );
});

String dashboardRouteForRole(String? role) {
  return switch (role) {
    UserRoles.eo => EoDashboardPage.routePath,
    UserRoles.talent => TalentDashboardPage.routePath,
    _ => PublicHomePage.routePath,
  };
}
