import 'package:flutter/material.dart';

/// A full-screen [DecoratedBox] with a linear gradient background.
///
/// This widget is commonly used to create visually appealing backgrounds
/// for authentication or onboarding screens.
class GradientBox extends StatelessWidget {
  /// Creates a [GradientBox] with a linear gradient.
  ///
  /// The [colors] parameter is required and must contain at least two colors.
  /// Optionally, you can customize the gradient's [begin] and [end] alignments.
  const GradientBox({
    super.key,
    this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  }) : assert(colors != null && colors.length >= 2,
            'The "colors" parameter must contain at least two colors.');

  /// The starting point of the gradient.
  ///
  /// Defaults to [Alignment.topLeft].
  final AlignmentGeometry begin;

  /// The ending point of the gradient.
  ///
  /// Defaults to [Alignment.bottomRight].
  final AlignmentGeometry end;

  /// The list of colors used in the gradient.
  ///
  /// Must contain at least two colors.
  final List<Color>? colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors!,
          begin: begin,
          end: end,
          stops: const [0, 1],
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}
