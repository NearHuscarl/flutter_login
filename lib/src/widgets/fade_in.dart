import 'package:flutter/material.dart';

/// Defines the direction from which a widget should fade and slide in.
enum FadeDirection {
  /// Fades in while sliding from the start (left in LTR, right in RTL).
  startToEnd,

  /// Fades in while sliding from the end (right in LTR, left in RTL).
  endToStart,

  /// Fades in while sliding from the top down.
  topToBottom,

  /// Fades in while sliding from the bottom up.
  bottomToTop,
}

/// A widget that animates its [child] into view with a fade and slide effect.
///
/// The animation can be either automatically triggered or controlled manually
/// via an external [AnimationController]. The fade direction and offset can be customized.
class FadeIn extends StatefulWidget {
  /// Creates a [FadeIn] widget that fades and slides its [child] into view.
  ///
  /// Provide either a [controller] or a [duration], not both. If [controller]
  /// is omitted, an internal controller will be used to trigger the animation
  /// automatically in `initState()`.
  ///
  /// The [offset] must be greater than 0.
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
          'You must provide either a controller or a duration, not both.',
        ),
        assert(offset > 0, 'Offset must be greater than 0.');

  /// Optional external animation controller. If provided, you must manage
  /// the animation lifecycle yourself.
  final AnimationController? controller;

  /// The direction from which the widget should animate into view.
  final FadeDirection fadeDirection;

  /// The amount (in logical pixels) to offset the widget before fading in.
  ///
  /// Higher values mean the widget starts farther away and slides a greater distance.
  final double offset;

  /// The widget to animate in.
  final Widget? child;

  /// Duration of the animation if [controller] is not provided.
  final Duration? duration;

  /// Curve used for the animation's easing.
  final Curve? curve;

  @override
  State<FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
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
        curve: widget.curve!,
      ),
    );
    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _effectiveController!,
        curve: widget.curve!,
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
