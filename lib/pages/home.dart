import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services.dart/movie_services.dart';
import 'favorite_page.dart';
import 'watchlist_page.dart';
import 'package:firebase_auth/firebase_auth.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MovieService _movieService = MovieService();
  // final FirestoreService firestoreService = FirestoreService();

  List<Movie> watchlist = [];
  List<Movie> favorites = [];

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
  color: const Color(0xFF111111),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
  ),
  elevation: 6,
  shadowColor: Colors.black54,
  margin: const EdgeInsets.only(bottom: 14),

              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => showMovieDetail(movie),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Poster
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

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                          '${movie.title} (${movie.year})',
                            style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          ),

                            const SizedBox(height: 6),
                            Text(
                            movie.overview,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              height: 1.4,
                            ),
                            ),
                            const SizedBox(height: 10),

                            // BUTTONS
                            Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.bookmark_border),
                                color: Colors.white,
                                onPressed: () => addToWatchlist(movie),
                              ),
                              IconButton(
                                icon: const Icon(Icons.favorite_border),
                                color: Colors.white,
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

  void addToWatchlist(Movie movie) async {
    if (!watchlist.any((m) => m.id == movie.id)) {
      setState(() => watchlist.add(movie));
    }
  }

  void addToFavorite(Movie movie) async {
    if (!favorites.any((m) => m.id == movie.id)) {
      setState(() => favorites.add(movie));
    }
  }

  void showMovieDetail(Movie movie) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
        backgroundColor: const Color(0xFF111111),
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
                    color: Colors.white,
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
                      icon: const Icon(Icons.bookmark, color: Colors.black),
                      label: const Text("Watchlist", style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      onPressed: () {
                        addToWatchlist(movie);
                        Navigator.pop(context);
                      },
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.favorite, color: Colors.black),
                      label: const Text("Favorite", style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
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

  Widget buildPlaceholder(String title) {
    return Center(child: Text(title, style: const TextStyle(fontSize: 18)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text(
    'CineList',
    style: TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white,
      letterSpacing: 1,
    ),
  ),
  backgroundColor: Colors.black,
  centerTitle: true,

  actions: [
    IconButton(
      icon: const Icon(Icons.logout, color: Colors.white),
      tooltip: 'Logout',
      onPressed: () async {
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
      },
    ),
  ],

  bottom: TabBar(
    controller: _tabController,
    indicatorColor: Colors.white,
    labelColor: Colors.white,
    unselectedLabelColor: Colors.grey,
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
