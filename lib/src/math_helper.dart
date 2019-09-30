import 'dart:math';

class MathHelper {
  static double toRadian(double degree) => degree * pi / 180;

  static double lerp(double start, double end, double percent) {
    return (start + percent * (end - start));
  }
}
