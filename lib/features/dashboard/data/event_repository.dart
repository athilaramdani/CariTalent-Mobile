import 'package:caritalent_mobile/core/constants/api_endpoints.dart';
import 'package:caritalent_mobile/core/network/api_client.dart';
import 'package:caritalent_mobile/features/dashboard/domain/event_model.dart';
import 'package:caritalent_mobile/features/dashboard/domain/application_model.dart';
import 'package:caritalent_mobile/features/dashboard/domain/recommendation_model.dart';

class EventRepository {
  const EventRepository(this._api);
  final ApiClient _api;

  /// GET /events — public list, supports filters
  Future<List<EventModel>> fetchPublicEvents({
    String? status,
    String? city,
    String? search,
    String? genre,
    int? budgetMin,
    int? budgetMax,
    String? dateFrom,
    String? dateTo,
    int perPage = 50,
  }) async {
    final params = <String, dynamic>{'per_page': perPage};
    if (status != null && status.isNotEmpty) params['status'] = status;
    if (city != null && city.isNotEmpty) params['city'] = city;
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (genre != null && genre.isNotEmpty) params['genre'] = genre;
    if (budgetMin != null) params['budget_min'] = budgetMin;
    if (budgetMax != null) params['budget_max'] = budgetMax;
    if (dateFrom != null && dateFrom.isNotEmpty) params['date_from'] = dateFrom;
    if (dateTo != null && dateTo.isNotEmpty) params['date_to'] = dateTo;

    return _api.get<List<EventModel>>(
      ApiEndpoints.events,
      queryParameters: params,
      parser: (json) => _parseEventList(json),
    );
  }

  /// GET /events/my — EO's own events
  Future<List<EventModel>> fetchMyEvents() async {
    return _api.get<List<EventModel>>(
      ApiEndpoints.myEvents,
      parser: (json) => _parseEventList(json),
    );
  }

  /// Handles response shapes:
  ///   - { events: [...] }   ← API /events/my
  ///   - { data: [...] }     ← some APIs
  ///   - [...]               ← direct list
  static List<EventModel> _parseEventList(Object? json) {
    if (json is List) {
      return json.map((e) => EventModel.fromJson(e)).toList();
    }
    if (json is Map<String, dynamic>) {
      final list = (json['events'] ?? json['data']) as List<dynamic>?;
      if (list != null) {
        return list.map((e) => EventModel.fromJson(e)).toList();
      }
    }
    return [];
  }

  /// POST /events — create new event
  Future<void> createEvent({
    required String title,
    required String description,
    required int budget,
    required String eventDate,
    required String venueName,
    required String city,
    required String status,
    required List<String> genre,
    double? latitude,
    double? longitude,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'description': description,
      'budget': budget,
      'event_date': eventDate,
      'venue_name': venueName,
      'city': city,
      'status': status,
      'genre': genre,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
    await _api.post<void>(
      ApiEndpoints.events,
      data: body,
      parser: (_) {},
    );
  }

  /// PUT /events/{id} — update event
  Future<void> updateEvent(int id, Map<String, dynamic> data) async {
    await _api.put<void>(
      ApiEndpoints.updateEvent(id),
      data: data,
      parser: (_) {},
    );
  }

  /// DELETE /events/{id} — cancel event (soft delete)
  Future<void> cancelEvent(int id) async {
    await _api.delete<void>(
      ApiEndpoints.deleteEvent(id),
      parser: (_) {},
    );
  }

  /// GET /events/{id}/applications — applicants for an EO event
  Future<List<ApplicationModel>> fetchEventApplications(
    int eventId, {
    String? status,
    String? source,
  }) async {
    final params = <String, dynamic>{};
    if (status != null && status.isNotEmpty) params['status'] = status;
    if (source != null && source.isNotEmpty) params['source'] = source;

    return _api.get<List<ApplicationModel>>(
      ApiEndpoints.eventApplications(eventId),
      queryParameters: params,
      parser: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['applications'] as List<dynamic>? ?? [];
        return list.map((e) => ApplicationModel.fromJson(e)).toList();
      },
    );
  }

  /// GET /events/{id}/recommendations
  Future<RecommendationsData> fetchRecommendations(int eventId) async {
    return _api.get<RecommendationsData>(
      ApiEndpoints.eventRecommendations(eventId),
      parser: RecommendationsData.fromJson,
    );
  }
}
