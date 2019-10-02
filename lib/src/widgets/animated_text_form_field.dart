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
    this.interval = const Interval(0.0, 1.0),
    @required this.animatedWidth,
    this.loadingController,
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
        super(key: key);

  final Interval interval;
  final AnimationController loadingController;
  final AnimationController inertiaController;
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

  @override
  _AnimatedTextFormFieldState createState() => _AnimatedTextFormFieldState();
}

class _AnimatedTextFormFieldState extends State<AnimatedTextFormField> {
  Animation<double> scaleAnimation;
  Animation<double> sizeAnimation;
  Animation<double> suffixIconOpacityAnimation;

  Animation<double> translateAnimation;
  Animation<double> prefixIconRotationAnimation;
  Animation<double> suffixIconRotationAnimation;
  Animation<double> prefixIconTranslateAnimation;
  Animation<double> suffixIconTranslateAnimation;

  @override
  void initState() {
    super.initState();

    widget.inertiaController?.addStatusListener(onAniStatusChanged);

    final interval = widget.interval;
    final dragDirection = widget.dragDirection;
    final loadingController = widget.loadingController;

    if (loadingController != null) {
      scaleAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: loadingController,
        curve: _getInternalInterval(
            0, .2, interval.begin, interval.end, Curves.easeOutBack),
      ));
      suffixIconOpacityAnimation =
          Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: loadingController,
        curve: _getInternalInterval(.65, 1.0, interval.begin, interval.end),
      ));
      sizeAnimation = Tween<double>(
        begin: 48.0,
        end: widget.animatedWidth,
      ).animate(CurvedAnimation(
        parent: loadingController,
        curve: _getInternalInterval(
            .2, 1.0, interval.begin, interval.end, Curves.linearToEaseOut),
        reverseCurve: Curves.easeInExpo,
      ));
    }

    final inertiaController = widget.inertiaController;

    if (inertiaController != null) {
      translateAnimation = Tween<double>(
        begin: 0.0,
        end: dragDirection == DragDirection.right ? 15.0 : -15.0,
      ).animate(CurvedAnimation(
        parent: inertiaController,
        curve: Interval(0, .5, curve: Curves.easeOut),
        reverseCurve: Curves.easeIn,
      ));
      prefixIconRotationAnimation =
          Tween<double>(begin: 0.0, end: pi / 12).animate(CurvedAnimation(
        parent: inertiaController,
        curve: Interval(.5, 1.0, curve: Curves.easeOut),
        reverseCurve: Curves.easeIn,
      ));
      suffixIconRotationAnimation =
          Tween<double>(begin: 0.0, end: pi / 12).animate(CurvedAnimation(
        parent: inertiaController,
        curve: Interval(.5, 1.0, curve: Curves.easeOut),
        reverseCurve: Curves.easeIn,
      ));
      prefixIconTranslateAnimation =
          Tween<double>(begin: 0.0, end: 8.0).animate(CurvedAnimation(
        parent: inertiaController,
        curve: Interval(.5, 1.0, curve: Curves.easeOut),
        reverseCurve: Curves.easeIn,
      ));
      suffixIconTranslateAnimation =
          Tween<double>(begin: 0.0, end: 8.0).animate(CurvedAnimation(
        parent: inertiaController,
        curve: Interval(.5, 1.0, curve: Curves.easeOut),
        reverseCurve: Curves.easeIn,
      ));
    }
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
    if (widget.inertiaController == null) {
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
        prefixIconRotationAnimation,
        prefixIconTranslateAnimation,
      ),
      suffixIcon: _buildInertiaAnimation(
        widget.loadingController != null
            ? FadeTransition(
                opacity: suffixIconOpacityAnimation,
                child: widget.suffixIcon,
              )
            : widget.suffixIcon,
        suffixIconRotationAnimation,
        suffixIconTranslateAnimation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget textField = TextFormField(
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
    );

    if (widget.loadingController != null) {
      textField = AnimatedBuilder(
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
        child: textField,
      );
    }

    if (widget.inertiaController != null) {
      textField = AnimatedBuilder(
        animation: translateAnimation,
        builder: (context, child) => Transform(
          transform: Matrix4.identity()..translate(translateAnimation.value),
          child: child,
        ),
        child: textField,
      );
    }

    return textField;
  }
}
