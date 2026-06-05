import 'package:caritalent_mobile/core/constants/api_endpoints.dart';
import 'package:caritalent_mobile/core/network/api_client.dart';
import 'package:caritalent_mobile/features/dashboard/domain/talent_model.dart';
import 'package:caritalent_mobile/features/dashboard/domain/review_model.dart';

class TalentRepository {
  const TalentRepository(this._api);
  final ApiClient _api;

  /// GET /talents/my — logged-in talent's own profile
  Future<TalentModel> fetchMyTalent() async {
    return _api.get<TalentModel>(
      ApiEndpoints.myTalent,
      parser: TalentModel.fromJson,
    );
  }

  /// PUT /talents/{id} — update talent profile
  Future<void> updateTalentProfile(int id, Map<String, dynamic> data) async {
    await _api.put<void>(
      ApiEndpoints.updateTalent(id),
      data: data,
      parser: (_) {},
    );
  }

  /// GET /reviews/my — my reviews (talent)
  Future<TalentReviewsData> fetchMyReviews() async {
    return _api.get<TalentReviewsData>(
      ApiEndpoints.myReviews,
      parser: TalentReviewsData.fromJson,
    );
  }

  /// GET /talents/{id}/reviews — public reviews for a talent
  Future<TalentReviewsData> fetchTalentReviews(int talentId) async {
    return _api.get<TalentReviewsData>(
      ApiEndpoints.talentReviews(talentId),
      parser: TalentReviewsData.fromJson,
    );
  }

  /// PUT /users/profile — update user name & phone
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    await _api.put<void>(
      ApiEndpoints.userProfile,
      data: data,
      parser: (_) {},
    );
  }

  /// PUT /users/password — change password
  Future<void> updatePassword(Map<String, dynamic> data) async {
    await _api.put<void>(
      ApiEndpoints.userPassword,
      data: data,
      parser: (_) {},
    );
  }
}
