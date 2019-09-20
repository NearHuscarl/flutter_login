import 'package:flutter/material.dart';

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

class _AnimatedButtonState extends State<AnimatedButton> {
  Animation<double> _sizeAnimation;
  Animation<double> _textOpacityAnimation;
  Animation<double> _buttonOpacityAnimation;
  Animation<double> _indicatorOpacityAnimation;
  Animation<Color> _colorAnimation;
  var _buttonEnabled = true;
  var _hover = false;

  static const _width = 120.0;
  static const _height = 40.0;

  @override
  void initState() {
    super.initState();

    _textOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: Interval(0.0, .3),
      ),
    );

    _sizeAnimation = Tween<double>(begin: 1.0, end: _height / _width)
        .animate(CurvedAnimation(
      parent: widget.controller,
      curve: Interval(0.0, .75, curve: Curves.fastOutSlowIn),
    ));

    _colorAnimation = ColorTween(begin: widget.color, end: widget.loadingColor)
        .animate(CurvedAnimation(
      parent: widget.controller,
      curve: Interval(0.0, .75, curve: Curves.fastOutSlowIn),
    ));

    _buttonOpacityAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: widget.controller,
      curve: Interval(.75, 1.0),
    ));

    _indicatorOpacityAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: widget.controller,
      curve: Interval(.75, 1.0),
    ));

    widget.controller.addStatusListener((status) {
      if (status == AnimationStatus.forward) {
        setState(() => _buttonEnabled = false);
      }
      if (status == AnimationStatus.dismissed) {
        setState(() => _buttonEnabled = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(100);
    final theme = Theme.of(context);

    return Stack(
      children: <Widget>[
        FadeTransition(
          opacity: _indicatorOpacityAnimation,
          child: Container(
            height: _height,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(widget.loadingColor),
            ),
          ),
        ),
        FadeTransition(
          opacity: _buttonOpacityAnimation,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: Colors.transparent,
              boxShadow: [
                if (_buttonEnabled)
                  BoxShadow(
                    blurRadius: _hover ? 12 : 4,
                    color: theme.primaryColor.withOpacity(.4),
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
                onTap: _buttonEnabled ? widget.onPressed : null,
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
                    child: FadeTransition(
                      opacity: _textOpacityAnimation,
                      child: Text(
                        widget.text,
                        style: TextStyle(
                            color: theme.primaryTextTheme.button.color),
                        overflow: TextOverflow.visible,
                        softWrap: false,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
