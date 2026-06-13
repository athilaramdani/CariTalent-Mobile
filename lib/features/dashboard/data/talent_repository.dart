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

  /// GET /talents — browse all public talent profiles (for EO)
  Future<List<TalentModel>> fetchTalentList({
    String? search,
    String? city,
    String? genre,
    int perPage = 50,
  }) async {
    final params = <String, dynamic>{'per_page': perPage};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (city != null && city.isNotEmpty) params['city'] = city;
    if (genre != null && genre.isNotEmpty) params['genre'] = genre;

    return _api.get<List<TalentModel>>(
      ApiEndpoints.talents,
      queryParameters: params,
      parser: (json) {
        if (json is List) {
          return json.map((e) => TalentModel.fromJson(e)).toList();
        }
        if (json is Map<String, dynamic>) {
          final list = (json['talents'] ?? json['data']) as List<dynamic>?;
          if (list != null) {
            return list.map((e) => TalentModel.fromJson(e)).toList();
          }
        }
        return [];
      },
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
