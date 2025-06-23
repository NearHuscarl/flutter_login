import 'package:flutter/material.dart';

/// A customizable button with optional shadow and rounded corners.
///
/// [ShadowButton] combines `Material`, `InkWell`, and a `BoxShadow` to
/// produce a modern tappable UI element. It is typically used where visual
/// elevation and shadow effects are desired.
class ShadowButton extends StatelessWidget {
  /// Creates a [ShadowButton] with optional styling and behavior.
  ///
  /// The [text] parameter is required to display content inside the button.
  const ShadowButton({
    super.key,
    this.text,
    this.borderRadius = BorderRadius.zero,
    this.color,
    this.onPressed,
    this.onHighlightChanged,
    this.splashColor,
    this.width,
    this.height,
    this.boxShadow,
  });

  /// The label to display inside the button.
  final String? text;

  /// The border radius applied to the button and splash effect.
  final BorderRadius borderRadius;

  /// The background color of the button.
  final Color? color;

  /// Callback invoked when the button is tapped.
  final VoidCallback? onPressed;

  /// Callback triggered when the button's highlight (pressed) state changes.
  final ValueChanged<bool>? onHighlightChanged;

  /// The color of the splash ripple effect when the button is tapped.
  final Color? splashColor;

  /// The width of the button. If `null`, it will size to fit its parent.
  final double? width;

  /// The height of the button. If `null`, it will size to fit its child.
  final double? height;

  /// Optional shadow to apply beneath the button.
  final BoxShadow? boxShadow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: Colors.transparent,
        boxShadow: [if (boxShadow != null) boxShadow!],
      ),
      child: Material(
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        color: color,
        child: InkWell(
          onTap: onPressed,
          onHighlightChanged: onHighlightChanged,
          splashColor: splashColor,
          borderRadius: borderRadius,
          child: Container(
            width: width,
            height: height,
            alignment: Alignment.center,
            child: Text(
              text!,
              style: TextStyle(color: theme.primaryTextTheme.labelLarge!.color),
              overflow: TextOverflow.visible,
              softWrap: false,
            ),
          ),
        ),
      ),
    );
  }
}
