import '../models/categoria_model.dart';

class CategoriaAdapter {
  /// Convert a Map from lib_new into the local `Categoria`.
  static Categoria fromNewMap(Map<String, dynamic> m) {
    final id = (m['id'] ?? '') as String;
    final nome = (m['nome'] ?? '') as String;
    final ordine = (m['ordine'] is int) ? m['ordine'] as int : ((m['ordine'] is num) ? (m['ordine'] as num).toInt() : 0);
    final immagine = m['immagine'] as String?;

    // New model may have macrocategoria/subcategory semantics; map to 'tipo'
    final tipo = (m['tipo'] ?? (m['idPadre'] != null ? 'sottocategoria' : 'macrocategoria')) as String;
    final idPadre = m['idPadre'] as String?;

    return Categoria(
      id: id,
      nome: nome,
      ordine: ordine,
      immagine: immagine,
      tipo: tipo,
      idPadre: idPadre,
    );
  }
}
