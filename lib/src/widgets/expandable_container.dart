import 'package:flutter/material.dart';

class ExpandableContainer extends StatefulWidget {
  ExpandableContainer({
    Key key,
    @required this.child,
    @required this.controller,
    this.background,
  }) : super(key: key);

  final Widget child;
  final AnimationController controller;
  final Color background;

  @override
  _ExpandableContainerState createState() => _ExpandableContainerState();
}

class _ExpandableContainerState extends State<ExpandableContainer> {
  Animation<double> _sizeAnimation;
  Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _sizeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: widget.controller,
      curve: Interval(0.0, 0.5, curve: Curves.linear),
    ));
    _slideAnimation = Tween<Offset>(
      begin: Offset(-1, 0),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: widget.controller,
      curve: Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _sizeAnimation,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Container(color: widget.background),
          ),
          SlideTransition(
            position: _slideAnimation,
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
