import 'package:flutter/material.dart';
import '../models/movie.dart';

class WatchlistPage extends StatelessWidget {
  final List<Movie> watchlist;

  const WatchlistPage({Key? key, required this.watchlist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (watchlist.isEmpty) {
      return const Center(child: Text("Watchlist masih kosong"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: watchlist.length,
      itemBuilder: (context, index) {
        final movie = watchlist[index];
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
