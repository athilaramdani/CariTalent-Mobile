class TalentModel {
  final int id;
  final int userId;
  final String? fullName;
  final String? email;
  final String? phone;
  final String stageName;
  final List<String> genre;
  final double? priceMin;
  final double? priceMax;
  final String city;
  final String? bio;
  final String? portfolioLink;
  final bool verified;
  final double averageRating;
  final int totalReviews;

  const TalentModel({
    required this.id,
    required this.userId,
    this.fullName,
    this.email,
    this.phone,
    required this.stageName,
    required this.genre,
    this.priceMin,
    this.priceMax,
    required this.city,
    this.bio,
    this.portfolioLink,
    required this.verified,
    required this.averageRating,
    required this.totalReviews,
  });

  factory TalentModel.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    final user = map['user'] is Map<String, dynamic>
        ? map['user'] as Map<String, dynamic>
        : null;

    // Genre bisa List<String> atau List<Map> dengan field 'name'
    List<String> parseGenres(dynamic raw) {
      if (raw == null) return [];
      return (raw as List<dynamic>).map((e) {
        if (e is Map<String, dynamic>) return e['name']?.toString() ?? '';
        return e.toString();
      }).where((s) => s.isNotEmpty).toList();
    }

    return TalentModel(
      id: (map['id'] as num?)?.toInt() ?? 0,
      userId: (map['user_id'] as num?)?.toInt() ??
          (user?['id'] as num?)?.toInt() ??
          0,
      fullName: (map['name'] ?? map['full_name'] ?? user?['name'])?.toString(),
      email: (map['email'] ?? user?['email'])?.toString(),
      phone:
          (map['phone'] ?? map['phone_number'] ?? map['no_hp'] ?? user?['phone'])
              ?.toString(),
      stageName:
          (map['stage_name'] ?? map['name'] ?? user?['name'])?.toString() ?? '',
      genre: parseGenres(map['genre'] ?? map['genres']),
      priceMin: map['price_min'] != null
          ? double.tryParse(map['price_min'].toString())
          : null,
      priceMax: map['price_max'] != null
          ? double.tryParse(map['price_max'].toString())
          : null,
      city: map['city'] as String? ?? '',
      bio: map['bio'] as String?,
      portfolioLink: map['portfolio_link'] as String?,
      verified: map['verified'] == true || map['verified'] == 1,
      averageRating:
          double.tryParse(map['average_rating']?.toString() ?? '0') ?? 0,
      totalReviews: (map['total_reviews'] as num?)?.toInt() ?? 0,
    );
  }

  String get priceRangeFormatted {
    final min = priceMin != null ? _formatCurrency(priceMin!) : null;
    final max = priceMax != null ? _formatCurrency(priceMax!) : null;
    if (min != null && max != null) return '$min - $max';
    if (min != null) return 'Ab $min';
    if (max != null) return 'Max $max';
    return 'Harga belum diatur';
  }

  String _formatCurrency(double amount) {
    final n = amount.toInt();
    final s = n
        .toString()
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return 'Rp $s';
  }
}
