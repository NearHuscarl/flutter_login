import 'package:flutter/material.dart';
import 'animated_text.dart';
import 'ring.dart';

class AnimatedButton extends StatefulWidget {
  AnimatedButton({
    Key key,
    @required this.text,
    @required this.color,
    @required this.loadingColor,
    @required this.onPressed,
    @required this.controller,
  }) : super(key: key);

  final String text;
  final Color color;
  final Color loadingColor;
  final Future<bool> Function() onPressed;
  final AnimationController controller;

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  Animation<double> _sizeAnimation;
  Animation<double> _textOpacityAnimation;
  Animation<double> _buttonOpacityAnimation;
  Animation<double> _ringThicknessAnimation;
  Animation<double> _ringOpacityAnimation;
  Animation<Color> _colorAnimation;
  var _hover = false;
  var _isLoading = false;

  static const _width = 120.0;
  static const _height = 40.0;
  static const _loadingCircleRadius = _height / 2;
  static const _loadingCircleThickness = 4.0;

  @override
  void initState() {
    super.initState();

    _textOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: Interval(0.0, .25),
      ),
    );

    _sizeAnimation = Tween<double>(begin: 1.0, end: _height / _width)
        .animate(CurvedAnimation(
      parent: widget.controller,
      curve: Interval(0.0, .65, curve: Curves.fastOutSlowIn),
    ));

    _updateColorAnimation();

    _buttonOpacityAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: widget.controller,
      curve: Threshold(.65),
    ));

    _ringThicknessAnimation =
        Tween<double>(begin: _loadingCircleRadius, end: _loadingCircleThickness)
            .animate(CurvedAnimation(
      parent: widget.controller,
      curve: Interval(.65, .85),
    ));
    _ringOpacityAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: widget.controller,
      curve: Interval(.85, 1.0),
    ));

    widget.controller.addStatusListener(onStatusChanged);
  }

  void _updateColorAnimation() => _colorAnimation =
          ColorTween(begin: widget.color, end: widget.loadingColor)
              .animate(CurvedAnimation(
        parent: widget.controller,
        curve: Interval(0.0, .65, curve: Curves.fastOutSlowIn),
      ));

  @override
  void didUpdateWidget(AnimatedButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    _updateColorAnimation();
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.removeStatusListener(onStatusChanged);
  }

  void onStatusChanged(status) {
    if (status == AnimationStatus.forward) {
      setState(() => _isLoading = true);
    }
    if (status == AnimationStatus.dismissed) {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildButtonText(ThemeData theme) {
    return FadeTransition(
      opacity: _textOpacityAnimation,
      child: AnimatedText(
        text: widget.text,
        style: TextStyle(color: theme.primaryTextTheme.button.color),
      ),
    );
  }

  Widget _buildButton(ThemeData theme) {
    final borderRadius = BorderRadius.circular(100);

    return FadeTransition(
      opacity: _buttonOpacityAnimation,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: Colors.transparent,
          boxShadow: [
            if (!_isLoading)
              BoxShadow(
                blurRadius: _hover ? 12 : 4,
                color: widget.color.withOpacity(.4),
                offset: Offset(0, 5),
              )
          ],
        ),
        child: AnimatedBuilder(
          animation: _colorAnimation,
          builder: (context, child) => Material(
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            color: _colorAnimation.value,
            child: child,
          ),
          child: InkWell(
            onTap: !_isLoading ? widget.onPressed : null,
            onHighlightChanged: (value) => setState(() => _hover = value),
            splashColor: theme.accentColor,
            borderRadius: borderRadius,
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
          Container(
            width: _height - _loadingCircleThickness,
            height: _height - _loadingCircleThickness,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(widget.loadingColor),
              // backgroundColor: Colors.red,
              strokeWidth: _loadingCircleThickness,
            ),
          ),
        _buildButton(theme),
      ],
    );
  }
}
