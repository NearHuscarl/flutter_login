import 'package:flutter/material.dart';

/// A circular progress indicator that looks like a ring (a circle with a hole).
///
/// Can be used to display static or animated progress indicators with
/// configurable [size], [thickness], and [color].
class Ring extends StatelessWidget {
  /// Creates a [Ring] widget, which is a visual circular progress indicator.
  ///
  /// The [size] must be greater than [thickness], and [thickness] must be non-negative.
  const Ring({
    super.key,
    this.color,
    this.size = 40.0,
    this.thickness = 2.0,
    this.value = 1.0,
  })  : assert(
            size - thickness > 0, 'Ring thickness must be smaller than size.'),
        assert(thickness >= 0, 'Ring thickness must be non-negative.');

  /// The color of the ring stroke.
  final Color? color;

  /// The overall diameter of the ring.
  final double size;

  /// The stroke width of the ring.
  ///
  /// If set to `0`, the ring will not render.
  final double thickness;

  /// The progress value of the ring, between 0.0 and 1.0.
  ///
  /// A value of `1.0` means full progress.
  final double value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size - thickness,
      height: size - thickness,
      child: thickness == 0
          ? null
          : CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color?>(color),
              strokeWidth: thickness,
              value: value,
            ),
    );
  }
}
