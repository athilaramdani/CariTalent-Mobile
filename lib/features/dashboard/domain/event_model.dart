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
  final String? organizerName;
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
    this.organizerName,
    this.latitude,
    this.longitude,
  });

  factory EventModel.fromJson(Object? json) {
    if (json == null || json is! Map<String, dynamic>) {
      return const EventModel(
        id: 0,
        organizerId: 0,
        title: '',
        description: '',
        budget: 0,
        eventDate: '',
        venueName: '',
        city: '',
        status: '',
        genres: [],
        organizerName: null,
        totalApplicants: 0,
      );
    }
    final map = json;

    // Genre bisa berupa List<String> atau List<Map> (dengan field 'name')
    List<String> parseGenres(dynamic raw) {
      if (raw == null || raw is! List) return [];
      final list = raw;
      return list.map((e) {
        if (e is Map<String, dynamic>) {
          return e['name']?.toString() ?? '';
        }
        return e?.toString() ?? '';
      }).where((s) => s.isNotEmpty).toList();
    }

    return EventModel(
      id: (map['id'] as num?)?.toInt() ?? 0,
      organizerId: (map['organizer_id'] as num?)?.toInt() ?? 0,
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      budget: double.tryParse(map['budget']?.toString() ?? '0') ?? 0,
      eventDate: map['event_date']?.toString() ?? '',
      venueName: map['venue_name']?.toString() ?? '',
      city: map['city']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
      genres: parseGenres(map['genres'] ?? map['genre_needed']),
      organizerName: map['organizer_name']?.toString() ?? map['organizer']?['name']?.toString(),
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

  /// Status dari API: 'dibuka', 'ditutup', 'selesai', 'dibatalkan'
  /// atau status lama app: 'open', 'closed', 'cancelled', 'completed'.
  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'open':
      case 'dibuka':
        return 'Open';
      case 'closed':
      case 'ditutup':
        return 'Closed';
      case 'draft':
        return 'Draft';
      case 'completed':
      case 'selesai':
        return 'Completed';
      case 'cancelled':
      case 'canceled':
      case 'dibatalkan':
        return 'Cancelled';
      default:
        return status;
    }
  }

  bool get isOpen {
    final value = status.toLowerCase();
    return value == 'open' || value == 'dibuka';
  }
}
