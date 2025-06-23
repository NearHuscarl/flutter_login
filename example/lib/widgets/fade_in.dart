import 'package:flutter/material.dart';

enum FadeDirection {
  startToEnd,
  endToStart,
  topToBottom,
  bottomToTop,
}

class FadeIn extends StatefulWidget {
  const FadeIn({
    required this.child,
    super.key,
    this.fadeDirection = FadeDirection.startToEnd,
    this.offset = 1.0,
    this.controller,
    this.duration,
    this.curve = Curves.easeOut,
  })  : assert(
          controller == null && duration != null ||
              controller != null && duration == null,
          'You must provide either a [duration] or a [controller], but not both.',
        ),
        assert(
          offset > 0,
          '[offset] must be greater than zero to apply a visible fade/slide effect.',
        );

  /// [FadeIn] animation can be controlled via external [controller]. If
  /// [controller] is not provided, it will use the default internal controller
  /// which will run the animation in initState()
  final AnimationController? controller;
  final FadeDirection fadeDirection;
  final double offset;
  final Widget child;
  final Duration? duration;
  final Curve curve;

  @override
  FadeInState createState() => FadeInState();
}

class FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    if (widget.controller == null) {
      _controller = AnimationController(
        vsync: this,
        duration: widget.duration,
      );
    }

    _updateAnimations();
    _controller?.forward();
  }

  void _updateAnimations() {
    Offset? begin;
    Offset? end;
    final offset = widget.offset;

    switch (widget.fadeDirection) {
      case FadeDirection.startToEnd:
        begin = Offset(-offset, 0);
        end = Offset.zero;
      case FadeDirection.endToStart:
        begin = Offset(offset, 0);
        end = Offset.zero;
      case FadeDirection.topToBottom:
        begin = Offset(0, -offset);
        end = Offset.zero;
      case FadeDirection.bottomToTop:
        begin = Offset(0, offset);
        end = Offset.zero;
    }

    _slideAnimation = Tween<Offset>(
      begin: begin,
      end: end,
    ).animate(
      CurvedAnimation(
        parent: _effectiveController!,
        curve: widget.curve,
      ),
    );
    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _effectiveController!,
        curve: widget.curve,
      ),
    );
  }

  AnimationController? get _effectiveController =>
      widget.controller ?? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
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
