import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for managing the BottomNavigationBar index.
final talentNavIndexProvider = StateProvider.autoDispose<int>((ref) => 0);

/// Provider for managing the BottomNavigationBar index for EO.
final eoNavIndexProvider = StateProvider.autoDispose<int>((ref) => 0);

/// Provider for managing the search query in the events search.
final eventSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

/// Provider for managing the search query in the bookings search.
final bookingSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

/// Provider for managing the search query in the invitations search.
final invitationSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');



