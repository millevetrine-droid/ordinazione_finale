import 'package:flutter/painting.dart';

/// Compatibility extension: use `withOpacityCompat` instead of the deprecated
/// `withOpacity`. This converts the opacity to an alpha value and delegates to
/// `withAlpha` to avoid the analyzer deprecated_member_use warnings.
extension ColorExtensions on Color {
  Color withOpacityCompat(double opacity) {
    final alpha = (opacity * 255).round().clamp(0, 255);
    return withAlpha(alpha);
  }
}
