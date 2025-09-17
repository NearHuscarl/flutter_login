import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_login/src/widgets/term_of_service_checkbox.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_builder_phone_field/form_builder_phone_field.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart' as pnp;
import 'package:url_launcher/url_launcher.dart';

/// Represents the direction of inertial animation applied to a text field.
enum TextFieldInertiaDirection {
  /// Slide-in animation from the left.
  left,

  /// Slide-in animation from the right.
  right,
}

/// Returns an [Interval] for animating a subrange within another interval,
/// useful for nested animation sequencing.
///
/// [start] and [end] define the full range of the parent animation.
/// [externalStart] and [externalEnd] define the subrange relative to the full range.
/// [curve] is optional and defines the easing for the interval.
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

/// A custom text field widget with animation and support for
/// advanced login field types like international phone input, email, etc.
///
/// It supports loading animations, inertia-driven entry animations,
/// form validation, and autofill hints.
class AnimatedTextFormField extends StatefulWidget {
  /// Creates an [AnimatedTextFormField].
  ///
  /// The [width] and [initialIsoCode] are required.
  ///
  /// If [inertiaController] is provided, [inertiaDirection] must also be set,
  /// and vice versa.
  const AnimatedTextFormField({
    required this.width,
    required this.initialIsoCode,
    super.key,
    this.textFormFieldKey,
    this.interval = const Interval(0, 1),
    this.userType,
    this.loadingController,
    this.inertiaController,
    this.inertiaDirection,
    this.enabled = true,
    this.labelText,
    this.linkUrl,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.controller,
    this.autofocus = false,
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
          'inertiaController and inertiaDirection must either both be null or both be non-null',
        );

  /// A unique key for the internal [TextFormField].
  final Key? textFormFieldKey;

  /// Controls the animation timing of this widget relative to a larger sequence.
  final Interval? interval;

  /// Animation controller for loading transitions (e.g., during form submission).
  final AnimationController? loadingController;

  /// Controller used to animate the text field with inertial entry effects.
  final AnimationController? inertiaController;

  /// Direction in which the inertial animation should slide in.
  final TextFieldInertiaDirection? inertiaDirection;

  /// Width of the input field (usually based on screen size).
  final double width;

  /// Type of user input expected (e.g., email, phone, name).
  final LoginUserType? userType;

  /// Whether the field is enabled for user input.
  final bool enabled;

  /// Whether to enable auto-correction.
  final bool autocorrect;

  /// Autofill hints for system autofill functionality.
  final Iterable<String>? autofillHints;

  /// Label text displayed above the input field.
  final String? labelText;

  /// Optional URL to link the label text to (e.g., terms and conditions).
  final String? linkUrl;

  /// An optional icon displayed before the input field.
  final Widget? prefixIcon;

  /// An optional icon displayed after the input field.
  final Widget? suffixIcon;

  /// The type of keyboard to display.
  final TextInputType? keyboardType;

  /// The action button shown on the keyboard (e.g., next, done).
  final TextInputAction? textInputAction;

  /// Whether to obscure the text (e.g., for password fields).
  final bool obscureText;

  /// The controller for the input field's value.
  final TextEditingController? controller;

  /// Whether the field should receive focus when the screen loads.
  final bool autofocus;

  /// An optional [FocusNode] to manage focus manually.
  final FocusNode? focusNode;

  /// Form field validator, returns a string error or null.
  final FormFieldValidator<String>? validator;

  /// Called when the field is submitted (e.g., on keyboard submit).
  final ValueChanged<String>? onFieldSubmitted;

  /// Called when the field value is saved (on form submit).
  final FormFieldSetter<String>? onSaved;

  /// Tooltip or helper content displayed inline with the field.
  final InlineSpan? tooltip;

  /// ISO country code used as default for phone number input (e.g., "US", "IN").
  final String? initialIsoCode;

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

  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();

    widget.inertiaController?.addStatusListener(handleAnimationStatus);

    final interval = widget.interval;
    final loadingController = widget.loadingController;

    if (loadingController != null) {
      scaleAnimation = Tween<double>(
        begin: 0,
        end: 1,
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
      suffixIconOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: loadingController,
          curve: _getInternalInterval(.65, 1, interval.begin, interval.end),
        ),
      );
      _updateSizeAnimation();
    }

    final inertiaController = widget.inertiaController;
    final inertiaDirection = widget.inertiaDirection;
    final sign = inertiaDirection == TextFieldInertiaDirection.right ? 1 : -1;

    if (inertiaController != null) {
      fieldTranslateAnimation = Tween<double>(
        begin: 0,
        end: sign * 15.0,
      ).animate(
        CurvedAnimation(
          parent: inertiaController,
          curve: const Interval(0, .5, curve: Curves.easeOut),
          reverseCurve: Curves.easeIn,
        ),
      );
      iconRotationAnimation =
          Tween<double>(begin: 0, end: sign * pi / 12 /* ~15deg */).animate(
        CurvedAnimation(
          parent: inertiaController,
          curve: const Interval(.5, 1, curve: Curves.easeOut),
          reverseCurve: Curves.easeIn,
        ),
      );
      iconTranslateAnimation = Tween<double>(begin: 0, end: 8).animate(
        CurvedAnimation(
          parent: inertiaController,
          curve: const Interval(.5, 1, curve: Curves.easeOut),
          reverseCurve: Curves.easeIn,
        ),
      );
    }

    if (widget.userType == LoginUserType.intlPhone) {
      _phoneNumberController.text = pnp.PhoneNumber(
        isoCode: pnp.IsoCode.fromJson(widget.initialIsoCode ?? 'US'),
        nsn: '',
      ).nsn;
      if (widget.controller?.value.text != null) {
        try {
          final parsed = pnp.PhoneNumber.parse(widget.controller!.value.text);
          if (parsed.isValid()) {
            _phoneNumberController.text = pnp.PhoneNumber(
              nsn: parsed.nsn,
              isoCode: pnp.IsoCode.fromJson(parsed.isoCode.name),
            ).nsn;
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
      begin: 48,
      end: widget.width,
    ).animate(
      CurvedAnimation(
        parent: loadingController,
        curve: _getInternalInterval(
          .2,
          1,
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
          ..translateByDouble(iconTranslateAnimation.value, 0, 0, 1)
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
      suffixIcon: widget.userType == LoginUserType.intlPhone
          ? null
          : _buildInertiaAnimation(
              widget.loadingController != null
                  ? FadeTransition(
                      opacity: suffixIconOpacityAnimation,
                      child: widget.suffixIcon,
                    )
                  : widget.suffixIcon,
            ),
    );
  }

  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget inputField;
    if (widget.userType == LoginUserType.intlPhone) {
      _phoneNumberController.addListener(() {
        final phoneNumber = (_formKey.currentState?.fields['phone_number_intl']
                as FormBuilderPhoneFieldState?)
            ?.fullNumber;
        if (phoneNumber == null) return;
        widget.controller?.text = phoneNumber;
      });

      inputField = FormBuilder(
        key: _formKey,
        child: FormBuilderPhoneField(
          name: 'phone_number_intl',
          iconSelector: const SizedBox.shrink(),
          cursorColor: theme.primaryColor,
          focusNode: widget.focusNode,
          decoration: _getInputDecoration(theme),
          keyboardType: widget.keyboardType ?? TextInputType.phone,
          onFieldSubmitted: widget.onFieldSubmitted,
          validator: widget.validator,
          controller: _phoneNumberController,
          enabled: widget.enabled,
        ),
      );
    } else if (widget.userType == LoginUserType.checkbox) {
      inputField = CheckboxFormField(
        initialValue: widget.controller?.text == 'true',
        validator: (value) =>
            widget.validator?.call((value ?? false).toString()),
        onChanged: (value) {
          widget.onSaved?.call((value ?? false).toString());
          widget.controller?.text = (value ?? false).toString();
        },
        title: widget.linkUrl != null
            ? InkWell(
                onTap: () {
                  launchUrl(Uri.parse(widget.linkUrl!));
                },
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.labelText ?? '',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.open_in_new,
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                        size: Theme.of(context).textTheme.bodyMedium!.fontSize,
                      ),
                    ),
                  ],
                ),
              )
            : Text(
                widget.labelText ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.left,
              ),
      );
    } else {
      inputField = TextFormField(
        cursorColor: theme.primaryColor,
        controller: widget.controller,
        autofocus: widget.autofocus,
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
        child: inputField,
      );
      inputField = Row(
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
          ),
        ],
      );
    }

    if (widget.loadingController != null) {
      inputField = ScaleTransition(
        scale: scaleAnimation,
        child: AnimatedBuilder(
          animation: sizeAnimation,
          builder: (context, child) => ConstrainedBox(
            constraints: BoxConstraints.tightFor(width: sizeAnimation.value),
            child: child,
          ),
          child: inputField,
        ),
      );
    }

    if (widget.inertiaController != null) {
      inputField = AnimatedBuilder(
        animation: fieldTranslateAnimation,
        builder: (context, child) => Transform.translate(
          offset: Offset(fieldTranslateAnimation.value, 0),
          child: child,
        ),
        child: inputField,
      );
    }

    return inputField;
  }
}

/// A password input field with animation support, designed for login and signup forms.
///
/// This widget includes support for:
/// - Loading and entrance animations
/// - Autofill hints
/// - Inertial (slide-in) animation direction
/// - Validation and focus control
class AnimatedPasswordTextFormField extends StatefulWidget {
  /// Creates an [AnimatedPasswordTextFormField] for use in authentication UIs.
  ///
  /// [animatedWidth] and [initialIsoCode] are required.
  /// If [inertiaController] is provided, then [inertiaDirection] must also be set (and vice versa).
  const AnimatedPasswordTextFormField({
    required this.animatedWidth,
    required this.initialIsoCode,
    super.key,
    this.interval = const Interval(0, 1),
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
          'inertiaController and inertiaDirection must either both be null or both be non-null.',
        );

  /// Interval defining how this field participates in an animation sequence.
  final Interval? interval;

  /// Controller for triggering loading-related animations.
  final AnimationController? loadingController;

  /// Controller for entry animation from the left or right.
  final AnimationController? inertiaController;

  /// Width of the input field when animated.
  final double animatedWidth;

  /// Whether the field is interactive or disabled.
  final bool enabled;

  /// Optional label text shown above the input.
  final String? labelText;

  /// Defines the keyboard type (usually [TextInputType.visiblePassword]).
  final TextInputType? keyboardType;

  /// The action button to display on the soft keyboard (e.g., done, next).
  final TextInputAction? textInputAction;

  /// Controller for managing the text value of the field.
  final TextEditingController? controller;

  /// Optional focus node for managing field focus externally.
  final FocusNode? focusNode;

  /// A validator function returning an error string or null.
  final FormFieldValidator<String>? validator;

  /// Called when the field is submitted (e.g., keyboard "done").
  final ValueChanged<String>? onFieldSubmitted;

  /// Called when the field is saved in a form.
  final FormFieldSetter<String>? onSaved;

  /// The direction of the entry animation (left or right).
  final TextFieldInertiaDirection? inertiaDirection;

  /// Autofill hints to help the OS autofill the field.
  final Iterable<String>? autofillHints;

  /// ISO country code, passed for potential use in phone/password hybrid inputs.
  final String? initialIsoCode;

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
            size: 25,
            semanticLabel: 'show password',
          ),
          secondChild: const Icon(
            Icons.visibility_off,
            size: 25,
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
      initialIsoCode: widget.initialIsoCode,
    );
  }
}
