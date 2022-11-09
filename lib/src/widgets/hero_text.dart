import 'package:flutter/material.dart';

/// https://uxdesign.cc/level-up-flutter-page-transition-choreographing-animations-across-screens-efb5ea105fca
enum ViewState {
  enlarge, // Hero to play enlarging animation
  enlarged, // Hero is static and enlarged
  shrink, // Hero to play shrinking animation
  shrunk, // Hero is static and shrunk
}

class _HeroTextContent extends StatefulWidget {
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

  final String? text;
  final ViewState viewState;
  final double smallFontSize;
  final double largeFontSize;

  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final double? textScaleFactor;
  final int maxLines;
  final Locale? locale;
  final StrutStyle? strutStyle;
  final TextStyle? style;

  @override
  __HeroTextContentState createState() => __HeroTextContentState();
}

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
      _controller.forward(from: 0.0);
    }
  }

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
        break;

      case ViewState.enlarged:
        fontSize = widget.largeFontSize;
        break;

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
        break;

      case ViewState.shrunk:
        fontSize = widget.smallFontSize;
        break;
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
    /// https://github.com/flutter/flutter/issues/30647#issuecomment-509712719
    /// Fix text using default text style while the hero is 'in flight'
    return Material(
      type: MaterialType.transparency,
      child: Text(
        widget.text!,
        style: widget.style!.copyWith(fontSize: fontSize),
        textAlign: widget.textAlign,
        textDirection: widget.textDirection,
        textScaleFactor: widget.textScaleFactor,
        maxLines: widget.maxLines,
        locale: widget.locale,
        strutStyle: widget.strutStyle,
        // prevent text from flickering when flying in hero animation
        overflow: TextOverflow.visible,
        softWrap: false,
      ),
    );
  }
}

class HeroText extends StatelessWidget {
  const HeroText(
    this.text, {
    super.key,
    required this.tag,
    required this.viewState,
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
        );

  final String? text;
  final Object? tag;
  final ViewState viewState;
  final double smallFontSize;
  final double largeFontSize;

  final TextAlign textAlign;
  final TextDirection? textDirection;
  final double? textScaleFactor;
  final int maxLines;
  final Locale? locale;
  final StrutStyle? strutStyle;
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

class HeroTextWidget extends StatelessWidget {
  const HeroTextWidget({
    super.key,
    this.child,
    required this.tag,
  });

  final Widget? child;
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
