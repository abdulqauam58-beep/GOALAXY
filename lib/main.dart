import 'package:flutter/material.dart';

void main() {
  runApp(const GoalaxyApp());
}

class GoalaxyApp extends StatelessWidget {
  const GoalaxyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GOALAXY',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF080D0B),
        primaryColor: const Color(0xFF00C853),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selected = 0;
  bool liked = false;

  final List<String> titles = [
    'Home',
    'Explore',
    'Upload',
    'Messages',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF080D0B),
        title: const Text(
          'GOALAXY ⚽',
          style: TextStyle(
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: selected == 0
          ? homeScreen()
          : otherScreen(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF101915),
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.white54,
        currentIndex: selected,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            selected = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget homeScreen() {
    return Column(
      children: [
        const SizedBox(height: 12),
        const Text(
          'Discover the World of Football',
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF123D29),
                  Color(0xFF080D0B),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.sports_soccer,
                  size: 100,
                  color: Colors.greenAccent,
                ),
                const SizedBox(height: 20),
                const Text(
                  'GOALAXY',
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Your World. Your Videos.',
                  style: TextStyle(color: Colors.white70),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          liked = !liked;
                        });
                      },
                      icon: Icon(
                        liked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: liked ? Colors.red : Colors.white,
                        size: 32,
                      ),
                    ),
                    const Icon(
                      Icons.comment,
                      color: Colors.white,
                      size: 30,
                    ),
                    const Icon(
                      Icons.share,
                      color: Colors.white,
                      size: 30,
                    ),
                  ],
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget otherScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            selected == 1
                ? Icons.explore
                : selected == 2
                    ? Icons.add_circle
                    : selected == 3
                        ? Icons.chat
                        : Icons.person,
            color: Colors.greenAccent,
            size: 75,
          ),
          const SizedBox(height: 20),
          Text(
            titles[selected],
            style: const TextStyle(
              color: Colors.greenAccent
