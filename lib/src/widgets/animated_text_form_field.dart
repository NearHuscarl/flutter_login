import 'dart:math';
import 'package:flutter/material.dart';

enum DragDirection {
  left,
  right,
}

Interval _getInternalInterval(
  double start,
  double end,
  double externalStart,
  double externalEnd, [
  Curve curve = Curves.linear,
]) {
  return Interval(
    start + (end - start) * externalStart,
    start + (end - start) * externalEnd,
    curve: curve,
  );
}

class AnimatedTextFormField extends StatefulWidget {
  AnimatedTextFormField({
    Key key,
    Interval interval = const Interval(0.0, 1.0),
    @required this.animatedWidth,
    @required this.loadingController,
    this.inertiaController,
    this.dragDirection,
    this.enabled = true,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.controller,
    this.focusNode,
    this.validator,
    this.onFieldSubmitted,
    this.onSaved,
  })  : assert((inertiaController == null && dragDirection == null) ||
            (inertiaController != null && dragDirection != null)),
        scaleAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: loadingController,
          curve: _getInternalInterval(
              0, .2, interval.begin, interval.end, Curves.easeOutBack),
        )),
        suffixIconOpacityAnimation =
            Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: loadingController,
          curve: _getInternalInterval(.65, 1.0, interval.begin, interval.end),
        )),
        sizeAnimation = Tween<double>(
          begin: 48.0,
          end: animatedWidth,
        ).animate(CurvedAnimation(
          parent: loadingController,
          curve: _getInternalInterval(
              .2, 1.0, interval.begin, interval.end, Curves.linearToEaseOut),
          reverseCurve: Curves.easeInExpo,
        )),
        translateAnimation = (inertiaController == null)
            ? null
            : Tween<double>(
                begin: 0.0,
                end: dragDirection == DragDirection.right ? 15.0 : -15.0,
              ).animate(CurvedAnimation(
                parent: inertiaController,
                curve: Interval(0, .5, curve: Curves.easeOut),
                reverseCurve: Curves.easeIn,
              )),
        prefixIconRotationAnimation = (inertiaController == null)
            ? null
            : Tween<double>(begin: 0.0, end: pi / 12).animate(CurvedAnimation(
                parent: inertiaController,
                curve: Interval(.5, 1.0, curve: Curves.easeOut),
                reverseCurve: Curves.easeIn,
              )),
        suffixIconRotationAnimation = (inertiaController == null)
            ? null
            : Tween<double>(begin: 0.0, end: pi / 12).animate(CurvedAnimation(
                parent: inertiaController,
                curve: Interval(.5, 1.0, curve: Curves.easeOut),
                reverseCurve: Curves.easeIn,
              )),
        prefixIconTranslateAnimation = (inertiaController == null)
            ? null
            : Tween<double>(begin: 0.0, end: 8.0).animate(CurvedAnimation(
                parent: inertiaController,
                curve: Interval(.5, 1.0, curve: Curves.easeOut),
                reverseCurve: Curves.easeIn,
              )),
        suffixIconTranslateAnimation = (inertiaController == null)
            ? null
            : Tween<double>(begin: 0.0, end: 8.0).animate(CurvedAnimation(
                parent: inertiaController,
                curve: Interval(.5, 1.0, curve: Curves.easeOut),
                reverseCurve: Curves.easeIn,
              )),
        super(key: key);

  final double animatedWidth;
  final bool enabled;
  final String labelText;
  final Widget prefixIcon;
  final Widget suffixIcon;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final TextEditingController controller;
  final FocusNode focusNode;
  final FormFieldValidator<String> validator;
  final ValueChanged<String> onFieldSubmitted;
  final FormFieldSetter<String> onSaved;
  final DragDirection dragDirection;

  final AnimationController loadingController;
  final Animation<double> scaleAnimation;
  final Animation<double> sizeAnimation;
  final Animation<double> suffixIconOpacityAnimation;

  final AnimationController inertiaController;
  final Animation<double> translateAnimation;
  final Animation<double> prefixIconRotationAnimation;
  final Animation<double> suffixIconRotationAnimation;
  final Animation<double> prefixIconTranslateAnimation;
  final Animation<double> suffixIconTranslateAnimation;

  @override
  _AnimatedTextFormFieldState createState() => _AnimatedTextFormFieldState();
}

class _AnimatedTextFormFieldState extends State<AnimatedTextFormField> {
  @override
  void initState() {
    super.initState();

    widget.inertiaController?.addStatusListener(onAniStatusChanged);
  }

  @override
  dispose() {
    widget.inertiaController?.removeStatusListener(onAniStatusChanged);
    super.dispose();
  }

  void onAniStatusChanged(status) {
    if (status == AnimationStatus.completed) {
      widget.inertiaController?.reverse();
    }
  }

  Widget _buildInertiaAnimation(
    Widget child,
    Animation rotateAnimation,
    Animation translateAnimation,
  ) {
    if (rotateAnimation == null || translateAnimation == null) {
      return child;
    }

    final sign = widget.dragDirection == DragDirection.right ? 1 : -1;

    return AnimatedBuilder(
      animation: translateAnimation,
      builder: (context, child) => Transform(
        transform: Matrix4.identity()
          ..translate(sign * translateAnimation.value),
        child: child,
      ),
      child: AnimatedBuilder(
        animation: rotateAnimation,
        builder: (context, child) => Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..rotateZ(sign * rotateAnimation.value),
          child: child,
        ),
        child: child,
      ),
    );
  }

  InputDecoration _getInputDecoration(ThemeData theme) {
    final bgColor = Color.alphaBlend(
      theme.primaryColor.withOpacity(.03),
      Colors.grey.withOpacity(.09),
    );
    final errorColor = theme.accentColor.withOpacity(.2);
    final borderRadius = BorderRadius.circular(100);

    return InputDecoration(
      filled: true,
      fillColor: bgColor,
      // fillColor: _hasError ? errorColor : bgColor,
      contentPadding: EdgeInsets.symmetric(vertical: 4.0),
      labelText: widget.labelText,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent),
        borderRadius: borderRadius,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
        borderRadius: borderRadius,
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: errorColor),
        borderRadius: borderRadius,
      ),
      border: OutlineInputBorder(
        borderRadius: borderRadius,
      ),
      prefixIcon: _buildInertiaAnimation(
        widget.prefixIcon,
        widget?.prefixIconRotationAnimation,
        widget?.prefixIconTranslateAnimation,
      ),
      suffixIcon: _buildInertiaAnimation(
        FadeTransition(
          opacity: widget.suffixIconOpacityAnimation,
          child: widget.suffixIcon,
        ),
        widget?.suffixIconRotationAnimation,
        widget?.suffixIconTranslateAnimation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sizeAnimation = widget.sizeAnimation;
    final scaleAnimation = widget.scaleAnimation;
    final translateAnimation = widget?.translateAnimation;
    final textField = AnimatedBuilder(
      animation: sizeAnimation,
      builder: (context, child) => Transform(
        transform: Matrix4.identity()
          ..scale(scaleAnimation.value, scaleAnimation.value),
        alignment: Alignment.center,
        child: Container(
          width: sizeAnimation.value,
          child: child,
        ),
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        decoration: _getInputDecoration(theme),
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        obscureText: widget.obscureText,
        onFieldSubmitted: widget.onFieldSubmitted,
        onSaved: widget.onSaved,
        validator: widget.validator,
        enabled: widget.enabled,
      ),
    );

    if (translateAnimation == null) {
      return textField;
    }

    return AnimatedBuilder(
      animation: translateAnimation,
      builder: (context, child) => Transform(
        transform: Matrix4.identity()..translate(translateAnimation.value),
        child: child,
      ),
      child: textField,
    );
  }
}
