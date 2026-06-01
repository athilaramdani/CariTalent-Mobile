import 'package:caritalent_mobile/core/constants/api_endpoints.dart';
import 'package:caritalent_mobile/core/network/api_client.dart';
import 'package:caritalent_mobile/features/dashboard/domain/booking_model.dart';

class BookingRepository {
  const BookingRepository(this._api);
  final ApiClient _api;

  /// GET /bookings/my — logged-in user's bookings (role-aware on backend)
  Future<List<BookingModel>> fetchMyBookings({String? status}) async {
    final params = <String, dynamic>{};
    if (status != null && status.isNotEmpty) params['status'] = status;

    return _api.get<List<BookingModel>>(
      ApiEndpoints.myBookings,
      queryParameters: params,
      parser: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['bookings'] as List<dynamic>? ?? [];
        return list.map((e) => BookingModel.fromJson(e)).toList();
      },
    );
  }

  /// PUT /bookings/{id}/complete — EO marks booking as completed
  Future<void> completeBooking(int id) async {
    await _api.put<void>(
      ApiEndpoints.completeBooking(id),
      parser: (_) {},
    );
  }

  /// PUT /bookings/{id}/cancel — talent or EO cancels booking
  Future<void> cancelBooking(int id) async {
    await _api.put<void>(
      ApiEndpoints.cancelBooking(id),
      parser: (_) {},
    );
  }
}
