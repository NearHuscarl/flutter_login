import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:flutter/material.dart';

import '../math_helper.dart';
import '../matrix.dart';

class CustomPageTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    final transform = Matrix.perspective();
    final position = info.position!;
    final pageDt = 1 - position.abs();

    if (position > 0) {
      transform
        ..scale(MathHelper.lerp(0.6, 1.0, pageDt))
        ..rotateY(position * -1.5);
    } else {
      transform
        ..scale(MathHelper.lerp(0.6, 1.0, pageDt))
        ..rotateY(position * 1.5);
    }

    return Transform(
      alignment: Alignment.center,
      transform: transform,
      child: child,
    );
  }
}
