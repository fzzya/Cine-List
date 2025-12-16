import 'package:flutter/material.dart';
// import '../widgets/movie_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  Widget buildEvenetList(BuildContext context, String category) {
    return Center(child: Text(category));
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
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Movies"),
            Tab(text: "TV Shows"),
            Tab(text: "Favorites"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildEvenetList(context, "Movies"),
          buildEvenetList(context, "TV Shows"),
          buildEvenetList(context, "Favorites"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFE50914),
        child: const Icon(Icons.add),
        onPressed: () {
          // Implement search functionality here
        },
      ),
    );
  }
}
