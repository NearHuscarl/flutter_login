import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'ring.dart';

///similar a AnimatedButton but has an icon instead of textButton
//(basically its a modified version of the AnimatedButton Widget and may need to be cleaned up)
class AnimatedIconButton extends StatefulWidget {
  const AnimatedIconButton({
    Key? key,
    required this.tooltip,
    required this.onPressed,
    required this.controller,
    required this.icon,
    this.loadingColor,
    this.color,
  }) : super(key: key);

  final String tooltip;
  final Color? color;
  final Color? loadingColor;
  final Function onPressed;
  final AnimationController controller;
  final IconData icon;

  @override
  _AnimatedIconButtonState createState() => _AnimatedIconButtonState();
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
  static const _loadingCircleRadius = _height / 2;
  static const _loadingCircleThickness = 4.0;

  @override
  void initState() {
    super.initState();

    // _colorAnimation
    // _width, _sizeAnimation

    _buttonOpacityAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: widget.controller,
      curve: const Threshold(.65),
    ));

    _ringThicknessAnimation =
        Tween<double>(begin: _loadingCircleRadius, end: _loadingCircleThickness)
            .animate(CurvedAnimation(
      parent: widget.controller,
      curve: const Interval(.65, .85),
    ));
    _ringOpacityAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: widget.controller,
      curve: const Interval(.85, 1.0),
    ));

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
        curve: const Interval(0.0, .65, curve: Curves.fastOutSlowIn),
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

  void handleStatusChanged(status) {
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
    final fontSize = theme.textTheme.button!.fontSize!;
    final renderParagraph = RenderParagraph(
      TextSpan(
        text: widget.tooltip,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: theme.textTheme.button!.fontWeight,
          letterSpacing: theme.textTheme.button!.letterSpacing,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );

    renderParagraph.layout(const BoxConstraints(minWidth: 120.0));

    // text width based on fontSize, plus 45.0 for padding
    var textWidth =
        renderParagraph.getMinIntrinsicWidth(fontSize).ceilToDouble() + 45.0;

    // button width is min 120.0 and max 240.0
    _width = textWidth > 120.0 && textWidth < 240.0
        ? textWidth
        : textWidth >= 240.0
            ? 240.0
            : 120.0;

    _sizeAnimation = Tween<double>(begin: 1.0, end: _height / _width)
        .animate(CurvedAnimation(
      parent: widget.controller,
      curve: const Interval(0.0, .65, curve: Curves.fastOutSlowIn),
    ));
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
            onTap: !_isLoading ? widget.onPressed as void Function()? : null,
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
                child: Icon(widget.icon, color: Colors.white),
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
              size: _height,
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
              // backgroundColor: Colors.red,
              strokeWidth: _loadingCircleThickness,
            ),
          ),
        _buildButton(theme),
      ],
    );
  }
}
