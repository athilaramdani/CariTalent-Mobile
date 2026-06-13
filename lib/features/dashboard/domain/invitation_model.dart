import 'package:caritalent_mobile/features/dashboard/domain/talent_model.dart';

class InvitationModel {
  final int id;
  final int? eventId;
  final int? talentId;
  final String? eventTitleValue;
  final Map<String, dynamic>? event;
  final TalentModel? talent;
  final double? offeredPrice;
  final double? proposedPrice;
  final String status;
  final String createdAt;

  const InvitationModel({
    required this.id,
    this.eventId,
    this.talentId,
    this.eventTitleValue,
    this.event,
    this.talent,
    this.offeredPrice,
    this.proposedPrice,
    required this.status,
    required this.createdAt,
  });

  factory InvitationModel.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    final event = map['event'] as Map<String, dynamic>?;
    final talent = map['talent'] != null ? TalentModel.fromJson(map['talent']) : null;

    return InvitationModel(
      id: (map['id'] as num?)?.toInt() ?? 0,
      eventId: _readInt(map['event_id']) ?? _readInt(event?['id']),
      talentId: _readInt(map['talent_id']) ??
          _readInt(map['talent_user_id']) ??
          _readInt(map['user_id']) ??
          talent?.userId ??
          talent?.id,
      eventTitleValue: map['event_title']?.toString(),
      event: event,
      talent: talent,
      offeredPrice: map['offered_price'] != null
          ? double.tryParse(map['offered_price'].toString())
          : null,
      proposedPrice: map['proposed_price'] != null
          ? double.tryParse(map['proposed_price'].toString())
          : null,
      status: map['status'] as String? ?? 'pending',
      createdAt: map['created_at'] as String? ?? '',
    );
  }

  String get eventTitle =>
      event?['title']?.toString() ??
      event?['event_title']?.toString() ??
      eventTitleValue ??
      '';
  String get eventDate => (event?['event_date'] as String?) ?? '';
  String get eventVenue => (event?['venue_name'] as String?) ?? '';
  String get eventCity => (event?['city'] as String?) ?? '';
  double? get eventBudget => event?['budget'] != null
      ? double.tryParse(event!['budget'].toString())
      : null;

  String get offeredPriceFormatted {
    final price = offeredPrice ?? proposedPrice;
    if (price == null) return '-';
    final n = price.toInt();
    final s = n
        .toString()
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return 'Rp $s';
  }

  String get eventBudgetFormatted {
    if (eventBudget == null) return '-';
    final n = eventBudget!.toInt();
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

  String get eventDateFormatted {
    if (eventDate.isEmpty) return '-';
    try {
      final dt = DateTime.parse(eventDate);
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return eventDate;
    }
  }
}

int? _readInt(Object? value) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
