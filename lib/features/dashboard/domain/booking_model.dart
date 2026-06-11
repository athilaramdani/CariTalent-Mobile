class BookingModel {
  final int id;
  final int applicationId;
  final String source;
  final Map<String, dynamic>? event;
  final Map<String, dynamic>? talent;
  final double agreedPrice;
  final String status;
  final String createdAt;

  const BookingModel({
    required this.id,
    required this.applicationId,
    required this.source,
    this.event,
    this.talent,
    required this.agreedPrice,
    required this.status,
    required this.createdAt,
  });

  factory BookingModel.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return BookingModel(
      id: (map['id'] as num?)?.toInt() ?? 0,
      applicationId: (map['application_id'] as num?)?.toInt() ?? 0,
      source: map['source'] as String? ?? '',
      event: map['event'] as Map<String, dynamic>?,
      talent: map['talent'] as Map<String, dynamic>?,
      agreedPrice:
          double.tryParse(map['agreed_price']?.toString() ?? '0') ?? 0,
      status: map['status'] as String? ?? '',
      createdAt: map['created_at'] as String? ?? '',
    );
  }

  String get eventTitle => (event?['title'] as String?) ?? '';
  String get eventDate => (event?['event_date'] as String?) ?? '';
  String get eventVenue => (event?['venue_name'] as String?) ?? '';
  double? get eventLat => event?['latitude'] != null
      ? double.tryParse(event!['latitude'].toString())
      : null;
  double? get eventLng => event?['longitude'] != null
      ? double.tryParse(event!['longitude'].toString())
      : null;
  String get eventDescription => (event?['description'] as String?) ?? '';
  String get eventCity => (event?['city'] as String?) ?? '';
  String? get organizerName => (event?['organizer_name'] as String?) ?? (event?['organizer']?['name'] as String?);
  int? get organizerId => (event?['organizer_id'] as num?)?.toInt();

  String get talentName => (talent?['stage_name'] as String?) ?? '';

  String get agreedPriceFormatted {
    final n = agreedPrice.toInt();
    final s = n
        .toString()
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return 'Rp $s';
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

  String get eventDateVenueFormatted {
    final date = eventDate.isNotEmpty ? _fmtDate(eventDate) : '-';
    final venue = eventVenue.isNotEmpty ? eventVenue : '';
    if (venue.isNotEmpty) return '$date • $venue';
    return date;
  }

  String _fmtDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  String get sourceLabel =>
      source == 'invitation' ? 'Dari invitation' : 'Apply langsung';

  String get statusCapitalized =>
      status.isNotEmpty ? '${status[0].toUpperCase()}${status.substring(1)}' : '';
}
