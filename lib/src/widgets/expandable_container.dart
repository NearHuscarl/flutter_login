import 'package:flutter/material.dart';

/// Represents the visual state of an [ExpandableContainer].
enum ExpandableContainerState {
  /// The container is fully expanded and visible.
  expanded,

  /// The container is collapsed (shrunk) and hidden or minimized.
  shrunk,
}

/// A container widget that can animate between expanded and shrunk states.
///
/// Useful for showing/hiding UI content smoothly using an [AnimationController].
/// Can be customized with alignment, colors, size, and padding.
///
/// The expansion and collapse are driven by the provided [controller].
class ExpandableContainer extends StatefulWidget {
  /// Creates an [ExpandableContainer] that expands or shrinks based on [controller].
  ///
  /// The [child] and [controller] are required. You may optionally provide
  /// dimensions, alignment, colors, and padding.
  const ExpandableContainer({
    required this.child,
    required this.controller,
    super.key,
    this.onExpandCompleted,
    this.alignment,
    this.backgroundColor,
    this.color,
    this.width,
    this.height,
    this.padding,
    this.initialState = ExpandableContainerState.shrunk,
  });

  /// The animation controller driving expansion or collapse.
  final AnimationController controller;

  /// Callback triggered when expansion animation completes.
  final VoidCallback? onExpandCompleted;

  /// The widget displayed inside the container.
  final Widget child;

  /// Alignment of the child within the container.
  final Alignment? alignment;

  /// The background color behind the container.
  final Color? backgroundColor;

  /// The container’s foreground color.
  final Color? color;

  /// Width of the container when expanded.
  final double? width;

  /// Height of the container when expanded.
  final double? height;

  /// Padding inside the container.
  final EdgeInsetsGeometry? padding;

  /// The initial state of the container (expanded or shrunk).
  final ExpandableContainerState initialState;

  @override
  State<ExpandableContainer> createState() => _ExpandableContainerState();
}

class _ExpandableContainerState extends State<ExpandableContainer> {
  late Animation<double> _sizeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    if (widget.initialState == ExpandableContainerState.expanded) {
      _controller = widget.controller..value = 1;
    } else {
      _controller = widget.controller..value = 0;
    }

    _sizeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, .6875, curve: Curves.bounceOut),
        reverseCurve: const Interval(0, .6875, curve: Curves.bounceIn),
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(.6875, 1, curve: Curves.fastOutSlowIn),
      ),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onExpandCompleted?.call();
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _sizeAnimation,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(color: widget.backgroundColor),
            ),
          ),
          SlideTransition(
            position: _slideAnimation,
            child: Container(
              alignment: widget.alignment,
              color: widget.color,
              width: widget.width,
              height: widget.height,
              padding: widget.padding,
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}
