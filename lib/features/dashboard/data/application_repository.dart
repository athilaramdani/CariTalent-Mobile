import 'package:caritalent_mobile/core/constants/api_endpoints.dart';
import 'package:caritalent_mobile/core/network/api_client.dart';
import 'package:caritalent_mobile/features/dashboard/domain/application_model.dart';

class ApplicationRepository {
  const ApplicationRepository(this._api);
  final ApiClient _api;

  /// GET /applications/my — talent's own applications (source=apply)
  Future<List<ApplicationModel>> fetchMyApplications() async {
    return _api.get<List<ApplicationModel>>(
      ApiEndpoints.myApplications,
      parser: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['applications'] as List<dynamic>? ?? [];
        return list.map((e) => ApplicationModel.fromJson(e)).toList();
      },
    );
  }

  /// POST /applications — apply to an event
  Future<ApplicationModel> applyEvent({
    required int eventId,
    required double proposedPrice,
    String? message,
  }) async {
    final data = <String, dynamic>{
      'event_id': eventId,
      'proposed_price': proposedPrice,
      if (message != null && message.isNotEmpty) 'message': message,
    };
    return _api.post<ApplicationModel>(
      ApiEndpoints.applications,
      data: data,
      parser: ApplicationModel.fromJson,
    );
  }

  /// DELETE /applications/{id} — cancel application (talent)
  Future<void> cancelApplication(int id) async {
    await _api.delete<void>(
      ApiEndpoints.cancelApplication(id),
      parser: (_) {},
    );
  }

  /// PUT /applications/{id}/status — accept or reject application (EO)
  Future<void> updateApplicationStatus({
    required int id,
    required String status, // 'accepted' | 'rejected'
    double? agreedPrice,
  }) async {
    final data = <String, dynamic>{'status': status};
    if (agreedPrice != null) data['agreed_price'] = agreedPrice;

    await _api.put<void>(
      ApiEndpoints.applicationStatus(id),
      data: data,
      parser: (_) {},
    );
  }
}
