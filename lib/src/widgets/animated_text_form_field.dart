import 'package:flutter/material.dart';

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
    @required this.animationController,
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
  })  : scaleAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animationController,
          curve: _getInternalInterval(
              0, .2, interval.begin, interval.end, Curves.easeOutBack),
        )),
        prefixIconOpacityAnimation =
            Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: animationController,
          curve: _getInternalInterval(.2, .55, interval.begin, interval.end),
        )),
        suffixIconOpacityAnimation =
            Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: animationController,
          curve: _getInternalInterval(.65, 1.0, interval.begin, interval.end),
        )),
        sizeAnimation = Tween<double>(
          begin: 48.0,
          end: animatedWidth,
        ).animate(CurvedAnimation(
          parent: animationController,
          curve: _getInternalInterval(
              .2, 1.0, interval.begin, interval.end, Curves.linearToEaseOut),
          reverseCurve: Curves.easeInExpo,
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

  final AnimationController animationController;
  final Animation<double> scaleAnimation;
  final Animation<double> sizeAnimation;
  final Animation<double> prefixIconOpacityAnimation;
  final Animation<double> suffixIconOpacityAnimation;

  @override
  _AnimatedTextFormFieldState createState() => _AnimatedTextFormFieldState();
}

class _AnimatedTextFormFieldState extends State<AnimatedTextFormField> {
  GlobalKey<FormFieldState<String>> _textFieldKey = GlobalKey();
  // var _hasError = false;

  // @override
  // void didUpdateWidget(Widget oldWidget) {
  //   super.didUpdateWidget(oldWidget);

  //   _hasError = _textFieldKey.currentState != null
  //       ? _textFieldKey.currentState.hasError
  //       : false;
  // }

  InputDecoration _getInputDecoration(ThemeData theme) {
    final bgColor = Colors.grey.withOpacity(.15);
    final errorColor = theme.accentColor.withOpacity(.2);
    final borderRadius = BorderRadius.circular(100);

    return InputDecoration(
      filled: true,
      fillColor: bgColor,
      // fillColor: _hasError ? errorColor : bgColor,
      contentPadding: EdgeInsets.symmetric(vertical: 4.0),
      labelText: widget.labelText,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: bgColor),
        borderRadius: borderRadius,
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: errorColor),
        borderRadius: borderRadius,
      ),
      border: OutlineInputBorder(
        borderRadius: borderRadius,
      ),
      prefixIcon: FadeTransition(
        opacity: widget.prefixIconOpacityAnimation,
        child: widget.prefixIcon,
      ),
      suffixIcon: FadeTransition(
        opacity: widget.suffixIconOpacityAnimation,
        child: widget.suffixIcon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sizeAnimation = widget.sizeAnimation;
    final scaleAnimation = widget.scaleAnimation;

    return AnimatedBuilder(
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
        key: _textFieldKey,
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
  }
}
