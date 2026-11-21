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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
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
  final List<bool> liked = [false, false, false];

  final List<String> users = [
    'GOALAXY User',
    'Football Fan',
    'World Football',
  ];

  final List<String> videos = [
    'Football video',
    'Amazing football moments',
    'Welcome to GOALAXY',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'GOALAXY',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Watch and share videos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          for (int i = 0; i < users.length; i++)
            Card(
              margin: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(users[i]),
                    subtitle: Text(videos[i]),
                    trailing: const Icon(Icons.more_vert),
                  ),
                  Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.black12,
                    child: const Icon(
                      Icons.play_circle_fill,
                      size: 65,
                      color: Colors.blue,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          liked[i]
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: liked[i] ? Colors.red : Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            liked[i] = !liked[i];
                          });
                        },
                      ),
                      const Text('Like'),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.comment),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CommentsPage(
                                videoTitle: videos[i],
                              ),
                            ),
                          );
                        },
                      ),
                      const Text('Comment'),
                      const SizedBox(width: 12),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class CommentsPage extends StatelessWidget {
  final String videoTitle;

  const CommentsPage({
    super.key,
    required this.videoTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          'Comments for $videoTitle',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}