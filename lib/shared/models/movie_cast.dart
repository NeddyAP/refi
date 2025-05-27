class CastMember {
  final int id;
  final String name;
  final String character;
  final String? profilePath;
  final int order;
  final bool adult;
  final int? gender;
  final String? knownForDepartment;
  final String? originalName;
  final double popularity;
  final int? castId;
  final String? creditId;

  const CastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
    required this.order,
    required this.adult,
    this.gender,
    this.knownForDepartment,
    this.originalName,
    required this.popularity,
    this.castId,
    this.creditId,
  });

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      id: json['id'] as int,
      name: json['name'] as String,
      character: json['character'] as String,
      profilePath: json['profile_path'] as String?,
      order: json['order'] as int,
      adult: json['adult'] as bool,
      gender: json['gender'] as int?,
      knownForDepartment: json['known_for_department'] as String?,
      originalName: json['original_name'] as String?,
      popularity: (json['popularity'] as num).toDouble(),
      castId: json['cast_id'] as int?,
      creditId: json['credit_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'character': character,
      'profile_path': profilePath,
      'order': order,
      'adult': adult,
      'gender': gender,
      'known_for_department': knownForDepartment,
      'original_name': originalName,
      'popularity': popularity,
      'cast_id': castId,
      'credit_id': creditId,
    };
  }

  /// Get full profile URL
  String? get fullProfileUrl {
    if (profilePath == null) return null;
    return 'https://image.tmdb.org/t/p/w185$profilePath';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CastMember && other.id == id && other.creditId == creditId;
  }

  @override
  int get hashCode => Object.hash(id, creditId);

  @override
  String toString() => 'CastMember(id: $id, name: $name, character: $character)';
}

class CrewMember {
  final int id;
  final String name;
  final String job;
  final String department;
  final String? profilePath;
  final bool adult;
  final int? gender;
  final String? knownForDepartment;
  final String? originalName;
  final double popularity;
  final String? creditId;

  const CrewMember({
    required this.id,
    required this.name,
    required this.job,
    required this.department,
    this.profilePath,
    required this.adult,
    this.gender,
    this.knownForDepartment,
    this.originalName,
    required this.popularity,
    this.creditId,
  });

  factory CrewMember.fromJson(Map<String, dynamic> json) {
    return CrewMember(
      id: json['id'] as int,
      name: json['name'] as String,
      job: json['job'] as String,
      department: json['department'] as String,
      profilePath: json['profile_path'] as String?,
      adult: json['adult'] as bool,
      gender: json['gender'] as int?,
      knownForDepartment: json['known_for_department'] as String?,
      originalName: json['original_name'] as String?,
      popularity: (json['popularity'] as num).toDouble(),
      creditId: json['credit_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'job': job,
      'department': department,
      'profile_path': profilePath,
      'adult': adult,
      'gender': gender,
      'known_for_department': knownForDepartment,
      'original_name': originalName,
      'popularity': popularity,
      'credit_id': creditId,
    };
  }

  /// Get full profile URL
  String? get fullProfileUrl {
    if (profilePath == null) return null;
    return 'https://image.tmdb.org/t/p/w185$profilePath';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CrewMember && other.id == id && other.creditId == creditId;
  }

  @override
  int get hashCode => Object.hash(id, creditId);

  @override
  String toString() => 'CrewMember(id: $id, name: $name, job: $job)';
}

class MovieCreditsResponse {
  final int id;
  final List<CastMember> cast;
  final List<CrewMember> crew;

  const MovieCreditsResponse({
    required this.id,
    required this.cast,
    required this.crew,
  });

  factory MovieCreditsResponse.fromJson(Map<String, dynamic> json) {
    return MovieCreditsResponse(
      id: json['id'] as int,
      cast: (json['cast'] as List<dynamic>)
          .map((cast) => CastMember.fromJson(cast as Map<String, dynamic>))
          .toList(),
      crew: (json['crew'] as List<dynamic>)
          .map((crew) => CrewMember.fromJson(crew as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cast': cast.map((member) => member.toJson()).toList(),
      'crew': crew.map((member) => member.toJson()).toList(),
    };
  }

  /// Get top billed cast (first 10)
  List<CastMember> get topBilledCast => cast.take(10).toList();

  /// Get director
  CrewMember? get director => crew.firstWhere(
        (member) => member.job.toLowerCase() == 'director',
        orElse: () => crew.first,
      );

  /// Get writers
  List<CrewMember> get writers => crew.where(
        (member) => member.department.toLowerCase() == 'writing',
      ).toList();

  /// Get producers
  List<CrewMember> get producers => crew.where(
        (member) => member.job.toLowerCase().contains('producer'),
      ).toList();
}