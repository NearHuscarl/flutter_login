import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter_login/src/widgets/ring.dart';

/// A custom animated button widget that displays an [IconButton] instead of text,
/// and animates between a static icon and a loading indicator.
///
/// This widget is similar to AnimatedButton, but shows an icon instead of a text label.
/// It supports animation using the provided [controller], and allows customization of
/// icon color and loading indicator color.
///
/// Typically used in login forms or actions requiring async loading states.
class AnimatedIconButton extends StatefulWidget {
  /// Creates an [AnimatedIconButton].
  ///
  /// The [tooltip], [onPressed], [controller], and [icon] parameters must not be null.
  const AnimatedIconButton({
    required this.tooltip,
    required this.onPressed,
    required this.controller,
    required this.icon,
    super.key,
    this.loadingColor,
    this.color,
    this.iconColor,
  });

  /// Tooltip shown on long press or mouse hover.
  final String tooltip;

  /// Background color of the button.
  final Color? color;

  /// Color of the loading indicator (spinner).
  final Color? loadingColor;

  /// Color of the icon.
  final Color? iconColor;

  /// Called when the button is pressed.
  final VoidCallback onPressed;

  /// The controller used to drive the loading animation.
  final AnimationController controller;

  /// The icon displayed in the button.
  final IconData icon;

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton>
    with SingleTickerProviderStateMixin {
  late Animation<double> _sizeAnimation;
  late Animation<double> _buttonOpacityAnimation;
  late Animation<double> _ringThicknessAnimation;
  late Animation<double> _ringOpacityAnimation;
  late Animation<Color?> _colorAnimation;
  var _isLoading = false;
  var _hover = false;
  var _width = 120.0;

  Color? _color;
  Color? _loadingColor;

  static const _height = 40.0;
  static const double _loadingCircleRadius = _height / 2;
  static const _loadingCircleThickness = 4.0;

  @override
  void initState() {
    super.initState();

    // _colorAnimation
    // _width, _sizeAnimation

    _buttonOpacityAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Threshold(.65),
      ),
    );

    _ringThicknessAnimation =
        Tween<double>(begin: _loadingCircleRadius, end: _loadingCircleThickness)
            .animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(.65, .85),
      ),
    );
    _ringOpacityAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(.85, 1),
      ),
    );

    widget.controller.addStatusListener(handleStatusChanged);
  }

  @override
  void didChangeDependencies() {
    _updateColorAnimation();
    _updateWidth();
    super.didChangeDependencies();
  }

  void _updateColorAnimation() {
    final theme = Theme.of(context);
    final buttonTheme = theme.floatingActionButtonTheme;

    _color = widget.color ?? buttonTheme.backgroundColor;
    _loadingColor = widget.loadingColor ?? theme.colorScheme.secondary;

    _colorAnimation = ColorTween(
      begin: _color,
      end: _loadingColor,
    ).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0, .65, curve: Curves.fastOutSlowIn),
      ),
    );
  }

  @override
  void didUpdateWidget(AnimatedIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.color != widget.color ||
        oldWidget.loadingColor != widget.loadingColor) {
      _updateColorAnimation();
    }

    if (oldWidget.tooltip != widget.tooltip) {
      _updateWidth();
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.removeStatusListener(handleStatusChanged);
  }

  void handleStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.forward) {
      setState(() => _isLoading = true);
    }
    if (status == AnimationStatus.dismissed) {
      setState(() => _isLoading = false);
    }
  }

  /// sets width and size animation
  void _updateWidth() {
    final theme = Theme.of(context);
    final fontSize = theme.textTheme.labelLarge!.fontSize!;
    final renderParagraph = RenderParagraph(
      TextSpan(
        text: widget.tooltip,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: theme.textTheme.labelLarge!.fontWeight,
          letterSpacing: theme.textTheme.labelLarge!.letterSpacing,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(const BoxConstraints(minWidth: 120));

    // text width based on fontSize, plus 45.0 for padding
    final textWidth =
        renderParagraph.getMinIntrinsicWidth(fontSize).ceilToDouble() + 45.0;

    // button width is min 120.0 and max 240.0
    _width = textWidth > 120.0 && textWidth < 240.0
        ? textWidth
        : textWidth >= 240.0
            ? 240.0
            : 120.0;

    _sizeAnimation = Tween<double>(begin: 1, end: _height / _width).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0, .65, curve: Curves.fastOutSlowIn),
      ),
    );
  }

  Widget _buildButton(ThemeData theme) {
    final buttonTheme = theme.floatingActionButtonTheme;
    return FadeTransition(
      opacity: _buttonOpacityAnimation,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: AnimatedBuilder(
          animation: _colorAnimation,
          builder: (context, child) => Material(
            shape: buttonTheme.shape,
            color: _colorAnimation.value,
            shadowColor: _color,
            elevation: !_isLoading
                ? (_hover
                    ? buttonTheme.highlightElevation!
                    : buttonTheme.elevation!)
                : 0,
            child: child,
          ),
          child: InkWell(
            onTap: !_isLoading ? widget.onPressed : null,
            splashColor: buttonTheme.splashColor,
            customBorder: buttonTheme.shape,
            onHighlightChanged: (value) => setState(() => _hover = value),
            child: SizeTransition(
              sizeFactor: _sizeAnimation,
              axis: Axis.horizontal,
              child: Container(
                width: _height,
                height: _height,
                alignment: Alignment.center,
                child:
                    Icon(widget.icon, color: widget.iconColor ?? Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    //return Icon(FontAwesomeIcons.facebook);
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        FadeTransition(
          opacity: _ringOpacityAnimation,
          child: AnimatedBuilder(
            animation: _ringThicknessAnimation,
            builder: (context, child) => Ring(
              color: widget.loadingColor,
              thickness: _ringThicknessAnimation.value,
            ),
          ),
        ),
        if (_isLoading)
          SizedBox(
            width: _height - _loadingCircleThickness,
            height: _height - _loadingCircleThickness,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color?>(widget.loadingColor),
            ),
          ),
        _buildButton(theme),
      ],
    );
  }
}
