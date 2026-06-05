import 'package:caritalent_mobile/features/dashboard/domain/talent_model.dart';
import 'package:caritalent_mobile/features/dashboard/domain/event_model.dart';

class ApplicationModel {
  final int id;
  final String source; // 'apply' | 'invitation'
  final String? message;
  final double? proposedPrice;
  final String status; // 'pending' | 'accepted' | 'rejected'
  final String createdAt;
  final TalentModel? talent;
  final EventModel? event;

  const ApplicationModel({
    required this.id,
    required this.source,
    this.message,
    this.proposedPrice,
    required this.status,
    required this.createdAt,
    this.talent,
    this.event,
  });

  factory ApplicationModel.fromJson(Object? json) {
    final map = json as Map<String, dynamic>;
    return ApplicationModel(
      id: (map['id'] as num?)?.toInt() ?? 0,
      source: map['source'] as String? ?? 'apply',
      message: map['message'] as String?,
      proposedPrice: map['proposed_price'] != null
          ? double.tryParse(map['proposed_price'].toString())
          : null,
      status: map['status'] as String? ?? 'pending',
      createdAt: map['created_at'] as String? ?? '',
      talent: map['talent'] != null
          ? TalentModel.fromJson(map['talent'])
          : null,
      event: map['event'] != null ? EventModel.fromJson(map['event']) : null,
    );
  }

  String get priceFormatted {
    if (proposedPrice == null) return '-';
    final n = proposedPrice!.toInt();
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
}
