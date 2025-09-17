import 'package:flutter/material.dart';
import 'package:ordinazione/table_page.dart';

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
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const TablePage(tableNumber: 1)),
                );
              },
              child: const Text('Tavolo 1'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const TablePage(tableNumber: 2)),
                );
              },
              child: const Text('Tavolo 2'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const TablePage(tableNumber: 3)),
                );
              },
              child: const Text('Tavolo 3'),
            ),
          ],
        ),
      ),
    );
  }
}