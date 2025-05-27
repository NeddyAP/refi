class Genre {
  final int id;
  final String name;

  const Genre({
    required this.id,
    required this.name,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Genre && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() => 'Genre(id: $id, name: $name)';
}

class GenreResponse {
  final List<Genre> genres;

  const GenreResponse({required this.genres});

  factory GenreResponse.fromJson(Map<String, dynamic> json) {
    return GenreResponse(
      genres: (json['genres'] as List<dynamic>)
          .map((genre) => Genre.fromJson(genre as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'genres': genres.map((genre) => genre.toJson()).toList(),
    };
  }
}
