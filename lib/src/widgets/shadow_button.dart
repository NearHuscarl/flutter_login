import 'package:flutter/material.dart';

class ShadowButton extends StatelessWidget {
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

  final String? text;
  final BorderRadius borderRadius;
  final Color? color;
  final VoidCallback? onPressed;
  final ValueChanged<bool>? onHighlightChanged;
  final Color? splashColor;
  final double? width;
  final double? height;
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
