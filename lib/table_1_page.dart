import 'package:flutter/material.dart';

class Table1Page extends StatelessWidget {
  const Table1Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordinazione Tavolo 1'),
        backgroundColor: Colors.blue,
      ),
      body: const Center(
        child: Text('Dettagli dell\'ordinazione'),
      ),
    );
  }
}