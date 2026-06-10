import 'package:caritalent_mobile/features/dashboard/domain/talent_model.dart';

class InvitationModel {
  final int id;
  final Map<String, dynamic>? event;
  final TalentModel? talent;
  final double? offeredPrice;
  final double? proposedPrice;
  final String status;
  final String createdAt;

  const InvitationModel({
    required this.id,
    this.event,
    this.talent,
    this.offeredPrice,
    this.proposedPrice,
    required this.status,
    required this.createdAt,
  });

  factory InvitationModel.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return InvitationModel(
      id: (map['id'] as num?)?.toInt() ?? 0,
      event: map['event'] as Map<String, dynamic>?,
      talent: map['talent'] != null ? TalentModel.fromJson(map['talent']) : null,
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

  String get eventTitle => (event?['title'] as String?) ?? '';
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
