import 'package:caritalent_mobile/features/dashboard/domain/talent_model.dart';

class ScoreBreakdown {
  final int genreScore;
  final int budgetScore;
  final int locationScore;

  const ScoreBreakdown({
    required this.genreScore,
    required this.budgetScore,
    required this.locationScore,
  });

  factory ScoreBreakdown.fromJson(Map<String, dynamic> map) {
    return ScoreBreakdown(
      genreScore: map['genre_score'] as int? ?? 0,
      budgetScore: map['budget_score'] as int? ?? 0,
      locationScore: map['location_score'] as int? ?? 0,
    );
  }
}

class RecommendationModel {
  final int rank;
  final int score;
  final ScoreBreakdown scoreBreakdown;
  final TalentModel talent;
  final bool isInvited;
  final String? invitationStatus;

  const RecommendationModel({
    required this.rank,
    required this.score,
    required this.scoreBreakdown,
    required this.talent,
    this.isInvited = false,
    this.invitationStatus,
  });

  factory RecommendationModel.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    final invitation = map['invitation'];
    final invitationMap =
        invitation is Map<String, dynamic> ? invitation : null;
    final invitationStatus = (map['invitation_status'] ??
            map['invite_status'] ??
            map['invited_status'] ??
            map['application_status'] ??
            invitationMap?['status'])
        ?.toString();
    final normalizedInvitationStatus = invitationStatus?.trim().toLowerCase();
    final hasInvitation = _readBool(map['is_invited']) ||
        _readBool(map['invited']) ||
        _readBool(map['already_invited']) ||
        _readBool(map['has_invitation']) ||
        _readBool(map['invitation_sent']) ||
        _readBool(map['has_been_invited']) ||
        invitationStatus != null ||
        map['invitation_id'] != null ||
        map['invited_at'] != null ||
        invitationMap != null;

    return RecommendationModel(
      rank: map['rank'] as int? ?? 0,
      score: map['score'] as int? ?? 0,
      scoreBreakdown: map['score_breakdown'] != null
          ? ScoreBreakdown.fromJson(
              map['score_breakdown'] as Map<String, dynamic>)
          : const ScoreBreakdown(
              genreScore: 0, budgetScore: 0, locationScore: 0),
      talent: TalentModel.fromJson(map['talent']),
      isInvited: hasInvitation &&
          normalizedInvitationStatus != 'rejected' &&
          normalizedInvitationStatus != 'cancelled' &&
          normalizedInvitationStatus != 'canceled',
      invitationStatus: invitationStatus,
    );
  }

  RecommendationModel copyWith({bool? isInvited}) {
    return RecommendationModel(
      rank: rank,
      score: score,
      scoreBreakdown: scoreBreakdown,
      talent: talent,
      isInvited: isInvited ?? this.isInvited,
      invitationStatus: invitationStatus,
    );
  }
}

bool _readBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    switch (value.trim().toLowerCase()) {
      case 'true':
      case '1':
      case 'yes':
      case 'ya':
      case 'sudah':
        return true;
      default:
        return false;
    }
  }
  return false;
}

class RecommendationsData {
  final int eventId;
  final String eventTitle;
  final List<RecommendationModel> recommendations;
  final Set<int> invitedTalentIds;

  const RecommendationsData({
    required this.eventId,
    required this.eventTitle,
    required this.recommendations,
    this.invitedTalentIds = const {},
  });

  factory RecommendationsData.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    final invitationSources = [
      map['invited_talent_ids'],
      map['already_invited_talent_ids'],
      map['invited_talent_user_ids'],
      map['invitedTalents'],
      map['invited_talents'],
      map['sent_invitations'],
      map['invitations'],
      map['applications'],
    ];

    return RecommendationsData(
      eventId: _readInt(map['event_id']) ?? 0,
      eventTitle: map['event_title'] as String? ?? '',
      recommendations: (map['recommendations'] as List<dynamic>?)
              ?.map((e) => RecommendationModel.fromJson(e))
              .toList() ??
          [],
      invitedTalentIds: {
        for (final source in invitationSources) ..._parseTalentIds(source),
      },
    );
  }
}

Set<int> _parseTalentIds(Object? raw) {
  if (raw == null) return {};
  if (raw is List) {
    return {
      for (final item in raw) ..._parseTalentIds(item),
    };
  }
  if (raw is num) return {raw.toInt()};
  if (raw is String) {
    final parsed = int.tryParse(raw);
    return parsed == null ? {} : {parsed};
  }
  if (raw is Map<String, dynamic>) {
    final talent = raw['talent'];
    final isInvitationLike = talent is Map<String, dynamic> ||
        raw.containsKey('event_id') ||
        raw.containsKey('offered_price') ||
        raw.containsKey('proposed_price');
    return {
      if (_readInt(raw['talent_id']) != null) _readInt(raw['talent_id'])!,
      if (_readInt(raw['talent_user_id']) != null)
        _readInt(raw['talent_user_id'])!,
      if (_readInt(raw['user_id']) != null) _readInt(raw['user_id'])!,
      if (talent is Map<String, dynamic>) ..._parseTalentIds(talent),
      if (!isInvitationLike && _readInt(raw['id']) != null)
        _readInt(raw['id'])!,
    };
  }
  return {};
}

int? _readInt(Object? value) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
