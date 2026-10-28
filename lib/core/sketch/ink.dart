import 'package:flutter/painting.dart';

/// Notebook-doodle palette shared by every screen and game.
class Ink {
  Ink._();

  static const navy = Color(0xFF2536A8);
  static const navySoft = Color(0xFF5A68C4);
  static const pencil = Color(0xFF3A3F55);
  static const paper = Color(0xFFFBF9F3);
  static const paperWarm = Color(0xFFFFF8EC);
  static const grid = Color(0xFFD3E1F4);
  static const cream = Color(0xFFFFF7E6);
  static const blushPink = Color(0xFFFDE8EC);

  static const blue = Color(0xFF4F8EF7);
  static const sky = Color(0xFF9CCFF2);
  static const coral = Color(0xFFEE7F6B);
  static const pink = Color(0xFFF49AB4);
  static const yellow = Color(0xFFF7C843);
  static const gold = Color(0xFFF2B12E);
  static const mint = Color(0xFF6CC48A);
  static const leaf = Color(0xFF4FA866);
  static const orange = Color(0xFFF39A4C);
  static const purple = Color(0xFFA88BE0);
  static const brown = Color(0xFFB9824F);
  static const sand = Color(0xFFF3D9A4);
  static const white = Color(0xFFFFFFFF);
  static const night = Color(0xFF2B3470);
  static const nightDeep = Color(0xFF1F2657);

  static const bright = [coral, yellow, blue, mint, orange, purple, pink];

  static Color tint(Color c, [double t = 0.45]) => Color.lerp(const Color(0xFFFFFFFF), c, t)!;
  static Color shade(Color c, [double t = 0.25]) => Color.lerp(c, const Color(0xFF1A1F4A), t)!;
}
