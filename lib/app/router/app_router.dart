import 'package:caritalent_mobile/core/constants/user_roles.dart';
import 'package:caritalent_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:caritalent_mobile/features/auth/presentation/pages/register_talent_page.dart';
import 'package:caritalent_mobile/features/auth/presentation/pages/register_eo_page.dart';
import 'package:caritalent_mobile/features/auth/presentation/pages/register_page.dart';
import 'package:caritalent_mobile/features/auth/presentation/pages/splash_page.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/pages/eo_applicants_page.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/pages/eo_change_password_page.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/pages/eo_dashboard_page.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/pages/eo_edit_profile_page.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/pages/eo_recommendations_page.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/pages/talent_change_password_page.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/pages/talent_dashboard_page.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/pages/talent_edit_profile_page.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/pages/talent_profile_page.dart';
import 'package:caritalent_mobile/features/dashboard/presentation/pages/notifications_page.dart';
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
        builder: (context, state) {
          final page = int.tryParse(state.uri.queryParameters['page'] ?? '0') ?? 0;
          return PublicHomePage(initialPage: page);
        },
      ),
      GoRoute(
        path: '/onboarding/:slide',
        builder: (context, state) {
          final slide = int.tryParse(state.pathParameters['slide'] ?? '1') ?? 1;
          return PublicHomePage(initialPage: slide - 1);
        },
      ),
      GoRoute(
        path: LoginPage.routePath,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: RegisterPage.routePath,
        builder: (context, state) => const PublicHomePage(initialPage: 3),
      ),
      GoRoute(
        path: RegisterTalentPage.routePath,
        builder: (context, state) => const RegisterTalentPage(),
      ),
      GoRoute(
        path: RegisterEoPage.routePath,
        builder: (context, state) => const RegisterEoPage(),
      ),
      GoRoute(
        path: TalentDashboardPage.routePath,
        builder: (context, state) => const TalentDashboardPage(),
      ),
      GoRoute(
        path: TalentProfilePage.routePath,
        builder: (context, state) => const TalentProfilePage(),
      ),
      GoRoute(
        path: TalentEditProfilePage.routePath,
        builder: (context, state) => const TalentEditProfilePage(),
      ),
      GoRoute(
        path: TalentChangePasswordPage.routePath,
        builder: (context, state) => const TalentChangePasswordPage(),
      ),
      GoRoute(
        path: EoDashboardPage.routePath,
        builder: (context, state) => const EoDashboardPage(),
      ),
      // EO Applicants — receives eventId as path param
      GoRoute(
        path: '${EoApplicantsPage.routePath}/:eventId',
        builder: (context, state) {
          final eventId =
              int.tryParse(state.pathParameters['eventId'] ?? '0') ?? 0;
          return EoApplicantsPage(eventId: eventId);
        },
      ),
      // EO Recommendations — receives eventId as path param
      GoRoute(
        path: '${EoRecommendationsPage.routePath}/:eventId',
        builder: (context, state) {
          final eventId =
              int.tryParse(state.pathParameters['eventId'] ?? '0') ?? 0;
          return EoRecommendationsPage(eventId: eventId);
        },
      ),
      GoRoute(
        path: EoEditProfilePage.routePath,
        builder: (context, state) => const EoEditProfilePage(),
      ),
      GoRoute(
        path: EoChangePasswordPage.routePath,
        builder: (context, state) => const EoChangePasswordPage(),
      ),
      GoRoute(
        path: NotificationsPage.routePath,
        builder: (context, state) => const NotificationsPage(),
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
