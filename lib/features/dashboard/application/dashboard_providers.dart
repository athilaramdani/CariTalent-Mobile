import 'package:caritalent_mobile/core/network/api_client.dart';
import 'package:caritalent_mobile/features/dashboard/data/application_repository.dart';
import 'package:caritalent_mobile/features/dashboard/data/booking_repository.dart';
import 'package:caritalent_mobile/features/dashboard/data/event_repository.dart';
import 'package:caritalent_mobile/features/dashboard/data/invitation_repository.dart';
import 'package:caritalent_mobile/features/dashboard/data/talent_repository.dart';
import 'package:caritalent_mobile/features/dashboard/domain/application_model.dart';
import 'package:caritalent_mobile/features/dashboard/domain/booking_model.dart';
import 'package:caritalent_mobile/features/dashboard/domain/event_model.dart';
import 'package:caritalent_mobile/features/dashboard/domain/invitation_model.dart';
import 'package:caritalent_mobile/features/dashboard/domain/recommendation_model.dart';
import 'package:caritalent_mobile/features/dashboard/domain/review_model.dart';
import 'package:caritalent_mobile/features/dashboard/domain/talent_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Nav Index Providers ──────────────────────────────────────────────────────

/// Provider for managing the BottomNavigationBar index.
final talentNavIndexProvider = StateProvider.autoDispose<int>((ref) => 0);

/// Provider for managing the BottomNavigationBar index for EO.
final eoNavIndexProvider = StateProvider.autoDispose<int>((ref) => 0);

/// Provider for managing the search query in the events search.
final eventSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

/// Provider for managing the search query in the bookings search.
final bookingSearchQueryProvider =
    StateProvider.autoDispose<String>((ref) => '');

/// Provider for managing the search query in the invitations search.
final invitationSearchQueryProvider =
    StateProvider.autoDispose<String>((ref) => '');

// ─── Repository Providers ─────────────────────────────────────────────────────

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository(ref.watch(apiClientProvider));
});

final talentRepositoryProvider = Provider<TalentRepository>((ref) {
  return TalentRepository(ref.watch(apiClientProvider));
});

final applicationRepositoryProvider = Provider<ApplicationRepository>((ref) {
  return ApplicationRepository(ref.watch(apiClientProvider));
});

final invitationRepositoryProvider = Provider<InvitationRepository>((ref) {
  return InvitationRepository(ref.watch(apiClientProvider));
});

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(ref.watch(apiClientProvider));
});

// ─── Data Providers ───────────────────────────────────────────────────────────

/// EO: list event milik EO yang login
final myEventsProvider =
    FutureProvider.autoDispose<List<EventModel>>((ref) async {
  return ref.read(eventRepositoryProvider).fetchMyEvents();
});

/// Talent: list event publik (bisa dengan filter)
class PublicEventsFilters {
  final String? status;
  final String? city;
  final String? search;
  final int? budgetMin;
  final int? budgetMax;

  const PublicEventsFilters({
    this.status,
    this.city,
    this.search,
    this.budgetMin,
    this.budgetMax,
  });
}

final publicEventsFiltersProvider =
    StateProvider.autoDispose<PublicEventsFilters>(
        (ref) => const PublicEventsFilters());

final publicEventsProvider =
    FutureProvider.autoDispose<List<EventModel>>((ref) async {
  final filters = ref.watch(publicEventsFiltersProvider);
  return ref.read(eventRepositoryProvider).fetchPublicEvents(
        status: filters.status,
        city: filters.city,
        search: filters.search,
        budgetMin: filters.budgetMin,
        budgetMax: filters.budgetMax,
      );
});

/// Talent: lamaran saya (source=apply)
final myApplicationsProvider =
    FutureProvider.autoDispose<List<ApplicationModel>>((ref) async {
  return ref.read(applicationRepositoryProvider).fetchMyApplications();
});

/// Talent: undangan masuk ke saya
final myInvitationsProvider =
    FutureProvider.autoDispose<List<InvitationModel>>((ref) async {
  return ref.read(invitationRepositoryProvider).fetchMyInvitations();
});

/// EO: undangan yang sudah dikirim
final sentInvitationsProvider =
    FutureProvider.autoDispose<List<InvitationModel>>((ref) async {
  return ref.read(invitationRepositoryProvider).fetchSentInvitations();
});

/// Talent & EO: booking saya
final myBookingsProvider =
    FutureProvider.autoDispose<List<BookingModel>>((ref) async {
  return ref.read(bookingRepositoryProvider).fetchMyBookings();
});

/// Talent: profil talent saya
final myTalentProvider =
    FutureProvider.autoDispose<TalentModel>((ref) async {
  return ref.read(talentRepositoryProvider).fetchMyTalent();
});

/// Talent: review saya
final myReviewsProvider =
    FutureProvider.autoDispose<TalentReviewsData>((ref) async {
  return ref.read(talentRepositoryProvider).fetchMyReviews();
});

/// EO: pelamar untuk event tertentu
final eventApplicationsProvider = FutureProvider.autoDispose
    .family<List<ApplicationModel>, int>((ref, eventId) async {
  return ref
      .read(eventRepositoryProvider)
      .fetchEventApplications(eventId);
});

/// EO: rekomendasi untuk event tertentu
final recommendationsProvider = FutureProvider.autoDispose
    .family<RecommendationsData, int>((ref, eventId) async {
  return ref.read(eventRepositoryProvider).fetchRecommendations(eventId);
});
