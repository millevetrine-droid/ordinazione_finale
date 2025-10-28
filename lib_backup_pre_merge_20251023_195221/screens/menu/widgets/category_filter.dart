import 'package:flutter/material.dart';
import 'package:ordinazione/utils/color_utils.dart';
import '../../../models/categoria_model.dart'; // 👈 CORREGGI QUESTO

class CategoryFilter extends StatelessWidget {
  final List<Categoria> categorie;
  final String? categoriaSelezionata;
  final Function(String?) onCategoriaChanged;

  const CategoryFilter({
    super.key,
    required this.categorie,
    required this.categoriaSelezionata,
    required this.onCategoriaChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (categorie.length <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categorie.length,
        itemBuilder: (context, index) {
          final categoria = categorie[index];
          final isSelezionata = categoriaSelezionata == categoria.id;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text('${categoria.immagine ?? '🍽️'} ${categoria.nome}'),
              selected: isSelezionata,
              onSelected: (selected) {
                onCategoriaChanged(selected ? categoria.id : null);
              },
              backgroundColor: Colors.black.withOpacitySafe(0.7),
              selectedColor: const Color(0xFFFF6B8B),
              labelStyle: TextStyle(
                color: isSelezionata ? Colors.white : Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        },
      ),
    );
  }
}