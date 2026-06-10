class ReviewModel {
  final int id;
  final String organizerName;
  final String eventTitle;
  final int rating;
  final String? comment;
  final String createdAt;

  const ReviewModel({
    required this.id,
    required this.organizerName,
    required this.eventTitle,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return ReviewModel(
      id: map['id'] as int,
      organizerName: map['organizer_name'] as String? ?? '',
      eventTitle: map['event_title'] as String? ?? '',
      rating: map['rating'] as int? ?? 0,
      comment: map['comment'] as String?,
      createdAt: map['created_at'] as String? ?? '',
    );
  }

  String get dateFormatted {
    if (createdAt.isEmpty) return '';
    try {
      final dt = DateTime.parse(createdAt);
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return createdAt;
    }
  }
}

class TalentReviewsData {
  final int talentId;
  final String stageName;
  final double averageRating;
  final int totalReviews;
  final List<ReviewModel> reviews;

  const TalentReviewsData({
    required this.talentId,
    required this.stageName,
    required this.averageRating,
    required this.totalReviews,
    required this.reviews,
  });

  factory TalentReviewsData.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return TalentReviewsData(
      talentId: map['talent_id'] as int? ?? 0,
      stageName: map['stage_name'] as String? ?? '',
      averageRating:
          double.tryParse(map['average_rating']?.toString() ?? '0') ?? 0,
      totalReviews: map['total_reviews'] as int? ?? 0,
      reviews: (map['reviews'] as List<dynamic>?)
              ?.map((e) => ReviewModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
