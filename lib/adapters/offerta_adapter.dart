/// Simple adapter for offer maps coming from lib_new.
class OffertaAdapter {
  /// Normalize an offer map to the shape used by MenuCacheService
  static Map<String, dynamic> fromNewMap(Map<String, dynamic> m) {
    return {
      'id': m['id']?.toString() ?? '',
      'titolo': m['titolo'] ?? m['title'] ?? '',
      'sottotitolo': m['sottotitolo'] ?? m['subtitle'] ?? '',
      'prezzo': (m['prezzo'] is num) ? m['prezzo'] : double.tryParse(m['prezzo']?.toString() ?? '0') ?? 0.0,
      'immagine': m['immagine'] ?? m['image'] ?? '',
      // Accept color as int or hex string (#AARRGGBB or #RRGGBB). Keep default pink.
      'colore': m['colore'] is String ? m['colore'] : (m['colore'] ?? 0xFFFF6B8B),
      'linkTipo': m['linkTipo'] ?? m['link_type'] ?? 'pietanza',
      'linkDestinazione': m['linkDestinazione'] ?? m['link_destination'] ?? '',
      'attiva': m['attiva'] ?? true,
      'ordine': m['ordine'] ?? 0,
    };
  }
}
