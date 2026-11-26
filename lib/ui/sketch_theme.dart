import 'package:flutter/material.dart' hide Ink;

import '../core/sketch/ink.dart';

/// Surface and ink colours for the app chrome (screens, cards, dialogs, HUD).
///
/// Game worlds and character art keep the fixed [Ink] palette in both themes;
/// only the notebook "paper" around them changes. Read it with
/// `context.palette`.
@immutable
class SketchPalette extends ThemeExtension<SketchPalette> {
  const SketchPalette({
    required this.brightness,
    required this.paper,
    required this.grid,
    required this.speckle,
    required this.surface,
    required this.surfaceWarm,
    required this.surfaceAccent,
    required this.selected,
    required this.ink,
    required this.inkSoft,
    required this.barrier,
    required this.tintBase,
    required this.tintStrength,
    required this.night,
    this.transient = false,
  });

  final Brightness brightness;

  /// Page background and its graph-paper lines.
  final Color paper;
  final Color grid;
  final Color speckle;

  /// Cards, chips and plain buttons.
  final Color surface;

  /// Dialogs and overlay cards.
  final Color surfaceWarm;

  /// The primary (pink) button fill.
  final Color surfaceAccent;

  /// Fill of the chosen chip in a group (theme, language, ...).
  final Color selected;

  /// Text, outlines and doodle icons.
  final Color ink;
  final Color inkSoft;

  /// Scrim behind dialogs.
  final Color barrier;

  /// Pastel button fills are mixed from this colour (white in light mode).
  final Color tintBase;
  final double tintStrength;

  /// 0 in light mode, 1 in dark mode (in between while animating). Dims
  /// illustrations so bright scenes do not glare at night.
  final double night;

  /// True while the theme is animating between light and dark. Painters skip
  /// the sprite cache for these in-between colours.
  final bool transient;

  bool get isDark => brightness == Brightness.dark;

  /// Pastel fill of [c] that suits this theme (the dark-mode equivalent of
  /// [Ink.tint]).
  Color tint(Color c, [double t = 0.45]) => Color.lerp(tintBase, c, (t * tintStrength).clamp(0.0, 1.0))!;

  static const light = SketchPalette(
    brightness: Brightness.light,
    paper: Ink.paper,
    grid: Ink.grid,
    speckle: Color(0x1F3A3F55),
    surface: Ink.white,
    surfaceWarm: Ink.paperWarm,
    surfaceAccent: Ink.blushPink,
    selected: Color(0xFFFBE2A0),
    ink: Ink.navy,
    inkSoft: Ink.navySoft,
    barrier: Color(0x402536A8),
    tintBase: Ink.white,
    tintStrength: 1,
    night: 0,
  );

  /// "Night notebook": deep blue paper with chalky ink.
  static const dark = SketchPalette(
    brightness: Brightness.dark,
    paper: Color(0xFF161A33),
    grid: Color(0xFF272E5A),
    speckle: Color(0x14FFFFFF),
    surface: Color(0xFF212748),
    surfaceWarm: Color(0xFF252B4F),
    surfaceAccent: Color(0xFF4A3358),
    // Yellow over navy turns muddy, so night mode selects in bright indigo.
    selected: Color(0xFF3F4FA0),
    ink: Color(0xFFE9ECFF),
    inkSoft: Color(0xFFA9B2E6),
    barrier: Color(0x99000000),
    tintBase: Color(0xFF212748),
    tintStrength: 0.62,
    night: 1,
  );

  @override
  SketchPalette copyWith({Brightness? brightness}) => brightness == Brightness.dark ? dark : light;

  @override
  SketchPalette lerp(covariant SketchPalette? other, double t) {
    if (other == null || t <= 0) return this;
    if (t >= 1) return other;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return SketchPalette(
      brightness: t < 0.5 ? brightness : other.brightness,
      paper: c(paper, other.paper),
      grid: c(grid, other.grid),
      speckle: c(speckle, other.speckle),
      surface: c(surface, other.surface),
      surfaceWarm: c(surfaceWarm, other.surfaceWarm),
      surfaceAccent: c(surfaceAccent, other.surfaceAccent),
      selected: c(selected, other.selected),
      ink: c(ink, other.ink),
      inkSoft: c(inkSoft, other.inkSoft),
      barrier: c(barrier, other.barrier),
      tintBase: c(tintBase, other.tintBase),
      tintStrength: tintStrength + (other.tintStrength - tintStrength) * t,
      night: night + (other.night - night) * t,
      transient: true,
    );
  }
}

extension SketchThemeContext on BuildContext {
  SketchPalette get palette => Theme.of(this).extension<SketchPalette>() ?? SketchPalette.light;
}

/// The always-light theme, for illustrated areas (the home pond's sign and
/// buttons) that keep their daytime look in dark mode.
final sketchLightTheme = buildSketchTheme(SketchPalette.light);
final sketchDarkTheme = buildSketchTheme(SketchPalette.dark);

/// Builds the Material theme around a [SketchPalette].
ThemeData buildSketchTheme(SketchPalette p) {
  final scheme = ColorScheme.fromSeed(
    seedColor: Ink.navy,
    brightness: p.brightness,
    surface: p.paper,
    onSurface: p.ink,
  );
  final base = ThemeData(brightness: p.brightness, colorScheme: scheme);
  return base.copyWith(
    scaffoldBackgroundColor: p.paper,
    splashFactory: NoSplash.splashFactory,
    // Text without an explicit colour (all of Txt) picks up the palette ink.
    textTheme: base.textTheme.apply(bodyColor: p.ink, displayColor: p.ink),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
      },
    ),
    extensions: [p],
  );
}

/// Multiplies [child] by [tint], scaled by how dark the theme is.
Widget _nightTint(BuildContext context, Color tint, Widget child) {
  final k = context.palette.night;
  if (k <= 0) return child;
  return ColorFiltered(
    colorFilter: ColorFilter.mode(Color.lerp(Ink.white, tint, k)!, BlendMode.modulate),
    child: child,
  );
}

/// Slightly dims an illustration (game world, thumbnail) in dark mode. A
/// no-op in light mode.
class SceneDimmer extends StatelessWidget {
  const SceneDimmer({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => _nightTint(context, const Color(0xFFD2D6EA), child);
}

/// Evening tint for the full-screen pond backdrop in dark mode: the scene
/// turns to dusk while the sign and buttons on top stay bright.
class DuskFilter extends StatelessWidget {
  const DuskFilter({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => _nightTint(context, const Color(0xFF7F8CC4), child);
}
