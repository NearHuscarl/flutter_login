import 'package:flutter/material.dart';
import 'package:flutter_login/src/widgets/term_of_service_checkbox.dart';
import 'package:url_launcher/url_launcher.dart';

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

class AnimatedCheckboxFormField extends StatefulWidget {
  const AnimatedCheckboxFormField({
    required this.width,
    required this.validator,
    required this.onChanged,
    super.key,
    this.textFormFieldKey,
    this.linkUrl,
    this.interval = const Interval(0.0, 1.0),
    this.loadingController,
    this.inertiaController,
    this.enabled = true,
    this.initialValue = false,
    this.labelText,
    this.tooltip,
  });

  final Key? textFormFieldKey;
  final Interval? interval;
  final AnimationController? loadingController;
  final AnimationController? inertiaController;
  final double width;
  final bool enabled;
  final String? labelText;
  final FormFieldValidator<bool>? validator;
  final bool initialValue;
  final ValueChanged<bool?> onChanged;
  final String? linkUrl;
  final InlineSpan? tooltip;

  @override
  State<AnimatedCheckboxFormField> createState() => _AnimatedCheckboxFormFieldState();
}

class _AnimatedCheckboxFormFieldState extends State<AnimatedCheckboxFormField> {
  late Animation<double> scaleAnimation;
  late Animation<double> sizeAnimation;
  late Animation<double> suffixIconOpacityAnimation;

  late Animation<double> fieldTranslateAnimation;
  late Animation<double> iconRotationAnimation;
  late Animation<double> iconTranslateAnimation;

  @override
  void initState() {
    super.initState();

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
  void didUpdateWidget(AnimatedCheckboxFormField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.width != widget.width) {
      _updateSizeAnimation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget textField = CheckboxFormField(
      initialValue: widget.initialValue,
      validator: widget.validator ?? (_) => null,
      onChanged: widget.onChanged,
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
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.open_in_new,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                      size: Theme.of(context).textTheme.bodyMedium!.fontSize,
                    ),
                  )
                ],
              ),
            )
          : Text(
              widget.labelText ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.left,
            ),
    );

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
