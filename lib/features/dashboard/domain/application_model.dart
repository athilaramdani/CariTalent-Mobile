import 'package:caritalent_mobile/features/dashboard/domain/talent_model.dart';
import 'package:caritalent_mobile/features/dashboard/domain/event_model.dart';

class ApplicationModel {
  final int id;
  final int? eventId;
  final String source; // 'apply' | 'invitation'
  final String? message;
  final double? proposedPrice;
  final String status; // 'pending' | 'accepted' | 'rejected'
  final String createdAt;
  final TalentModel? talent;
  final EventModel? event;

  const ApplicationModel({
    required this.id,
    this.eventId,
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
    final invitation = map['invitation'];
    final source =
        (map['source'] ?? map['apply_method'] ?? map['application_source'])
                ?.toString() ??
            (invitation != null ? 'invitation' : 'apply');

    return ApplicationModel(
      id: (map['id'] as num?)?.toInt() ?? 0,
      eventId: _readInt(map['event_id']) ??
          _readInt((map['event'] as Map<String, dynamic>?)?['id']),
      source: source,
      message: (map['message'] ??
              map['description'] ??
              map['cover_letter'] ??
              map['application_message'])
          ?.toString(),
      proposedPrice: _readDouble(
        map['proposed_price'] ?? map['offered_price'] ?? map['price'],
      ),
      status: map['status']?.toString() ?? 'pending',
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

  String get sourceLabel {
    switch (source.trim().toLowerCase()) {
      case 'invitation':
      case 'invite':
      case 'undangan':
        return 'Undangan';
      case 'direct':
      case 'apply':
      case 'application':
      default:
        return 'Apply Langsung';
    }
  }

  bool get isDirectApply {
    final value = source.trim().toLowerCase();
    return value != 'invitation' && value != 'invite' && value != 'undangan';
  }
}

double? _readDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

int? _readInt(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}
