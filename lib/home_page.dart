import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordinazione App'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Azione per il pulsante 1
              },
              child: const Text('Tavolo 1'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Azione per il pulsante 2
              },
              child: const Text('Tavolo 2'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Azione per il pulsante 3
              },
              child: const Text('Tavolo 3'),
            ),
          ],
        ),
      ),
    );
  }
}