import 'package:flutter/material.dart';

class ExpandableContainer extends StatelessWidget {
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
  })  : sizeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: controller,
          curve: const Interval(0.0, .6875, curve: Curves.bounceOut),
          reverseCurve: const Interval(0.0, .6875, curve: Curves.bounceIn),
        )),
        slideAnimation = Tween<Offset>(
          begin: const Offset(-1, 0),
          end: const Offset(0, 0),
        ).animate(CurvedAnimation(
          parent: controller,
          curve: const Interval(.6875, 1.0, curve: Curves.fastOutSlowIn),
        ))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              if (onExpandCompleted != null) {
                onExpandCompleted();
              }
            }
          }),
        super(key: key);

  final AnimationController controller;
  final Function onExpandCompleted;
  final Widget child;
  final Alignment alignment;
  final Color backgroundColor;
  final Color color;
  final double width;
  final double height;
  final EdgeInsetsGeometry padding;

  final Animation<double> sizeAnimation;
  final Animation<Offset> slideAnimation;

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: sizeAnimation,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(color: backgroundColor),
            ),
          ),
          SlideTransition(
            position: slideAnimation,
            child: Container(
              alignment: alignment,
              color: color,
              width: width,
              height: height,
              padding: padding,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
