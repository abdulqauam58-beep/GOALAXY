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
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: const Color(0xFF080D0B),
        appBar: AppBar(
          backgroundColor: const Color(0xFF00C853),
          title: const Text('GOALAXY ⚽'),
        ),
        body: const Center(
          child: Text(
            'Welcome to GOALAXY!',
            style: TextStyle(
              color: Colors.greenAccent,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
