import 'package:flutter/rendering.dart';

class Matrix {
  /// Perspective makes objects that are farther away appear smaller
  ///
  /// the [weight] parameter increases and decreases the amount of perspective,
  /// something like zooming in and out with a zoom lens on a camera. The bigger
  /// this number, the more pronounced is the perspective, which makes it look
  /// like you are closer to the viewed object
  ///
  /// https://medium.com/flutter/perspective-on-flutter-6f832f4d912e
  static Matrix4 perspective([double weight = .001]) =>
      Matrix4.identity()..setEntry(3, 2, weight);
}
