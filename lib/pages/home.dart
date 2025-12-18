import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services.dart/movie_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MovieService _movieService = MovieService();

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
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            return ListTile(
              leading: Image.network(
                'https://image.tmdb.org/t/p/w200${movie.posterPath}',
              ),
              title: Text(movie.title),
              subtitle: Text(
                movie.overview,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
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
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFE50914),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Movies"),
            Tab(text: "TV Shows"),
            Tab(text: "Favorites"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildMovieList(),
          buildPlaceholder("TV Shows"), // dummy
          buildPlaceholder("Favorites"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFE50914),
        child: const Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }
}
