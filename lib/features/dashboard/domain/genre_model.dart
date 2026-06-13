class GenreModel {
  final int id;
  final String name;

  const GenreModel({
    required this.id,
    required this.name,
  });

  factory GenreModel.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      return const GenreModel(id: 0, name: '');
    }

    return GenreModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}
