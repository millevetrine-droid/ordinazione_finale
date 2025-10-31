import 'package:flutter/material.dart';

class MenuHeader extends StatelessWidget implements PreferredSizeWidget {
  final String numeroTavolo;
  final VoidCallback onProfilePressed;

  const MenuHeader({
    super.key,
    required this.numeroTavolo,
    required this.onProfilePressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          const Icon(Icons.restaurant_menu, color: Colors.white),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MENU DIGITALE',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Tavolo $numeroTavolo',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: const Color(0xFF8B4513),
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.person, color: Colors.white),
          onPressed: onProfilePressed,
          tooltip: 'Profilo cliente',
        ),
      ],
    );
  }
}