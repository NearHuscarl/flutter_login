import 'dart:math';

import 'package:flutter/material.dart';

import '../math_helper.dart';
import '../matrix.dart';

enum AnimatedTextRotation { up, down }

/// https://medium.com/flutter-community/flutter-challenge-3d-bottom-navigation-bar-48952a5fd996
class AnimatedText extends StatefulWidget {
  AnimatedText({
    Key key,
    @required this.text,
    this.padding = 4.0,
    this.style,
    this.onAnimationStatusChanged,
    this.textRotation = AnimatedTextRotation.up,
  }) : super(key: key);

  final String text;
  final double padding;
  final TextStyle style;
  final AnimatedTextRotation textRotation;
  final AnimationStatusListener onAnimationStatusChanged;

  @override
  _AnimatedTextState createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText>
    with SingleTickerProviderStateMixin {
  var _newText = '';
  var _oldText = '';
  var _layoutHeight = 0.0;
  final _textKey = GlobalKey();

  Animation<double> _animation;
  AnimationController _controller;

  double get radius => (_layoutHeight + widget.padding) / 2;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    )..addStatusListener(widget.onAnimationStatusChanged);

    _animation = Tween<double>(begin: 0.0, end: pi / 2).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _oldText = widget.text;
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
  }

  void _afterLayout(Duration timeStamp) {
    _layoutHeight = _getWidgetSize()?.height;
  }

  @override
  void didUpdateWidget(AnimatedText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.text != oldWidget.text) {
      _oldText = oldWidget.text;
      _newText = widget.text;
      _controller.forward().then((void _) {
        final t = _oldText;

        _oldText = _newText;
        _newText = t;
        _controller.reset();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Size _getWidgetSize() {
    final RenderBox renderBox = _textKey.currentContext?.findRenderObject();
    return renderBox?.size;
  }

  Matrix4 _getFrontSideUp(double value) {
    return Matrix.perspective(.006)
      ..translate(
        0.0,
        -radius * sin(_animation.value),
        -radius * cos(_animation.value),
      )
      ..rotateX(-_animation.value); // 0 -> -pi/2
  }

  Matrix4 _getBackSideUp(double value) {
    return Matrix.perspective(.006)
      ..translate(
        0.0,
        radius * cos(_animation.value),
        -radius * sin(_animation.value),
      )
      ..rotateX((pi / 2) - _animation.value); // pi/2 -> 0
  }

  Matrix4 _getFrontSideDown(double value) {
    return Matrix.perspective(.006)
      ..translate(
        0.0,
        radius * sin(_animation.value),
        -radius * cos(_animation.value),
      )
      ..rotateX(_animation.value); // 0 -> pi/2
  }

  Matrix4 _getBackSideDown(double value) {
    return Matrix.perspective(.006)
      ..translate(
        0.0,
        -radius * cos(_animation.value),
        -radius * sin(_animation.value),
      )
      ..rotateX(_animation.value - pi / 2); // -pi/2 -> 0
  }

  @override
  Widget build(BuildContext context) {
    final rollUp = widget.textRotation == AnimatedTextRotation.up;
    final oldText = Text(
      _oldText,
      key: _textKey,
      style: widget.style,
      overflow: TextOverflow.visible,
      softWrap: false,
    );
    final newText = Text(
      _newText,
      style: widget.style,
      overflow: TextOverflow.visible,
      softWrap: false,
    );

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Stack(
        alignment: Alignment.center,
        children: <Widget>[
          _animation.value <= MathHelper.toRadian(85)
              ? Transform(
                  alignment: Alignment.center,
                  transform: rollUp
                      ? _getFrontSideUp(_animation.value)
                      : _getFrontSideDown(_animation.value),
                  child: oldText,
                )
              : Container(width: 0, height: 0),
          _animation.value >= MathHelper.toRadian(5)
              ? Transform(
                  alignment: Alignment.center,
                  transform: rollUp
                      ? _getBackSideUp(_animation.value)
                      : _getBackSideDown(_animation.value),
                  child: newText,
                )
              : Container(width: 0, height: 0),
        ],
      ),
    );
  }
}
