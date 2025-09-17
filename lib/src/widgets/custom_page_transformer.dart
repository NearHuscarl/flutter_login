import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:flutter/material.dart';

import 'package:flutter_login/src/utils/math_helper.dart';
import 'package:flutter_login/src/utils/matrix.dart';

/// A custom 3D page transformer that applies perspective scaling and rotation
/// as pages are swiped. Creates a visually dynamic carousel-like effect.
class CustomPageTransformer extends PageTransformer {
  @override
  Widget transform(Widget child, TransformInfo info) {
    // Start with a 3D perspective matrix.
    final transform = perspective();

    // Position of the current page relative to the viewport center.
    // Ranges from -1 (left) to 1 (right), where 0 is the center.
    final position = info.position!;

    // Value between 0 and 1, indicating how close the page is to the center.
    final pageDt = 1 - position.abs();

    // Apply scale and Y-axis rotation based on the page's position.
    final scale = lerp(0.6, 1, pageDt);
    if (position > 0) {
      transform
        ..scaleByDouble(
            scale, scale, scale, 1) // Scale up as it approaches center
        ..rotateY(position * -1.5); // Rotate left for right-side pages
    } else {
      transform
        ..scaleByDouble(
            scale, scale, scale, 1) // Scale up as it approaches center
        ..rotateY(position * 1.5); // Rotate right for left-side pages
    }

    // Return the transformed widget.
    return Transform(
      alignment: Alignment.center,
      transform: transform,
      child: child,
    );
  }
}
