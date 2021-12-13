import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'animated_text.dart';
import 'ring.dart';

class AnimatedButton extends StatefulWidget {
  const AnimatedButton({
    Key? key,
    required this.text,
    required this.onPressed,
    required this.controller,
    this.loadingColor,
    this.color,
  }) : super(key: key);

  final String text;
  final Color? color;
  final Color? loadingColor;
  final Function? onPressed;
  final AnimationController? controller;

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late Animation<double> _sizeAnimation;
  late Animation<double> _textOpacityAnimation;
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

    _textOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: widget.controller!,
        curve: const Interval(0.0, .25),
      ),
    );

    // _colorAnimation
    // _width, _sizeAnimation

    _buttonOpacityAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: widget.controller!,
      curve: const Threshold(.65),
    ));

    _ringThicknessAnimation =
        Tween<double>(begin: _loadingCircleRadius, end: _loadingCircleThickness)
            .animate(CurvedAnimation(
      parent: widget.controller!,
      curve: const Interval(.65, .85),
    ));
    _ringOpacityAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: widget.controller!,
      curve: const Interval(.85, 1.0),
    ));

    widget.controller!.addStatusListener(handleStatusChanged);
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
        parent: widget.controller!,
        curve: const Interval(0.0, .65, curve: Curves.fastOutSlowIn),
      ),
    );
  }

  @override
  void didUpdateWidget(AnimatedButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.color != widget.color ||
        oldWidget.loadingColor != widget.loadingColor) {
      _updateColorAnimation();
    }

    if (oldWidget.text != widget.text) {
      _updateWidth();
    }
  }

  @override
  void dispose() {
    widget.controller!.removeStatusListener(handleStatusChanged);
    super.dispose();
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
        text: widget.text,
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
      parent: widget.controller!,
      curve: const Interval(0.0, .65, curve: Curves.fastOutSlowIn),
    ));
  }

  Widget _buildButtonText(ThemeData theme) {
    return FadeTransition(
      opacity: _textOpacityAnimation,
      child: AnimatedText(
        text: widget.text,
        style: theme.textTheme.button,
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
            onTap: !_isLoading ? widget.onPressed as void Function()? : null,
            splashColor: buttonTheme.splashColor,
            customBorder: buttonTheme.shape,
            onHighlightChanged: (value) => setState(() => _hover = value),
            child: SizeTransition(
              sizeFactor: _sizeAnimation,
              axis: Axis.horizontal,
              child: Container(
                width: _width,
                height: _height,
                alignment: Alignment.center,
                child: _buildButtonText(theme),
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
