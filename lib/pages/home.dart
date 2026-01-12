import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/movie_services.dart';
import 'favorite_page.dart';
import 'watchlist_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cine_list/auth_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MovieService _movieService = MovieService();

  List<Movie> watchlist = [];
  List<Movie> favorites = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// LOAD DATA WATCHLIST & FAVORITE DARI FIRESTORE
  Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final watchSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('watchlist')
        .get();

    final favSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .get();

    setState(() {
      watchlist = watchSnap.docs
          .map((doc) => Movie.fromFirestore(doc.data()))
          .toList();

      favorites = favSnap.docs
          .map((doc) => Movie.fromFirestore(doc.data()))
          .toList();
    });
  }

  /// LIST MOVIE DARI API
  Widget buildMovieList() {
    return FutureBuilder<List<Movie>>(
      future: _movieService.getPopularMovies(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final movies = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => showMovieDetail(movie),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                          width: 90,
                          height: 130,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${movie.title} (${movie.year})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              movie.overview,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),

                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.bookmark_border),
                                  onPressed: () => addToWatchlist(movie),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.favorite_border),
                                  color: Colors.red,
                                  onPressed: () => addToFavorite(movie),
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

  /// TAMBAH KE WATCHLIST (FIRESTORE)
  Future<void> addToWatchlist(Movie movie) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('watchlist')
        .doc(movie.id.toString());

    await ref.set({
      'id': movie.id,
      'title': movie.title,
      'overview': movie.overview,
      'posterPath': movie.posterPath,
      'releaseDate': movie.releaseDate,
      'createdAt': Timestamp.now(),
    });

    if (!watchlist.any((m) => m.id == movie.id)) {
      setState(() => watchlist.add(movie));
    }
  }

  /// TAMBAH KE FAVORITE (FIRESTORE)
  Future<void> addToFavorite(Movie movie) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(movie.id.toString());

    await ref.set({
      'id': movie.id,
      'title': movie.title,
      'overview': movie.overview,
      'posterPath': movie.posterPath,
      'releaseDate': movie.releaseDate,
      'createdAt': Timestamp.now(),
    });

    if (!favorites.any((m) => m.id == movie.id)) {
      setState(() => favorites.add(movie));
    }
  }

  /// DETAIL MOVIE
  void showMovieDetail(Movie movie) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'https://image.tmdb.org/t/p/w300${movie.posterPath}',
                        height: 250,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Text(
                    'Tahun rilis: ${movie.year}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 10),

                  Text(movie.overview),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.bookmark),
                        label: const Text("Watchlist"),
                        onPressed: () {
                          addToWatchlist(movie);
                          Navigator.pop(context);
                        },
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.favorite),
                        label: const Text("Favorite"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () {
                          addToFavorite(movie);
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CineList',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFE50914),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              if (!context.mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
                (route) => false,
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Movies"),
            Tab(text: "Watchlist"),
            Tab(text: "Favorites"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildMovieList(),
          WatchlistPage(watchlist: watchlist),
          FavoritePage(favorites: favorites),
        ],
      ),
    );
  }
}
