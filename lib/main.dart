import 'package:flutter/material.dart';

void main() {
  runApp(const GOALAXY());
}

class GOALAXY extends StatelessWidget {
  const GOALAXY({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GOALAXY',
      theme: ThemeData.dark(),
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
  int page = 0;

  final List<Map<String, dynamic>> videos = [
    {'name': 'Ronaldo', 'likes': 1200, 'liked': false},
    {'name': 'Messi', 'likes': 950, 'liked': false},
    {'name': 'Neymar', 'likes': 870, 'liked': false},
    {'name': 'Mbappe', 'likes': 650, 'liked': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GOALAXY ⚽',
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: page == 0
          ? ListView.builder(
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];

                return Card(
                  margin: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Container(
                        height: 190,
                        width: double.infinity,
                        color: Colors.black87,
                        child: const Icon(
                          Icons.play_circle_fill,
                          size: 75,
                          color: Colors.orange,
                        ),
                      ),
                      ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(video['name']),
                        subtitle: const Text('Football video ⚽'),
                      ),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceAround,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                video['liked'] = !video['liked'];
                                video['likes'] +=
                                    video['liked'] ? 1 : -1;
                              });
                            },
                            icon: Icon(
                              video['liked']
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.red,
                            ),
                            label: Text('${video['likes']}'),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Comments will be available soon.',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.comment),
                            label: const Text('Comment'),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.share),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            )
          : Center(
              child: Text(
                ['Home', 'Search', 'Upload', 'Alerts', 'Profile'][page],
                style: const TextStyle(fontSize: 25),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: page,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            page = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}