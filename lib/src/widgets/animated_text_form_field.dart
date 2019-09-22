import 'package:flutter/material.dart';

enum TextFieldType {
  normal,
  password,
}

class AnimatedTextFormField extends StatefulWidget {
  AnimatedTextFormField({
    Key key,
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
  })  : prefixIconOpacityAnimation =
            Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: animationController,
          curve: Interval(0, .35),
        )),
        suffixIconOpacityAnimation =
            Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: animationController,
          curve: Interval(.65, 1.0),
        )),
        sizeAnimation = Tween<double>(
          begin: 48.0,
          end: animatedWidth,
        ).animate(CurvedAnimation(
          parent: animationController,
          curve: Interval(0, 1.0, curve: Curves.linearToEaseOut),
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
  final Animation<double> sizeAnimation;
  final Animation<double> prefixIconOpacityAnimation;
  final Animation<double> suffixIconOpacityAnimation;

  @override
  _AnimatedTextFormFieldState createState() => _AnimatedTextFormFieldState();
}

class _AnimatedTextFormFieldState extends State<AnimatedTextFormField> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.sizeAnimation,
      builder: (context, child) => Container(
        width: widget.sizeAnimation.value,
        child: child,
      ),
      child: TextFormField(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 4.0),
          labelText: widget.labelText,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.all(
              Radius.circular(100),
            ),
          ),
          prefixIcon: FadeTransition(
            opacity: widget.prefixIconOpacityAnimation,
            child: widget.prefixIcon,
          ),
          suffixIcon: FadeTransition(
            opacity: widget.suffixIconOpacityAnimation,
            child: widget.suffixIcon,
          ),
        ),
        enabled: widget.enabled,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        obscureText: widget.obscureText,
        controller: widget.controller,
        focusNode: widget.focusNode,
        onFieldSubmitted: widget.onFieldSubmitted,
        validator: widget.validator,
        onSaved: widget.onSaved,
      ),
    );
  }
}
