import 'package:flutter/material.dart';

class TablePage extends StatelessWidget {
  final int tableNumber;
  
  const TablePage({super.key, required this.tableNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ordinazione Tavolo $tableNumber'),
        backgroundColor: Colors.blue,
      ),
      body: const Center(
        child: Text('Dettagli dell\'ordinazione'),
      ),
    );
  }
}