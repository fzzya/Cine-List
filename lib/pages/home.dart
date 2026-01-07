import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/movie.dart';
import '../services/movie_services.dart';
import 'favorite_page.dart';
import 'watchlist_page.dart';

const Color bgMain = Color(0xFFCEDAD2);
const Color cardBg = Color(0xFFFFFFFF);

const Color primary = Color(0xFF62B4CA);
const Color secondary = Color(0xFFB4D2D0);
const Color accent = Color(0xFF0784A5);

const Color textMain = Color(0xFF001936);
const Color textMuted = Color(0xFF4F6D7A);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final MovieService _movieService = MovieService();

  final List<Movie> watchlist = [];
  final List<Movie> favorites = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildMovieList() {
    return FutureBuilder<List<Movie>>(
      future: _movieService.getPopularMovies(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: accent),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return const Center(
            child: Text(
              'Terjadi kesalahan',
              style: TextStyle(color: textMuted),
            ),
          );
        }

        final movies = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: secondary),
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => _showMovieDetail(movie),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                          width: 90,
                          height: 130,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${movie.title} (${movie.year})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textMain,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              movie.overview,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: textMuted,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                IconButton(
                                  icon:
                                      const Icon(Icons.bookmark_border),
                                  color: accent,
                                  onPressed: () =>
                                      _addToWatchlist(movie),
                                ),
                                IconButton(
                                  icon:
                                      const Icon(Icons.favorite_border),
                                  color: accent,
                                  onPressed: () =>
                                      _addToFavorite(movie),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _addToWatchlist(Movie movie) {
    if (!watchlist.any((m) => m.id == movie.id)) {
      setState(() => watchlist.add(movie));
    }
  }

  void _addToFavorite(Movie movie) {
    if (!favorites.any((m) => m.id == movie.id)) {
      setState(() => favorites.add(movie));
    }
  }

  void _showMovieDetail(Movie movie) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    'https://image.tmdb.org/t/p/w300${movie.posterPath}',
                    height: 260,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                movie.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textMain,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tahun rilis: ${movie.year}',
                style: const TextStyle(color: textMuted),
              ),
              const SizedBox(height: 12),
              Text(
                movie.overview,
                style: const TextStyle(
                  color: textMain,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.bookmark),
                    label: const Text('Watchlist'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondary,
                      foregroundColor: textMain,
                    ),
                    onPressed: () {
                      _addToWatchlist(movie);
                      Navigator.pop(context);
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.favorite),
                    label: const Text('Favorite'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      _addToFavorite(movie);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgMain,
      appBar: AppBar(
        backgroundColor: bgMain,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'CineList',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textMain,
            letterSpacing: 1,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: accent),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: accent,
          labelColor: accent,
          unselectedLabelColor: textMuted,
          tabs: const [
            Tab(text: 'Movies'),
            Tab(text: 'Watchlist'),
            Tab(text: 'Favorites'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMovieList(),
          WatchlistPage(
            watchlist: watchlist,
            onRemove: (movie) {
              setState(() {
                watchlist.removeWhere((m) => m.id == movie.id);
              });
            },
          ),
          FavoritePage(
            favorites: favorites,
            onRemove: (movie) {
              setState(() {
                favorites.removeWhere((m) => m.id == movie.id);
              });
            },
          ),
        ],
      ),
    );
  }
}
