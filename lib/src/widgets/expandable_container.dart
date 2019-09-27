import 'package:flutter/material.dart';

class ExpandableContainer extends StatelessWidget {
  ExpandableContainer({
    Key key,
    @required this.child,
    @required this.controller,
    this.onExpandCompleted,
    this.background,
  })  : sizeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: controller,
          curve: Interval(0.0, .75, curve: Curves.bounceOut),
          reverseCurve: Interval(0.0, .75, curve: Curves.bounceIn),
        )),
        slideAnimation = Tween<Offset>(
          begin: Offset(-1, 0),
          end: Offset(0, 0),
        ).animate(CurvedAnimation(
          parent: controller,
          curve: Interval(.75, 1.0, curve: Curves.fastOutSlowIn),
        ))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              onExpandCompleted();
            }
          }),
        super(key: key);

  final Widget child;
  final AnimationController controller;
  final Function onExpandCompleted;
  final Color background;

  final Animation<double> sizeAnimation;
  final Animation<Offset> slideAnimation;

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: sizeAnimation,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Container(color: background),
          ),
          SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        ],
      ),
    );
  }
}
