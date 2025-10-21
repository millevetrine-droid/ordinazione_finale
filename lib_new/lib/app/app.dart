import 'package:flutter/material.dart';
import '../features/splash/splash_screen.dart';
import '../features/home/home_screen.dart';

class MillevetrineRestaurantApp extends StatelessWidget {
  const MillevetrineRestaurantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ristorante Millevetrine',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}