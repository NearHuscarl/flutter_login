import 'package:flutter/material.dart';

/// Defines various lightness levels for a material color shade.
enum ColorShade {
  /// Lightest shade (typically 50 in Material Design)
  lightest,

  /// Very light shade (typically 100)
  secondLightest,

  /// Light shade (typically 200)
  thirdLightest,

  /// Medium-light shade (typically 300)
  fourthLightest,

  /// Slightly lighter than normal (typically 400)
  fifthLightest,

  /// Standard material color (typically 500)
  normal,

  /// Slightly darker than normal (typically 600)
  fourthDarkest,

  /// Dark shade (typically 700)
  thirdDarkest,

  /// Very dark shade (typically 800)
  secondDarkest,

  /// Darkest shade (typically 900)
  darkest,
}

/// Maps [ColorShade] enum values to their corresponding Material Design integers.
const Map<ColorShade, int> shades = {
  ColorShade.lightest: 50,
  ColorShade.secondLightest: 100,
  ColorShade.thirdLightest: 200,
  ColorShade.fourthLightest: 300,
  ColorShade.fifthLightest: 400,
  ColorShade.normal: 500,
  ColorShade.fourthDarkest: 600,
  ColorShade.thirdDarkest: 700,
  ColorShade.secondDarkest: 800,
  ColorShade.darkest: 900,
};

/// Tries to match the provided [color] with an existing [MaterialColor].
///
/// If no match is found, returns a new [MaterialColor] using the same [color]
/// value for all shade levels.
///
/// Useful when you need a [MaterialColor] from a single [Color].
MaterialColor getMaterialColor(Color color) {
  return Colors.primaries.firstWhere(
    (c) => c.toARGB32() == color.toARGB32(),
    orElse: () => MaterialColor(
      color.toARGB32(),
      <int, Color>{
        for (final entry in shades.entries) entry.value: color,
      },
    ),
  );
}

/// Estimates the [Brightness] of a [Color] (either light or dark).
///
/// Uses the color's relative luminance to determine brightness. This is based
/// on [ThemeData.estimateBrightnessForColor] but with a more permissive threshold
/// (`kThreshold = 0.45`) to allow more colors to qualify as dark.
Brightness estimateBrightnessForColor(Color color) {
  final relativeLuminance = color.computeLuminance();
  const kThreshold = 0.45;
  if ((relativeLuminance + 0.05) * (relativeLuminance + 0.05) > kThreshold) {
    return Brightness.light;
  }
  return Brightness.dark;
}

/// Returns a list of dark shades from a given [color].
///
/// The shades are determined based on [MaterialColor] mappings, and filtered by
/// [estimateBrightnessForColor]. Only shades darker than [minShade] are returned.
///
/// If no dark shades are found, returns the darkest shade (900) as fallback.
List<Color?> getDarkShades(
  Color color, [
  ColorShade minShade = ColorShade.fifthLightest,
]) {
  final materialColor =
      color is MaterialColor ? color : getMaterialColor(color);
  final darkShades = <Color>[];

  for (final shade in shades.values) {
    if (shade < shades[minShade]!) continue;

    final colorShade = materialColor[shade]!;
    if (estimateBrightnessForColor(colorShade) == Brightness.dark) {
      darkShades.add(colorShade);
    }
  }

  return darkShades.isNotEmpty
      ? darkShades
      : [materialColor[shades[ColorShade.darkest]!]];
}

/// Darkens the given [color] by a percentage [amount] (0.0 - 1.0).
///
/// Uses HSL color space to reduce lightness. Default amount is `0.1`.
Color darken(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1,
      'The darken amount must be between 0.0 and 1.0 (was $amount)');

  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDark.toColor();
}

/// Lightens the given [color] by a percentage [amount] (0.0 - 1.0).
///
/// Uses HSL color space to increase lightness. Default amount is `0.1`.
Color lighten(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1,
      'The lighten amount must be between 0.0 and 1.0 (was $amount)');

  final hsl = HSLColor.fromColor(color);
  final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

  return hslLight.toColor();
}
