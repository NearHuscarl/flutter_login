import 'package:flutter/material.dart';

/// Represents the animation state of a [HeroText] widget.
///
/// Used to control the font size transition for hero animations.
enum ViewState {
  /// Hero is transitioning to a larger size.
  enlarge,

  /// Hero has finished enlarging and remains static at large size.
  enlarged,

  /// Hero is transitioning to a smaller size.
  shrink,

  /// Hero has finished shrinking and remains static at small size.
  shrunk,
}

/// A widget used internally by [HeroText] to animate font size
/// between [smallFontSize] and [largeFontSize] based on [viewState].
class _HeroTextContent extends StatefulWidget {
  /// Creates a [_HeroTextContent] widget that animates font size.
  ///
  /// [text] is the string to be displayed.
  /// [viewState] controls how the font size should behave.
  /// [smallFontSize] and [largeFontSize] determine font size bounds.
  const _HeroTextContent(
    this.text, {
    required this.viewState,
    required this.smallFontSize,
    required this.largeFontSize,
    this.style,
    this.textAlign,
    this.textDirection,
    this.textScaleFactor,
    this.maxLines = 1,
    this.locale,
    this.strutStyle,
  });

  /// The text to display.
  final String? text;

  /// The visual state of the widget controlling the font size animation.
  final ViewState viewState;

  /// Font size when the widget is shrunk.
  final double smallFontSize;

  /// Font size when the widget is enlarged.
  final double largeFontSize;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// The direction in which text flows (e.g., left-to-right).
  final TextDirection? textDirection;

  /// Used to scale all text uniformly.
  final double? textScaleFactor;

  /// Maximum number of lines for the text.
  final int maxLines;

  /// The locale used to select region-specific text formatting.
  final Locale? locale;

  /// Defines strut layout options (height, leading, etc.).
  final StrutStyle? strutStyle;

  /// The base style to apply to the text.
  final TextStyle? style;

  @override
  __HeroTextContentState createState() => __HeroTextContentState();
}

/// State class for [_HeroTextContent], handles font size animations.
class __HeroTextContentState extends State<_HeroTextContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fontSizeTween;
  double? fontSize;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..addListener(() {
        setState(() => fontSize = _fontSizeTween.value);
      });

    _updateFontSize();

    if (widget.viewState == ViewState.enlarge ||
        widget.viewState == ViewState.shrink) {
      _controller.forward(from: 0);
    }
  }

  /// Updates the [fontSize] or sets up a tween depending on the viewState.
  void _updateFontSize() {
    switch (widget.viewState) {
      case ViewState.enlarge:
        _fontSizeTween = Tween<double>(
          begin: widget.smallFontSize,
          end: widget.largeFontSize,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeInOut,
          ),
        );

      case ViewState.enlarged:
        fontSize = widget.largeFontSize;

      case ViewState.shrink:
        _fontSizeTween = Tween<double>(
          begin: widget.largeFontSize,
          end: widget.smallFontSize,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeInOut,
          ),
        );

      case ViewState.shrunk:
        fontSize = widget.smallFontSize;
    }
  }

  @override
  void didUpdateWidget(_HeroTextContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.largeFontSize != widget.largeFontSize ||
        oldWidget.smallFontSize != widget.smallFontSize) {
      _updateFontSize();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Prevents default text style override during Hero flight.
    return Material(
      type: MaterialType.transparency,
      child: Text(
        widget.text!,
        style: widget.style!.copyWith(fontSize: fontSize),
        textAlign: widget.textAlign,
        textDirection: widget.textDirection,
        textScaler: widget.textScaleFactor != null
            ? TextScaler.linear(widget.textScaleFactor!)
            : null,
        maxLines: widget.maxLines,
        locale: widget.locale,
        strutStyle: widget.strutStyle,
        overflow: TextOverflow.visible,
        softWrap: false,
      ),
    );
  }
}

/// A hero-animated text widget that transitions smoothly between font sizes.
///
/// Wraps a [Text] widget in a [Hero] to animate changes between routes.
/// Uses [ViewState] to determine how the text should animate.
class HeroText extends StatelessWidget {
  /// Creates a [HeroText] widget with hero animation.
  ///
  /// [tag] must be unique and consistent across transitions.
  /// [viewState] must be [ViewState.shrunk] or [ViewState.enlarged] in static state.
  const HeroText(
    this.text, {
    required this.tag,
    required this.viewState,
    super.key,
    this.smallFontSize = 15.0,
    this.largeFontSize = 48.0,
    this.style,
    this.textAlign = TextAlign.center,
    this.textDirection,
    this.textScaleFactor,
    this.maxLines = 1,
    this.locale,
    this.strutStyle,
  }) : assert(
          viewState == ViewState.shrunk || viewState == ViewState.enlarged,
          'viewState must be either ViewState.shrunk or ViewState.enlarged for static HeroText.',
        );

  /// The text to display and animate.
  final String? text;

  /// Unique tag used to identify hero widgets between routes.
  final Object? tag;

  /// The animation state that determines font size behavior.
  final ViewState viewState;

  /// The font size when shrunk.
  final double smallFontSize;

  /// The font size when enlarged.
  final double largeFontSize;

  /// Defines text alignment (left, right, center).
  final TextAlign textAlign;

  /// The direction in which text flows.
  final TextDirection? textDirection;

  /// A scale factor applied to the font size.
  final double? textScaleFactor;

  /// The maximum number of lines the text can span.
  final int maxLines;

  /// The locale used to resolve text and number formatting.
  final Locale? locale;

  /// Layout rules for line height and spacing.
  final StrutStyle? strutStyle;

  /// Base styling applied to the text.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag!,
      flightShuttleBuilder: (
        BuildContext flightContext,
        Animation<double> animation,
        HeroFlightDirection flightDirection,
        BuildContext fromHeroContext,
        BuildContext toHeroContext,
      ) {
        return _HeroTextContent(
          text,
          viewState: viewState == ViewState.shrunk
              ? (flightDirection == HeroFlightDirection.push
                  ? ViewState.shrink
                  : ViewState.enlarge)
              : (flightDirection == HeroFlightDirection.push
                  ? ViewState.enlarge
                  : ViewState.shrink),
          smallFontSize: smallFontSize,
          largeFontSize: largeFontSize,
          style: style,
          textAlign: textAlign,
          textDirection: textDirection,
          textScaleFactor: textScaleFactor,
          maxLines: maxLines,
          locale: locale,
          strutStyle: strutStyle,
        );
      },
      child: _HeroTextContent(
        text,
        viewState: viewState,
        smallFontSize: smallFontSize,
        largeFontSize: largeFontSize,
        style: style,
        textAlign: textAlign,
        textDirection: textDirection,
        textScaleFactor: textScaleFactor,
        maxLines: maxLines,
        locale: locale,
        strutStyle: strutStyle,
      ),
    );
  }
}

/// A wrapper for any widget that should participate in a Hero animation.
///
/// Unlike [HeroText], this class does not perform font size transitions.
class HeroTextWidget extends StatelessWidget {
  /// Creates a [HeroTextWidget] for arbitrary child widgets.
  ///
  /// [tag] is required to link this hero to another.
  const HeroTextWidget({
    required this.tag,
    super.key,
    this.child,
  });

  /// The widget to wrap inside the hero animation.
  final Widget? child;

  /// Unique tag for the hero animation.
  final Object tag;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    );
  }
}
