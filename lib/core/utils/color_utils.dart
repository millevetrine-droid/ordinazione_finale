import 'package:flutter/material.dart';

/// Utilities to parse and serialize colors in a stable format.
class ColorParser {
  /// Parse a color value that may be an int or a hex string (#RRGGBB or #AARRGGBB).
  /// Falls back to pink if parsing fails.
  static Color parseColor(dynamic colorData) {
    if (colorData is int) return Color(colorData);

    if (colorData is String) {
      var hex = colorData.replaceFirst('#', '');
      if (hex.length == 6) hex = 'ff$hex';
      if (hex.length == 8) return Color(int.parse(hex, radix: 16));
    }

    return const Color(0xFFFF6B8B);
  }

  /// Convert a [Color] into a hex string '#AARRGGBB'.
  static String colorToHex(Color color) {
  // Use an explicit ARGB conversion helper (toARGB32) when available
  // to avoid deprecated channel accessors on Color.
  final value = color.toARGB32();
    final a = ((value >> 24) & 0xff).toRadixString(16).padLeft(2, '0');
    final r = ((value >> 16) & 0xff).toRadixString(16).padLeft(2, '0');
    final g = ((value >> 8) & 0xff).toRadixString(16).padLeft(2, '0');
    final b = ((value) & 0xff).toRadixString(16).padLeft(2, '0');
    return '#$a$r$g$b';
  }
}

// Small helper to replace deprecated `withOpacity` usage.
extension ColorUtils on Color {
  Color withOpacitySafe(double opacity) {
    final a = (opacity.clamp(0.0, 1.0) * 255).round();
    final v = toARGB32();
    final r = (v >> 16) & 0xff;
    final g = (v >> 8) & 0xff;
    final b = v & 0xff;
    return Color.fromARGB(a, r, g, b);
  }
}
