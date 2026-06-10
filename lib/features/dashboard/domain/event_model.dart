class EventModel {
  final int id;
  final int organizerId;
  final String title;
  final String description;
  final double budget;
  final String eventDate;
  final String venueName;
  final String city;
  final String status;
  final List<String> genres;
  final int totalApplicants;
  final double? latitude;
  final double? longitude;

  const EventModel({
    required this.id,
    required this.organizerId,
    required this.title,
    required this.description,
    required this.budget,
    required this.eventDate,
    required this.venueName,
    required this.city,
    required this.status,
    required this.genres,
    required this.totalApplicants,
    this.latitude,
    this.longitude,
  });

  factory EventModel.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;

    // Genre bisa berupa List<String> atau List<Map> (dengan field 'name')
    List<String> parseGenres(dynamic raw) {
      if (raw == null) return [];
      final list = raw as List<dynamic>;
      return list.map((e) {
        if (e is Map<String, dynamic>) {
          return e['name']?.toString() ?? '';
        }
        return e.toString();
      }).where((s) => s.isNotEmpty).toList();
    }

    return EventModel(
      // 'id' bisa int atau null, fallback 0
      id: (map['id'] as num?)?.toInt() ?? 0,
      organizerId: (map['organizer_id'] as num?)?.toInt() ?? 0,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      budget: double.tryParse(map['budget']?.toString() ?? '0') ?? 0,
      eventDate: map['event_date'] as String? ?? '',
      venueName: map['venue_name'] as String? ?? '',
      city: map['city'] as String? ?? '',
      status: map['status'] as String? ?? '',
      // 'genres' adalah relasi many-to-many → List<Map>, atau kadang List<String>
      genres: parseGenres(map['genres'] ?? map['genre_needed']),
      totalApplicants: (map['total_applicants'] as num?)?.toInt() ?? 0,
      latitude: map['latitude'] != null
          ? double.tryParse(map['latitude'].toString())
          : null,
      longitude: map['longitude'] != null
          ? double.tryParse(map['longitude'].toString())
          : null,
    );
  }

  String get budgetFormatted {
    final n = budget.toInt();
    final s = n
        .toString()
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return 'Rp $s';
  }

  /// Status dari API: 'open', 'closed', 'draft', 'cancelled', 'completed'
  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'open':
        return 'Open';
      case 'closed':
        return 'Closed';
      case 'draft':
        return 'Draft';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  bool get isOpen => status.toLowerCase() == 'open';
}
