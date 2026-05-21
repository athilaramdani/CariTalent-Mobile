import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for managing the BottomNavigationBar index.
final talentNavIndexProvider = StateProvider.autoDispose<int>((ref) => 0);
