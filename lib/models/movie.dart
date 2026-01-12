class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String releaseDate;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.releaseDate,
  });

  // FROM API TMDB
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      overview: json['overview'],
      posterPath: json['poster_path'] ?? '',
      releaseDate: json['release_date'] ?? '',
    );
  }

  // TO FIRESTORE
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'posterPath': posterPath,
      'releaseDate': releaseDate,
      'createdAt': DateTime.now(),
    };
  }

  // FROM FIRESTORE
  factory Movie.fromFirestore(Map<String, dynamic> data) {
    return Movie(
      id: data['id'],
      title: data['title'],
      overview: data['overview'],
      posterPath: data['posterPath'],
      releaseDate: data['releaseDate'],
    );
  }

  // helper ambil tahun
  String get year {
    if (releaseDate.isEmpty) return '-';
    return releaseDate.split('-').first;
  }
}
