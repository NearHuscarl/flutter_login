import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum TextFieldInertiaDirection {
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
    @required this.width,
    this.loadingController,
    this.inertiaController,
    this.inertiaDirection,
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
  })  : assert((inertiaController == null && inertiaDirection == null) ||
            (inertiaController != null && inertiaDirection != null)),
        super(key: key);

  final Interval interval;
  final AnimationController loadingController;
  final AnimationController inertiaController;
  final double width;
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
  final TextFieldInertiaDirection inertiaDirection;

  @override
  _AnimatedTextFormFieldState createState() => _AnimatedTextFormFieldState();
}

class _AnimatedTextFormFieldState extends State<AnimatedTextFormField> {
  Animation<double> scaleAnimation;
  Animation<double> sizeAnimation;
  Animation<double> suffixIconOpacityAnimation;

  Animation<double> fieldTranslateAnimation;
  Animation<double> iconRotationAnimation;
  Animation<double> iconTranslateAnimation;

  @override
  void initState() {
    super.initState();

    widget.inertiaController?.addStatusListener(handleAnimationStatus);

    final interval = widget.interval;
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
      _updateSizeAnimation();
    }

    final inertiaController = widget.inertiaController;
    final inertiaDirection = widget.inertiaDirection;
    final sign = inertiaDirection == TextFieldInertiaDirection.right ? 1 : -1;

    if (inertiaController != null) {
      fieldTranslateAnimation = Tween<double>(
        begin: 0.0,
        end: sign * 15.0,
      ).animate(CurvedAnimation(
        parent: inertiaController,
        curve: Interval(0, .5, curve: Curves.easeOut),
        reverseCurve: Curves.easeIn,
      ));
      iconRotationAnimation =
          Tween<double>(begin: 0.0, end: sign * pi / 12 /* ~15deg */)
              .animate(CurvedAnimation(
        parent: inertiaController,
        curve: Interval(.5, 1.0, curve: Curves.easeOut),
        reverseCurve: Curves.easeIn,
      ));
      iconTranslateAnimation =
          Tween<double>(begin: 0.0, end: 8.0).animate(CurvedAnimation(
        parent: inertiaController,
        curve: Interval(.5, 1.0, curve: Curves.easeOut),
        reverseCurve: Curves.easeIn,
      ));
    }
  }

  void _updateSizeAnimation() {
    final interval = widget.interval;
    final loadingController = widget.loadingController;

    sizeAnimation = Tween<double>(
      begin: 48.0,
      end: widget.width,
    ).animate(CurvedAnimation(
      parent: loadingController,
      curve: _getInternalInterval(
          .2, 1.0, interval.begin, interval.end, Curves.linearToEaseOut),
      reverseCurve: Curves.easeInExpo,
    ));
  }

  @override
  void didUpdateWidget(AnimatedTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.width != widget.width) {
      _updateSizeAnimation();
    }
  }

  @override
  dispose() {
    widget.inertiaController?.removeStatusListener(handleAnimationStatus);
    super.dispose();
  }

  void handleAnimationStatus(status) {
    if (status == AnimationStatus.completed) {
      widget.inertiaController?.reverse();
    }
  }

  Widget _buildInertiaAnimation(Widget child) {
    if (widget.inertiaController == null) {
      return child;
    }

    return AnimatedBuilder(
      animation: iconTranslateAnimation,
      builder: (context, child) => Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..translate(iconTranslateAnimation.value)
          ..rotateZ(iconRotationAnimation.value),
        child: child,
      ),
      child: child,
    );
  }

  InputDecoration _getInputDecoration(ThemeData theme) {
    return InputDecoration(
      labelText: widget.labelText,
      prefixIcon: _buildInertiaAnimation(widget.prefixIcon),
      suffixIcon: _buildInertiaAnimation(widget.loadingController != null
          ? FadeTransition(
              opacity: suffixIconOpacityAnimation,
              child: widget.suffixIcon,
            )
          : widget.suffixIcon),
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
      textField = ScaleTransition(
        scale: scaleAnimation,
        child: AnimatedBuilder(
          animation: sizeAnimation,
          builder: (context, child) => ConstrainedBox(
            constraints: BoxConstraints.tightFor(width: sizeAnimation.value),
            child: child,
          ),
          child: textField,
        ),
      );
    }

    if (widget.inertiaController != null) {
      textField = AnimatedBuilder(
        animation: fieldTranslateAnimation,
        builder: (context, child) => Transform.translate(
          offset: Offset(fieldTranslateAnimation.value, 0),
          child: child,
        ),
        child: textField,
      );
    }

    return textField;
  }
}

class AnimatedPasswordTextFormField extends StatefulWidget {
  AnimatedPasswordTextFormField({
    Key key,
    this.interval = const Interval(0.0, 1.0),
    @required this.animatedWidth,
    this.loadingController,
    this.inertiaController,
    this.inertiaDirection,
    this.enabled = true,
    this.labelText,
    this.keyboardType,
    this.textInputAction,
    this.controller,
    this.focusNode,
    this.validator,
    this.onFieldSubmitted,
    this.onSaved,
  })  : assert((inertiaController == null && inertiaDirection == null) ||
            (inertiaController != null && inertiaDirection != null)),
        super(key: key);

  final Interval interval;
  final AnimationController loadingController;
  final AnimationController inertiaController;
  final double animatedWidth;
  final bool enabled;
  final String labelText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final TextEditingController controller;
  final FocusNode focusNode;
  final FormFieldValidator<String> validator;
  final ValueChanged<String> onFieldSubmitted;
  final FormFieldSetter<String> onSaved;
  final TextFieldInertiaDirection inertiaDirection;

  @override
  _AnimatedPasswordTextFormFieldState createState() =>
      _AnimatedPasswordTextFormFieldState();
}

class _AnimatedPasswordTextFormFieldState
    extends State<AnimatedPasswordTextFormField> {
  var _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedTextFormField(
      interval: widget.interval,
      loadingController: widget.loadingController,
      inertiaController: widget.inertiaController,
      width: widget.animatedWidth,
      enabled: widget.enabled,
      labelText: widget.labelText,
      prefixIcon: Icon(FontAwesomeIcons.lock, size: 20),
      suffixIcon: GestureDetector(
        onTap: () => setState(() => _obscureText = !_obscureText),
        dragStartBehavior: DragStartBehavior.down,
        child: AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          firstCurve: Curves.easeInOutSine,
          secondCurve: Curves.easeInOutSine,
          alignment: Alignment.center,
          layoutBuilder: (Widget topChild, _, Widget bottomChild, __) {
            return Stack(
              alignment: Alignment.center,
              children: <Widget>[bottomChild, topChild],
            );
          },
          firstChild: Icon(
            Icons.visibility,
            size: 25.0,
            semanticLabel: 'show password',
          ),
          secondChild: Icon(
            Icons.visibility_off,
            size: 25.0,
            semanticLabel: 'hide password',
          ),
          crossFadeState: _obscureText
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
        ),
      ),
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      controller: widget.controller,
      focusNode: widget.focusNode,
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      onSaved: widget.onSaved,
      inertiaDirection: widget.inertiaDirection,
    );
  }
}
