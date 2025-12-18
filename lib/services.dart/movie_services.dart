import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class MovieService {
  static const String _apiKey = 'b8cd2eac32fc13f5b3a756d3b18b07ed';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  Future<List<Movie>> getPopularMovies() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/popular?api_key=$_apiKey&language=en-US'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List)
          .map((movie) => Movie.fromJson(movie))
          .toList();
    } else {
      throw Exception('Failed to load movies');
    }
  }
}
