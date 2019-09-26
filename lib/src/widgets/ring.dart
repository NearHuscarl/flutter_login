import 'package:flutter/material.dart';

/// A circle with a hole
class Ring extends StatelessWidget {
  Ring({
    Key key,
    this.color,
    this.size = 40.0,
    this.thickness = 2.0,
  })  : assert(size - thickness > 0),
        assert(thickness >= 0),
        super(key: key);

  final Color color;
  final double size;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size - thickness,
      height: size - thickness,
      child: thickness == 0
          ? null
          : CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeWidth: thickness,
              value: 1.0,
            ),
    );
  }
}
