import 'package:caritalent_mobile/core/constants/api_endpoints.dart';
import 'package:caritalent_mobile/core/network/api_client.dart';
import 'package:caritalent_mobile/features/dashboard/domain/invitation_model.dart';

class InvitationRepository {
  const InvitationRepository(this._api);
  final ApiClient _api;

  /// GET /invitations/my — talent's received invitations
  Future<List<InvitationModel>> fetchMyInvitations() async {
    return _api.get<List<InvitationModel>>(
      ApiEndpoints.myInvitations,
      parser: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['invitations'] as List<dynamic>? ?? [];
        return list.map((e) => InvitationModel.fromJson(e)).toList();
      },
    );
  }

  /// GET /invitations/sent — EO's sent invitations
  Future<List<InvitationModel>> fetchSentInvitations() async {
    return _api.get<List<InvitationModel>>(
      ApiEndpoints.sentInvitations,
      parser: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['invitations'] as List<dynamic>? ?? [];
        return list.map((e) => InvitationModel.fromJson(e)).toList();
      },
    );
  }

  /// PUT /invitations/{id}/respond — talent accepts or rejects invitation
  Future<void> respondInvitation({
    required int id,
    required String status, // 'accepted' | 'rejected'
  }) async {
    await _api.put<void>(
      ApiEndpoints.respondInvitation(id),
      data: {'status': status},
      parser: (_) {},
    );
  }

  /// POST /invitations — EO sends invitation to a talent
  Future<void> sendInvitation({
    required int eventId,
    required int talentId,
    required double offeredPrice,
  }) async {
    await _api.post<void>(
      ApiEndpoints.invitations,
      data: {
        'event_id': eventId,
        'talent_id': talentId,
        'offered_price': offeredPrice.toInt(),
      },
      parser: (_) {},
    );
  }
}
