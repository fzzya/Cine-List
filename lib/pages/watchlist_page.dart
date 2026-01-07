import 'package:flutter/material.dart';
import '../models/movie.dart';

const Color bgMain = Color(0xFFCEDAD2);
const Color cardBg = Color(0xFFFFFFFF);

const Color primary = Color(0xFF62B4CA);
const Color secondary = Color(0xFFB4D2D0);
const Color accent = Color(0xFF0784A5);

const Color textMain = Color(0xFF001936);
const Color textMuted = Color(0xFF4F6D7A);

class WatchlistPage extends StatelessWidget {
  final List<Movie> watchlist;
  final ValueChanged<Movie> onRemove;

  const WatchlistPage({
    super.key,
    required this.watchlist,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (watchlist.isEmpty) {
      return const _EmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: watchlist.length,
      itemBuilder: (context, index) {
        final movie = watchlist[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: secondary),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.12),
                blurRadius: 18,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                width: 60,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              '${movie.title} (${movie.year})',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: textMain,
              ),
            ),
            subtitle: Text(
              movie.overview,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: textMuted),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              color: accent,
              tooltip: 'Hapus dari watchlist',
              onPressed: () => _confirmRemove(context, movie),
            ),
          ),
        );
      },
    );
  }

  void _confirmRemove(BuildContext context, Movie movie) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Watchlist'),
        content: const Text(
          'Film ini akan dihapus dari watchlist.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              onRemove(movie);
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.bookmark_border,
              size: 72,
              color: secondary,
            ),
            SizedBox(height: 16),
            Text(
              'Watchlist masih kosong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textMain,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Simpan film yang ingin kamu tonton\nagar tidak terlupa',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: textMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
