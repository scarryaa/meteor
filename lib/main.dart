import 'package:flutter/material.dart';
import 'package:meteor/pages/main_page.dart';

void main() {
  runApp(const MeteorApp());
}

class MeteorApp extends StatelessWidget {
  const MeteorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'meteor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MainPage(),
    );
  }
}
