import 'package:caritalent_mobile/core/constants/api_endpoints.dart';
import 'package:caritalent_mobile/core/network/api_client.dart';
import 'package:caritalent_mobile/features/dashboard/domain/genre_model.dart';

class GenreRepository {
  const GenreRepository(this._api);
  final ApiClient _api;

  /// GET /genres — public genre list.
  Future<List<GenreModel>> fetchGenres() async {
    return _api.getRaw<List<GenreModel>>(
      ApiEndpoints.genres,
      parser: _parseGenreList,
    );
  }

  static List<GenreModel> _parseGenreList(Object? json) {
    Object? raw = json;

    if (raw is Map<String, dynamic>) {
      final message = raw['message'];
      final data = raw['data'];
      raw = raw['genres'] ??
          (message is Map<String, dynamic> ? message['genres'] : null) ??
          (data is Map<String, dynamic> ? data['genres'] : null) ??
          (data is List ? data : null);
    }

    if (raw is! List) return [];

    return raw
        .map(GenreModel.fromJson)
        .where((genre) => genre.id > 0 && genre.name.isNotEmpty)
        .toList();
  }
}
