import 'package:flutter/material.dart';
import '../../../utils/color_utils.dart';

class UltraSmallButton extends StatelessWidget {
  final String text;
  final String subtitle;
  final VoidCallback onPressed;

  const UltraSmallButton({
    super.key,
    required this.text,
    required this.subtitle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CD964).withOpacitySafe(0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
              color: Colors.black.withOpacitySafe(0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF4CD964).withOpacitySafe(0.2),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_arrow,
                  color: const Color(0xFF4CD964).withOpacitySafe(0.8),
                  size: 12,
                ),
                const SizedBox(width: 4),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      subtitle,
            style: TextStyle(
              color: Colors.white.withOpacitySafe(0.5),
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}