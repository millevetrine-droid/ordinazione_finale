import 'package:flutter/material.dart';
import 'package:ordinazione/features/splash/splash_screen.dart';
import 'package:ordinazione/features/home/home_screen.dart';

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