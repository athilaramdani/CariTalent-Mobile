import 'package:caritalent_mobile/core/constants/api_endpoints.dart';
import 'package:caritalent_mobile/core/network/api_client.dart';

class ReviewRepository {
  const ReviewRepository(this._api);
  final ApiClient _api;

  /// POST /reviews — EO creates a review for a talent after booking completed
  /// Fields: booking_id, talent_id, rating (1-5), comment (optional)
  Future<void> createReview({
    required int bookingId,
    required int talentId,
    required int rating,
    String? comment,
  }) async {
    final data = <String, dynamic>{
      'booking_id': bookingId,
      'talent_id': talentId,
      'rating': rating,
      if (comment != null && comment.isNotEmpty) 'comment': comment,
    };
    await _api.post<void>(
      ApiEndpoints.reviews,
      data: data,
      parser: (_) {},
    );
  }
}
