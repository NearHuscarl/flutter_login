import 'dart:math';

/// Converts [degree] to radians.
///
/// Useful when working with Flutter animations or trigonometric functions
/// that expect angles in radians.
double toRadian(double degree) => degree * pi / 180;

/// Linearly interpolates between [start] and [end] by [percent].
///
/// [percent] should typically be between 0.0 and 1.0.
/// Returns a value that is [percent] of the way from [start] to [end].
double lerp(double start, double end, double percent) {
  return start + percent * (end - start);
}
