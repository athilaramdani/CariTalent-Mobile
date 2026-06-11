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

  const RecommendationModel({
    required this.rank,
    required this.score,
    required this.scoreBreakdown,
    required this.talent,
    this.isInvited = false,
  });

  factory RecommendationModel.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return RecommendationModel(
      rank: map['rank'] as int? ?? 0,
      score: map['score'] as int? ?? 0,
      scoreBreakdown: map['score_breakdown'] != null
          ? ScoreBreakdown.fromJson(
              map['score_breakdown'] as Map<String, dynamic>)
          : const ScoreBreakdown(
              genreScore: 0, budgetScore: 0, locationScore: 0),
      talent: TalentModel.fromJson(map['talent']),
      isInvited: map['is_invited'] == true || map['is_invited'] == 1,
    );
  }

  RecommendationModel copyWith({bool? isInvited}) {
    return RecommendationModel(
      rank: rank,
      score: score,
      scoreBreakdown: scoreBreakdown,
      talent: talent,
      isInvited: isInvited ?? this.isInvited,
    );
  }
}

class RecommendationsData {
  final int eventId;
  final String eventTitle;
  final List<RecommendationModel> recommendations;

  const RecommendationsData({
    required this.eventId,
    required this.eventTitle,
    required this.recommendations,
  });

  factory RecommendationsData.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return RecommendationsData(
      eventId: map['event_id'] as int? ?? 0,
      eventTitle: map['event_title'] as String? ?? '',
      recommendations: (map['recommendations'] as List<dynamic>?)
              ?.map((e) => RecommendationModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
