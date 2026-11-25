import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const GOALAXY());
}

class GOALAXY extends StatelessWidget {
  const GOALAXY({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GOALAXY',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF101010),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.dark,
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  Future<void> login(bool create) async {
    setState(() => loading = true);
    try {
      if (create) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text.trim(),
          password: password.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.text.trim(),
          password: password.text.trim(),
        );
      }
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              const Icon(Icons.sports_soccer,
                  color: Colors.orange, size: 85),
              const SizedBox(height: 15),
              const Text('GOALAXY',
                  style: TextStyle(
                      fontSize: 35,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              TextField(
                controller: email,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              if (loading)
                const CircularProgressIndicator()
              else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => login(false),
                    child: const Text('Login'),
                  ),
                ),
                TextButton(
                  onPressed: () => login(true),
                  child: const Text('Create Account'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int page = 0;

  final pages = const [
    FeedPage(),
    SearchPage(),
    UploadPage(),
    AlertsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GOALAXY ⚽',
            style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: pages[page],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: page,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: (value) => setState(() => page = value),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle), label: 'Upload'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Alerts'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Could not load posts'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('Welcome to GOALAXY ⚽\nNo posts yet.'),
          );
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: const CircleAvatar(
                        child: Icon(Icons.person)),
                    title: Text(data['email'] ?? 'GOALAXY user'),
                    subtitle: const Text('Football video ⚽'),
                  ),
                  if (data['text'] != null)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(data['text']),
                    ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => likePost(doc.id),
                        icon: const Icon(Icons.favorite_border,
                            color: Colors.red),
                      ),
                      Text('${data['likes'] ?? 0}'),
                      const SizedBox(width: 25),
                      IconButton(
                        onPressed: () => showComments(context, doc.id),
                        icon: const Icon(Icons.comment),
                      ),
                      const Text('Comment'),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

Future<void> likePost(String id) async {
  await FirebaseFirestore.instance.collection('posts').doc(id).update({
    'likes': FieldValue.increment(1),
  });
}

void showComments(BuildContext context, String postId) {
  final controller = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        left: 15,
        right: 15,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Write a comment...',
          suffixIcon: IconButton(
            icon: const Icon(Icons.send),
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              await FirebaseFirestore.instance
                  .collection('posts')
                  .doc(postId)
                  .collection('comments')
                  .add({
                'text': controller.text.trim(),
                'email': FirebaseAuth.instance.currentUser?.email,
                'createdAt': FieldValue.serverTimestamp(),
              });
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ),
      ),
    ),
  );
}

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'Search GOALAXY...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onSubmitted: (value) {},
      ),
    );
  }
}

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final controller = TextEditingController();
  bool uploading = false;

  Future<void> uploadPost() async {
    if (controller.text.trim().isEmpty) return;

    setState(() => uploading = true);

    try {
      await FirebaseFirestore.instance.collection('posts').add({
        'text': controller.text.trim(),
        'email': FirebaseAuth.instance.currentUser?.email,
        'likes': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      controller.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post published!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }

    if (mounted) setState(() => uploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text('Create a GOALAXY post',
              style: TextStyle(fontSize: 22)),
          const SizedBox(height: 20),
          TextField(
            controller: controller,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Write something about football...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: uploading ? null : uploadPost,
            icon