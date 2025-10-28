import 'package:flutter/material.dart';
import 'package:ordinazione/database_service.dart';
import 'package:ordinazione/models/order.dart';
import 'package:ordinazione/models/item.dart';

class CustomerRegistrationPage extends StatefulWidget {
  final List<Item>? selectedItems;

  const CustomerRegistrationPage({super.key, this.selectedItems});

  @override
  _CustomerRegistrationPageState createState() => _CustomerRegistrationPageState();
}

class _CustomerRegistrationPageState extends State<CustomerRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _tableNumberController = TextEditingController();
  late List<Item> _orderItems;

  @override
  void initState() {
    super.initState();
    _orderItems = widget.selectedItems != null ? List.from(widget.selectedItems!) : [];
  }

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
        id: DateTime.now().millisecondsSinceEpoch,
        tableNumber: int.parse(_tableNumberController.text),
        items: _orderItems,
        status: ItemStatus.inPreparation,
      );

      print('Ordine creato: ${newOrder.id}');

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
                      trailing: Text('€${(item.price ?? 0).toStringAsFixed(2)}'),
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