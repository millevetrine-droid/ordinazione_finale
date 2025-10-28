import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ordinazione/utils/color_utils.dart';

void main() {
  test('parse int color', () {
    final c = ColorParser.parseColor(0xFFFF6B8B);
    expect(c, const Color(0xFFFF6B8B));
  });

  test('parse hex #RRGGBB', () {
    final c = ColorParser.parseColor('#FF6B8B');
    expect(c, const Color(0xFFFF6B8B));
  });

  test('parse hex RRGGBB without #', () {
    final c = ColorParser.parseColor('FF6B8B');
    expect(c, const Color(0xFFFF6B8B));
  });

  test('parse hex #AARRGGBB', () {
    final c = ColorParser.parseColor('#80FF6B8B');
    expect(c, const Color(0x80FF6B8B));
  });

  test('colorToHex roundtrip', () {
    const original = Color(0xAABBCCDD);
    final hex = ColorParser.colorToHex(original);
    final parsed = ColorParser.parseColor(hex);
    expect((parsed.a * 255).round(), (original.a * 255).round());
    expect((parsed.r * 255).round(), (original.r * 255).round());
    expect((parsed.g * 255).round(), (original.g * 255).round());
    expect((parsed.b * 255).round(), (original.b * 255).round());
  });
}
