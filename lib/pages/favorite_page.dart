import 'package:flutter/material.dart';
import '../models/movie.dart';

class FavoritePage extends StatelessWidget {
  final List<Movie> favorites;

  const FavoritePage({Key? key, required this.favorites}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) {
      return const Center(child: Text("Favorite masih kosong"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final movie = favorites[index];
        return Card(
          child: ListTile(
            leading: Image.network(
              'https://image.tmdb.org/t/p/w200${movie.posterPath}',
            ),
            title: Text(
              '${movie.title} (${movie.year})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              movie.overview,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
    );
  }
}
