import 'package:flutter/material.dart';

enum FadeDirection {
  startToEnd,
  endToStart,
  topToBottom,
  bottomToTop,
}

class FadeIn extends StatefulWidget {
  FadeIn({
    Key key,
    this.fadeDirection = FadeDirection.startToEnd,
    @required this.child,
    @required this.duration,
  }) : super(key: key);

  final FadeDirection fadeDirection;
  final Widget child;
  final Duration duration;

  @override
  _FadeInState createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _slideAnimation;
  Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    Offset begin;
    Offset end;

    switch (widget.fadeDirection) {
      case FadeDirection.startToEnd:
        begin = Offset(-1, 0);
        end = Offset(0, 0);
        break;
      case FadeDirection.endToStart:
        begin = Offset(1, 0);
        end = Offset(0, 0);
        break;
      case FadeDirection.topToBottom:
        begin = Offset(0, -1);
        end = Offset(0, 0);
        break;
      case FadeDirection.bottomToTop:
        begin = Offset(0, 1);
        end = Offset(0, 0);
        break;
    }

    _slideAnimation = Tween<Offset>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.5, 1.0, curve: Curves.easeOut),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: widget.child,
      ),
    );
  }
}
