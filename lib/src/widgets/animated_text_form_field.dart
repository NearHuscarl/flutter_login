import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart' as pnp;

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
  const AnimatedTextFormField({
    super.key,
    this.textFormFieldKey,
    this.interval = const Interval(0.0, 1.0),
    required this.width,
    this.userType,
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
    this.autocorrect = false,
    this.autofillHints,
    this.tooltip,
  }) : assert(
          (inertiaController == null && inertiaDirection == null) ||
              (inertiaController != null && inertiaDirection != null),
        );

  final Key? textFormFieldKey;
  final Interval? interval;
  final AnimationController? loadingController;
  final AnimationController? inertiaController;
  final double width;
  final LoginUserType? userType;
  final bool enabled;
  final bool autocorrect;
  final Iterable<String>? autofillHints;
  final String? labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldSetter<String>? onSaved;
  final TextFieldInertiaDirection? inertiaDirection;
  final InlineSpan? tooltip;

  @override
  State<AnimatedTextFormField> createState() => _AnimatedTextFormFieldState();
}

class _AnimatedTextFormFieldState extends State<AnimatedTextFormField> {
  late Animation<double> scaleAnimation;
  late Animation<double> sizeAnimation;
  late Animation<double> suffixIconOpacityAnimation;

  late Animation<double> fieldTranslateAnimation;
  late Animation<double> iconRotationAnimation;
  late Animation<double> iconTranslateAnimation;

  PhoneNumber? _phoneNumberInitialValue;
  final TextEditingController _phoneNumberController = TextEditingController();

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
      ).animate(
        CurvedAnimation(
          parent: loadingController,
          curve: _getInternalInterval(
            0,
            .2,
            interval!.begin,
            interval.end,
            Curves.easeOutBack,
          ),
        ),
      );
      suffixIconOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: loadingController,
          curve: _getInternalInterval(.65, 1.0, interval.begin, interval.end),
        ),
      );
      _updateSizeAnimation();
    }

    final inertiaController = widget.inertiaController;
    final inertiaDirection = widget.inertiaDirection;
    final sign = inertiaDirection == TextFieldInertiaDirection.right ? 1 : -1;

    if (inertiaController != null) {
      fieldTranslateAnimation = Tween<double>(
        begin: 0.0,
        end: sign * 15.0,
      ).animate(
        CurvedAnimation(
          parent: inertiaController,
          curve: const Interval(0, .5, curve: Curves.easeOut),
          reverseCurve: Curves.easeIn,
        ),
      );
      iconRotationAnimation =
          Tween<double>(begin: 0.0, end: sign * pi / 12 /* ~15deg */).animate(
        CurvedAnimation(
          parent: inertiaController,
          curve: const Interval(.5, 1.0, curve: Curves.easeOut),
          reverseCurve: Curves.easeIn,
        ),
      );
      iconTranslateAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
        CurvedAnimation(
          parent: inertiaController,
          curve: const Interval(.5, 1.0, curve: Curves.easeOut),
          reverseCurve: Curves.easeIn,
        ),
      );
    }

    if (widget.userType == LoginUserType.intlPhone) {
      _phoneNumberInitialValue = PhoneNumber(isoCode: 'US', dialCode: '+1');
      if (widget.controller?.value.text != null) {
        try {
          final parsed = pnp.PhoneNumber.parse(widget.controller!.value.text);
          if (parsed.isValid()) {
            _phoneNumberInitialValue = PhoneNumber(
              phoneNumber: parsed.nsn,
              isoCode: parsed.isoCode.name,
              dialCode: parsed.countryCode,
            );
          }
        } on pnp.PhoneNumberException {
          // ignore
        } finally {
          widget.controller!.text = '';
        }
      }
    }
  }

  void _updateSizeAnimation() {
    final interval = widget.interval!;
    final loadingController = widget.loadingController!;

    sizeAnimation = Tween<double>(
      begin: 48.0,
      end: widget.width,
    ).animate(
      CurvedAnimation(
        parent: loadingController,
        curve: _getInternalInterval(
          .2,
          1.0,
          interval.begin,
          interval.end,
          Curves.linearToEaseOut,
        ),
        reverseCurve: Curves.easeInExpo,
      ),
    );
  }

  @override
  void didUpdateWidget(AnimatedTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.width != widget.width) {
      _updateSizeAnimation();
    }
  }

  @override
  void dispose() {
    widget.inertiaController?.removeStatusListener(handleAnimationStatus);
    super.dispose();
  }

  void handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.inertiaController?.reverse();
    }
  }

  Widget? _buildInertiaAnimation(Widget? child) {
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
      suffixIcon: _buildInertiaAnimation(
        widget.loadingController != null
            ? FadeTransition(
                opacity: suffixIconOpacityAnimation,
                child: widget.suffixIcon,
              )
            : widget.suffixIcon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget textField;
    if (widget.userType == LoginUserType.intlPhone) {
      textField = Padding(
        padding: const EdgeInsets.only(left: 8),
        child: InternationalPhoneNumberInput(
          cursorColor: theme.primaryColor,
          focusNode: widget.focusNode,
          inputDecoration: _getInputDecoration(theme),
          searchBoxDecoration: const InputDecoration(
            contentPadding: EdgeInsets.only(left: 20),
            labelText: 'Search by country name or dial code',
          ),
          keyboardType: widget.keyboardType ?? TextInputType.phone,
          onFieldSubmitted: widget.onFieldSubmitted,
          onSaved: (phoneNumber) {
            if (phoneNumber.phoneNumber == phoneNumber.dialCode) {
              widget.controller?.text = '';
            } else {
              widget.controller?.text = phoneNumber.phoneNumber ?? '';
            }
            _phoneNumberController.selection = TextSelection.collapsed(
              offset: _phoneNumberController.text.length,
            );
            widget.onSaved?.call(phoneNumber.phoneNumber);
          },
          validator: widget.validator,
          autofillHints: widget.autofillHints,
          onInputChanged: (phoneNumber) {
            if (phoneNumber.phoneNumber != null &&
                phoneNumber.dialCode != null &&
                phoneNumber.phoneNumber!.startsWith('+')) {
              _phoneNumberController.text =
                  _phoneNumberController.text.replaceAll(
                RegExp(
                  '^([\\+]${phoneNumber.dialCode!.replaceAll('+', '')}[\\s]?)',
                ),
                '',
              );
            }
            _phoneNumberController.selection = TextSelection.collapsed(
              offset: _phoneNumberController.text.length,
            );
          },
          textFieldController: _phoneNumberController,
          isEnabled: widget.enabled,
          selectorConfig: SelectorConfig(
            selectorType: PhoneInputSelectorType.DIALOG,
            trailingSpace: false,
            countryComparator: (c1, c2) =>
                int.parse(c1.dialCode!.substring(1)).compareTo(
              int.parse(c2.dialCode!.substring(1)),
            ),
          ),
          spaceBetweenSelectorAndTextField: 0,
          initialValue: _phoneNumberInitialValue,
        ),
      );
    } else {
      textField = TextFormField(
        cursorColor: theme.primaryColor,
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
        autocorrect: widget.autocorrect,
        autofillHints: widget.autofillHints,
      );
    }

    if (widget.tooltip != null) {
      final tooltipKey = GlobalKey<TooltipState>();
      final tooltip = Tooltip(
        key: tooltipKey,
        richMessage: widget.tooltip,
        showDuration: const Duration(seconds: 30),
        triggerMode: TooltipTriggerMode.manual,
        margin: const EdgeInsets.all(4),
        child: textField,
      );
      textField = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: tooltip,
          ),
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: () => tooltipKey.currentState?.ensureTooltipVisible(),
            color: theme.primaryColor,
            iconSize: 28,
            icon: const Icon(Icons.info),
          )
        ],
      );
    }

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
  const AnimatedPasswordTextFormField({
    super.key,
    this.interval = const Interval(0.0, 1.0),
    required this.animatedWidth,
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
    this.autofillHints,
  }) : assert(
          (inertiaController == null && inertiaDirection == null) ||
              (inertiaController != null && inertiaDirection != null),
        );

  final Interval? interval;
  final AnimationController? loadingController;
  final AnimationController? inertiaController;
  final double animatedWidth;
  final bool enabled;
  final String? labelText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldSetter<String>? onSaved;
  final TextFieldInertiaDirection? inertiaDirection;
  final Iterable<String>? autofillHints;

  @override
  State<AnimatedPasswordTextFormField> createState() =>
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
      autofillHints: widget.autofillHints,
      labelText: widget.labelText,
      prefixIcon: const Icon(FontAwesomeIcons.lock, size: 20),
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
          firstChild: const Icon(
            Icons.visibility,
            size: 25.0,
            semanticLabel: 'show password',
          ),
          secondChild: const Icon(
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
