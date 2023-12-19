import 'dart:math';

double toRadian(double degree) => degree * pi / 180;

double lerp(double start, double end, double percent) {
  return start + percent * (end - start);
}
