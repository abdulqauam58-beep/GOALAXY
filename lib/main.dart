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

final db = FirebaseFirestore.instance;
final auth = FirebaseAuth.instance;

class GOALAXY extends StatelessWidget {
  const GOALAXY({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GOALAXY',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF101018),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingPage();
        }

        if (snapshot.data == null) {
          return const AuthPage();
        }

        return const MainPage();
      },
    );
  }
}

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

// LOGIN AND REGISTER

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;
  bool createAccount = false;

  Future<void> submit() async {
    if (email.text.trim().isEmpty || password.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter email and password (at least 6 characters).'),
        ),
      );
      return;
    }

    setState(() => loading = true);

    try {
      UserCredential result;

      if (createAccount) {
        result = await auth.createUserWithEmailAndPassword(
          email: email.text.trim(),
          password: password.text.trim(),
        );
      } else {
        result = await auth.signInWithEmailAndPassword(
          email: email.text.trim(),
          password: password.text.trim(),
        );
      }

      final user = result.user!;

      await db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'name': user.email?.split('@').first ?? 'Football Fan',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }

    if (mounted) setState(() => loading = false);
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
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
                  color: Colors.green, size: 85),
              const SizedBox(height: 10),
              const Text(
                'GOALAXY',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const Text('Global Football Community'),
              const SizedBox(height: 35),
              TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : submit,
                  child: Text(
                    loading
                        ? 'Please wait...'
                        : createAccount
                            ? 'Create Account'
                            : 'Login',
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() => createAccount = !createAccount);
                },
                child: Text(
                  createAccount
                      ? 'Already have an account? Login'
                      : 'Create a new account',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// MAIN NAVIGATION

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
      body: IndexedStack(
        index: selected,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selected,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF191923),
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => selected = index),
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

// HOME PAGE

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
        actions: [
          IconButton(
            icon: const Icon(Icons.sports_soccer),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: db.collection('posts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load posts.'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data!.docs.toList();

          posts.sort((a, b) {
            final at = a.data()['createdAt'] as Timestamp?;
            final bt = b.data()['createdAt'] as Timestamp?;
            return (bt?.millisecondsSinceEpoch ?? 0)
                .compareTo(at?.millisecondsSinceEpoch ?? 0);
          });

          if (posts.isEmpty) {
            return const Center(
              child: Text(
                'Welcome to GOALAXY!\nBe the first to publish a post.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return PostCard(post: posts[index]);
            },
          );
        },
      ),
    );
  }
}

// POST CARD AND LIKE

class PostCard extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> post;

  const PostCard({super.key, required this.post});

  Future<void> toggleLike() async {
    final uid = auth.currentUser!.uid;
    final ref = db.collection('posts').doc(post.id);
    final data = post.data();
    final likes = List<String>.from(data['likes'] ?? []);

    if (likes.contains(uid)) {
      await ref.update({
        'likes': FieldValue.arrayRemove([uid]),
      });
    } else {
      await ref.update({
        'likes': FieldValue.arrayUnion([uid]),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = post.data();
    final uid = auth.currentUser!.uid;
    final likes = List<String>.from(data['likes'] ?? []);
    final liked = likes.contains(uid);

    return Card(
      margin: const EdgeInsets.all(10),
      color: const Color(0xFF20202B),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.green,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    data['authorName'] ?? 'Football Fan',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Icon(Icons.public, color: Colors.green),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              data['text'] ?? '',
              style: const TextStyle(fontSize: 17),
            ),
            const SizedBox(height: 15),
            const Divider(),
            Row(
              children: [
                IconButton(
                  onPressed: toggleLike,
                  icon: Icon(
                    liked ? Icons.favorite : Icons.favorite_border,
                    color: liked ? Colors.red : Colors.white,
                  ),
                ),
                Text('${likes.length} Likes'),
                const Spacer(),
                const Icon(Icons.sports_soccer, color: Colors.green),
                const SizedBox(width: 5),
                const Text('GOALAXY'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// SEARCH PAGE

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final search = TextEditingController();

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Football Fans')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: search,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search by name or email...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: db.collection('users').limit(100).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final uid = auth.currentUser!.uid;
                final term = search.text.toLowerCase();

                final users = snapshot.data!.docs.where((doc) {
                  if (doc.id == uid) return false;
                  final data = doc.data();
                  final name =
                      (data['name'] ?? '').toString().toLowerCase();
                  final email =
                      (data['email'] ?? '').toString().toLowerCase();

                  return name.contains(term) || email.contains(term);
                }).toList();

                if (users.isEmpty) {
                  return const Center(child: Text('No users found.'));
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return UserTile(user: users[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// USER AND FOLLOW BUTTON

class UserTile extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> user;

  const UserTile({super.key, required this.user});

  Future<void> toggleFollow(bool following) async {
    final uid = auth.currentUser!.uid;
    final target = user.id;

    final ref = db
        .collection('users')
        .doc(uid)
        .collection('following')
        .doc(target);

    if (following) {
      await ref.delete();
    } else {
      await ref.set({
        'uid': target,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await db.collection('alerts').add({
        'recipientId': target,
        'senderId': uid,
        'message': 'Someone followed you!',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = auth.currentUser!.uid;
    final followRef = db
        .collection('users')
        .doc(uid)
        .collection('following')
        .doc(user.id);

    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Colors.green,
        child: Icon(Icons.person),
      ),
      title: Text(user.data()['name'] ?? 'Football Fan'),
      subtitle: Text(user.data()['email'] ?? ''),
      trailing: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: followRef.snapshots(),
        builder: (context, snapshot) {
          final following = snapshot.data?.exists ?? false;

          return ElevatedButton(
            onPressed: () => toggleFollow(following),
            child: Text(following ? 'Following' : 'Follow'),
          );
        },
      ),
    );
  }
}

// UPLOAD PAGE

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final controller = TextEditingController();
  bool loading = false;

  Future<void> publish() async {
    final text = controller.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write something first.')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final user = auth.currentUser!;
      final profile = await db.collection('users').doc(user.uid).get();

      await db.collection('posts').add({
        'text': text,
        'authorId': user.uid,
        'authorName': profile.data()?['name'] ?? 'Football Fan',
        'likes': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      });

      controller.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post published successfully!')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload error: $e')),
        );
      }
    }

    if (mounted) setState(() => loading = false);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create a GOALAXY Post')),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            TextField(
              controller: controller,
              maxLines: 7,
              decoration: const InputDecoration(
                hintText: 'Write something about football...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: loading ? null : publish,
                icon: const Icon(Icons.publish),
                label: Text(
                  loading ? 'Publishing...' : 'Publish Post',
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Text posts are available. Video upload needs additional setup.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ALERTS PAGE

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = auth.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: db
            .collection('alerts')
            .where('recipientId', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load alerts.'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final alerts = snapshot.data!.docs;

          if (alerts.isEmpty) {
            return const Center(child: Text('No notifications yet.'));
          }

          return ListView.builder(
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final data = alerts[index].data();

              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.notifications),
                ),
                title: Text(data['message'] ?? 'New notification'),
                subtitle: const Text('GOALAXY'),
              );
            },
          );
        },
      ),
    );
  }
}

// PROFILE PAGE

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = auth.currentUser!;

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: db.collection('users').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() ?? {};

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.green,
                    child: Icon(Icons.person, size: 55),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    data['name'] ?? 'Football Fan',
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(user.email ?? ''),
                  const SizedBox(height: 25),
                  const Text(
                    'Welcome to the GOALAXY football community!',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await auth.signOut();
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}