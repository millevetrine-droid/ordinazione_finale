import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/menu_provider.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late MenuProvider _provider;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _provider = context.read<MenuProvider>();
      // trigger lazy load after the first frame to avoid calling notifyListeners
      // during the build phase.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _provider.loadMacrocategorie();
      });
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MenuProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: provider.macrocategorie.length,
              itemBuilder: (context, index) {
                final cat = provider.macrocategorie[index];
                return ListTile(
                  title: Text(cat.nome),
                  subtitle: Text('id: ${cat.id}'),
                );
              },
            ),
    );
  }
}
