import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBkuq_l0r6nBHH-azLdBOadYYfbdBsc-3Y',
      appId: '1:257666001605:android:693d089af2fc4ec5c75eac',
      messagingSenderId: '257666001605',
      projectId: 'goalaxy-481e0',
      storageBucket: 'goalaxy-481e0.firebasestorage.app',
    ),
  );

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
        scaffoldBackgroundColor: const Color(0xFF101018),
        primaryColor: Colors.green,
      ),
      home: const AuthPage(),
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
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
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'GOALAXY',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const Text('WORLD FOOTBALL COMMUNITY'),
              const SizedBox(height: 35),
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
              const SizedBox(height: 25),
              if (loading)
                const CircularProgressIndicator()
              else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => login(false),
                    child: const Text('LOGIN'),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => login(true),
                    child: const Text('CREATE ACCOUNT'),
                  ),
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
  int selected = 0;

  final pages = const [
    HomePage(),
    SearchPage(),
    UploadPage(),
    AlertsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GOALAXY ⚽',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF101018),
      ),
      body: pages[selected],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selected,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF191923),
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => selected = i),
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
            icon: Icon(Icons.add_box),
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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('Welcome to GOALAXY ⚽\nNo posts yet!'),
          );
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            return Card(
              color: const Color(0xFF20202B),
              margin: const EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['email'] ?? 'Football Fan',
                      style: const TextStyle(color: Colors.green),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      data['text'] ?? '',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.favorite_border),
                          onPressed: () async {
                            final uid = FirebaseAuth.instance.currentUser!.uid;
                            await doc.reference
                                .collection('likes')
                                .doc(uid)
                                .set({'likedAt': FieldValue.serverTimestamp()});
                          },
                        ),
                        StreamBuilder<QuerySnapshot>(
                          stream: doc.reference
                              .collection('likes')
                              .snapshots(),
                          builder: (context, likes) {
                            return Text('${likes.data?.docs.length ?? 0}');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
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

  Future<void> publish() async {
    if (controller.text.trim().isEmpty) return;

    setState(() => uploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;

      await FirebaseFirestore.instance.collection('posts').add({
        'text': controller.text.trim(),
        'email': user.email,
        'uid': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      controller.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post published successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).