import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pokedex/services/auth.dart';
import 'package:pokedex/menu.dart';
import 'package:pokedex/screens/signin.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokedex',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE3350D)),
      ),

      routes: {
        '/': (_) => const MyHomePage(title: 'Pokedex'),
        '/signin': (_) => const SigninPage(),
      },
    );
  }
}