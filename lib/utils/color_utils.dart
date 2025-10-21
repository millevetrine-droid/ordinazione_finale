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
    final a = (((color.a * 255).round()) & 0xff).toRadixString(16).padLeft(2, '0');
    final r = (((color.r * 255).round()) & 0xff).toRadixString(16).padLeft(2, '0');
    final g = (((color.g * 255).round()) & 0xff).toRadixString(16).padLeft(2, '0');
    final b = (((color.b * 255).round()) & 0xff).toRadixString(16).padLeft(2, '0');
    return '#$a$r$g$b';
  }
}

// Small helper to replace deprecated `withOpacity` usage.
// This computes a new Color preserving RGB channels and setting alpha explicitly.
extension ColorUtils on Color {
  /// Returns the same color with the given opacity (0.0 - 1.0) using
  /// an explicit ARGB construction to avoid precision-loss deprecations.
  /// Uses the recommended component accessors (.r/.g/.b) and converts them
  /// to 0-255 integers as required by [Color.fromARGB].
  Color withOpacitySafe(double opacity) {
    final a = (opacity.clamp(0.0, 1.0) * 255).round();
    final r = (this.r * 255.0).round() & 0xff;
    final g = (this.g * 255.0).round() & 0xff;
    final b = (this.b * 255.0).round() & 0xff;
    return Color.fromARGB(a, r, g, b);
  }
}
