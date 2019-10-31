import 'package:flutter/material.dart';

enum ExpandableContainerState {
  expanded,
  shrunk,
}

class ExpandableContainer extends StatefulWidget {
  ExpandableContainer({
    Key key,
    @required this.child,
    @required this.controller,
    this.onExpandCompleted,
    this.alignment,
    this.backgroundColor,
    this.color,
    this.width,
    this.height,
    this.padding,
    this.initialState = ExpandableContainerState.shrunk,
  }) : super(key: key);

  final AnimationController controller;
  final Function onExpandCompleted;
  final Widget child;
  final Alignment alignment;
  final Color backgroundColor;
  final Color color;
  final double width;
  final double height;
  final EdgeInsetsGeometry padding;
  final ExpandableContainerState initialState;

  @override
  _ExpandableContainerState createState() => _ExpandableContainerState();
}

class _ExpandableContainerState extends State<ExpandableContainer> {
  Animation<double> _sizeAnimation;
  Animation<Offset> _slideAnimation;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();

    if (widget.initialState == ExpandableContainerState.expanded) {
      _controller = widget.controller..value = 1;
    } else {
      _controller = widget.controller..value = 0;
    }

    _sizeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, .6875, curve: Curves.bounceOut),
      reverseCurve: const Interval(0.0, .6875, curve: Curves.bounceIn),
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(.6875, 1.0, curve: Curves.fastOutSlowIn),
    ))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget?.onExpandCompleted();
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
