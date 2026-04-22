import 'package:flutter/material.dart';
import 'features/bottomnavbar.dart'; // adjust path to wherever you saved the navbar file

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AppBottomNavBar(),
    );
  }
}
