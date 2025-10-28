import 'package:ordinazione/core/models/categoria_model.dart';
import 'package:ordinazione/core/models/pietanza_model.dart' show Pietanza;

class CategoriaAdapter {
  /// Convert a Map from lib_new into the legacy Categoria model.
  static Categoria fromNewMap(Map<String, dynamic> data) {
    final id = (data['id'] ?? '') as String;
    final nome = (data['nome'] ?? '') as String;
    final ordineRaw = data['ordine'];
    final ordine = ordineRaw is int
        ? ordineRaw
        : (ordineRaw is num ? ordineRaw.toInt() : 0);
    final immagine = data['immagine'] as String?;

    final tipo = (data['tipo'] ?? (data['idPadre'] != null ? 'sottocategoria' : 'macrocategoria')) as String?;
    final idPadre = data['idPadre'] as String?;
    final macrocategoriaId = data['macrocategoriaId'] as String? ?? '';

    // Build pietanze list if present in the incoming map, otherwise empty list
    final pietanzeRaw = data['pietanze'] as List? ?? const [];
    final pietanze = pietanzeRaw.map((p) => Pietanza.fromMap(Map<String, dynamic>.from(p as Map))).toList();

    return Categoria(
      id: id,
      nome: nome,
      ordine: ordine,
      imageUrl: immagine,
      tipo: tipo,
      idPadre: idPadre,
      macrocategoriaId: macrocategoriaId,
      pietanze: pietanze,
    );
  }
}
