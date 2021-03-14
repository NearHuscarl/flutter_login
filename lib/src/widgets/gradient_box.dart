import 'package:flutter/material.dart';

class GradientBox extends StatelessWidget {
  GradientBox({
    this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });

  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: begin,
          end: end,
          stops: [0, 1],
        ),
      ),
      child: SizedBox.expand(),
    );
  }
}
