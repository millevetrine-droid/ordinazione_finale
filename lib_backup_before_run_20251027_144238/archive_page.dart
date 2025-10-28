import 'package:flutter/material.dart';
import 'services/firebase/archive_service.dart';
import 'models/pietanza_ordine_model.dart';

class ArchivePage extends StatelessWidget {
  const ArchivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archivio Ordini'),
        backgroundColor: Colors.grey,
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Archivio Cucina'),
                Tab(text: 'Archivio Sala'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildArchiveListCucina(),
                  _buildArchiveListSala(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArchiveListCucina() {
    final service = ArchiveService();
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: service.getArchivioCucina(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Errore: ${snapshot.error}'));
        }
        final data = snapshot.data ?? [];
        if (data.isEmpty) {
          return const Center(child: Text('Nessun elemento in archivio cucina.'));
        }

        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            final pietanza = item['pietanza'] as PietanzaOrdine;
            final tavolo = item['tavolo'] ?? 'N/A';

            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(pietanza.nome),
                subtitle: Text('Tavolo: $tavolo - Stato: ${pietanza.stato}'),
                trailing: IconButton(
                  icon: const Icon(Icons.undo, color: Colors.orange),
                  onPressed: () async {
                    final scaffold = ScaffoldMessenger.of(context);
                    await service.ripristinaPietanzaDaArchivio(item['id'] as String);
                    scaffold.showSnackBar(
                      SnackBar(content: Text('${pietanza.nome} ripristinato.')),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildArchiveListSala() {
    final service = ArchiveService();
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: service.getArchivioSala(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Errore: ${snapshot.error}'));
        }
        final data = snapshot.data ?? [];
        if (data.isEmpty) {
          return const Center(child: Text('Nessun elemento in archivio sala.'));
        }

        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            final pietanza = item['pietanza'] as PietanzaOrdine;
            final tavolo = item['tavolo'] ?? 'N/A';

            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(pietanza.nome),
                subtitle: Text('Tavolo: $tavolo - Stato: ${pietanza.stato}'),
                trailing: IconButton(
                  icon: const Icon(Icons.undo, color: Colors.orange),
                  onPressed: () async {
                    final scaffold = ScaffoldMessenger.of(context);
                    await service.ripristinaPietanzaDaArchivioSala(item['id'] as String);
                    scaffold.showSnackBar(
                      SnackBar(content: Text('${pietanza.nome} ripristinato.')),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}