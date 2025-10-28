import 'package:flutter/material.dart';
import '../../../models/categoria_model.dart';

class CategoryTabBar extends StatelessWidget {
  final List<Categoria> categorie;
  final String? categoriaSelezionata;
  final Function(String) onCategoriaChanged;

  const CategoryTabBar({
    super.key,
    required this.categorie,
    required this.categoriaSelezionata,
    required this.onCategoriaChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categorie.length,
        itemBuilder: (context, index) {
          final categoria = categorie[index];
          final isSelected = categoriaSelezionata == categoria.id;
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: ElevatedButton(
              onPressed: () {
                onCategoriaChanged(categoria.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? const Color(0xFF8B4513) : Colors.grey[100],
                foregroundColor: isSelected ? Colors.white : Colors.grey[800],
                elevation: isSelected ? 4 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF8B4513) : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    categoria.immagine,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    categoria.nome.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}