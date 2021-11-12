import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnimatedNumericText extends StatelessWidget {
  AnimatedNumericText({
    Key? key,
    required this.initialValue,
    required this.targetValue,
    required this.controller,
    this.curve = Curves.linear,
    this.formatter = '#,##0.00',
    this.style,
  })  : numberFormat = NumberFormat(formatter),
        numberAnimation = Tween<double>(
          begin: initialValue,
          end: targetValue,
        ).animate(CurvedAnimation(
          parent: controller,
          curve: curve,
        )),
        super(key: key);

  final double initialValue;
  final double targetValue;
  final AnimationController controller;
  final Curve curve;
  final String formatter;
  final TextStyle? style;
  final NumberFormat numberFormat;
  final Animation<double> numberAnimation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: numberAnimation,
      builder: (context, child) => Text(
        numberFormat.format(numberAnimation.value),
        style: style,
      ),
    );
  }
}
