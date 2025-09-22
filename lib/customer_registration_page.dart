import 'package:flutter/material.dart';
import 'package:ordinazione_finale/database_service.dart';
import 'package:ordinazione_finale/models/order.dart';

class CustomerRegistrationPage extends StatefulWidget {
  const CustomerRegistrationPage({super.key});

  @override
  _CustomerRegistrationPageState createState() => _CustomerRegistrationPageState();
}

class _CustomerRegistrationPageState extends State<CustomerRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _tableNumberController = TextEditingController();
  final List<Item> _orderItems = [];

  void _addOrderItem(String itemName, double price) {
    setState(() {
      _orderItems.add(Item(itemName: itemName, price: price, itemStatus: ItemStatus.inPreparation));
    });
  }

  void _submitOrder() async {
    print('Tentativo di invio ordine...');
    if (_orderItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aggiungi almeno un articolo all\'ordine.')),
      );
      print('Errore: Nessun articolo aggiunto all\'ordine.');
      return;
    }

    if (_formKey.currentState!.validate()) {
      print('Form validato. Creazione oggetto Order...');
      final newOrder = Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        tableNumber: int.parse(_tableNumberController.text),
        items: _orderItems,
        timestamp: DateTime.now(),
      );

      print('Ordine creato: ${newOrder.toFirestore()}');

      try {
        await DatabaseService().addOrder(newOrder);
        print('Ordine inviato con successo al database!');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ordine inviato con successo!')),
        );

        _tableNumberController.clear();
        setState(() {
          _orderItems.clear();
        });

      } catch (e) {
        print('Errore durante l\'invio dell\'ordine al database: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nell\'invio dell\'ordine: $e')),
        );
      }
    } else {
      print('Form non valido!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrazione Cliente'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tableNumberController,
                decoration: const InputDecoration(labelText: 'Numero Tavolo'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Inserisci un numero di tavolo';
                  }
                  return null;
                },
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _orderItems.length,
                  itemBuilder: (context, index) {
                    final item = _orderItems[index];
                    return ListTile(
                      title: Text(item.itemName),
                      trailing: Text('€${item.price.toStringAsFixed(2)}'),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: _submitOrder,
                child: const Text('Invia Ordine'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addOrderItem('Pizza Margherita', 7.50);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}