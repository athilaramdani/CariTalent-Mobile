import 'package:flutter/material.dart';

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
  final String address;
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
    required this.address,
    required this.status,
    required this.genres,
    required this.totalApplicants,
    this.organizerName,
    this.latitude,
    this.longitude,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as int,
      organizerId: _readInt(json['organizer_id'] ?? json['e_o_id']) ?? 0,
      title: json['title'] ?? json['event_name'] ?? 'Untitled Event',
      description: json['description'] ?? '',
      budget: _readDouble(json['budget'] ?? json['price'] ?? 0) ?? 0.0,
      eventDate: json['event_date'] ?? json['date'] ?? '',
      venueName: json['venue_name'] ?? json['venue'] ?? '',
      city: json['city'] ?? json['location'] ?? '',
      address: json['address'] ?? json['full_address'] ?? json['venue_address'] ?? '',
      status: json['status'] ?? 'open',
      genres: json['genres'] is List
          ? (json['genres'] as List).map((e) {
              if (e is Map && e.containsKey('name')) return e['name'].toString();
              return e.toString();
            }).toList()
          : [],
      totalApplicants: json['total_applicants'] ?? 0,
      organizerName: json['organizer_name'] ?? json['e_o_name'],
      latitude: _readDouble(json['latitude']),
      longitude: _readDouble(json['longitude']),
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
        return 'Dibuka';
      case 'closed':
      case 'ditutup':
        return 'Ditutup';
      case 'draft':
        return 'Konsep';
      case 'completed':
      case 'selesai':
        return 'Selesai';
      case 'cancelled':
      case 'canceled':
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        // Try to capitalize if unknown
        if (status.isEmpty) return 'Unknown';
        return status[0].toUpperCase() + status.substring(1).toLowerCase();
    }
  }

  /// Status colors for UI
  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'open':
      case 'dibuka':
        return const Color(0xFF4CAF50); // Green
      case 'closed':
      case 'ditutup':
        return const Color(0xFFF44336); // Red
      case 'completed':
      case 'selesai':
        return const Color(0xFFC48DF6); // Purple
      case 'cancelled':
      case 'canceled':
      case 'dibatalkan':
        return const Color(0xFF9E9E9E); // Grey
      default:
        return const Color(0xFF38BDF8); // Default Cyan
    }
  }

  bool get isClosed {
    final value = status.toLowerCase();
    return value == 'closed' || value == 'ditutup';
  }

  bool get isCompleted {
    final value = status.toLowerCase();
    return value == 'completed' || value == 'selesai';
  }

  bool get isOpen {
    final value = status.toLowerCase();
    return value == 'open' || value == 'dibuka';
  }

  String get organizerLabel {
    final name = organizerName?.trim();
    if (name != null && name.isNotEmpty) return name;
    if (organizerId > 0) return 'Organizer #$organizerId';
    return 'Organizer';
  }
}

int? _readInt(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? _readDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value * 1.0;
  return double.tryParse(value.toString());
}
