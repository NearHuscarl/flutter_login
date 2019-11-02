import 'package:flutter/material.dart';

class LoginButtonTheme {
  const LoginButtonTheme({
    this.backgroundColor,
    this.highlightColor,
    this.splashColor,
    this.elevation,
    this.highlightElevation,
    this.shape,
  });

  /// Color to be used for the unselected, enabled button's
  /// background.
  final Color backgroundColor;

  /// The highlight color of the ink response when pressed. If this property is
  /// null then the highlight color of the theme, [ThemeData.highlightColor],
  /// will be used.
  final Color highlightColor;

  /// The splash color for this button's [InkWell].
  final Color splashColor;

  /// The z-coordinate to be used for the unselected, enabled
  /// button's elevation foreground.
  final double elevation;

  /// The z-coordinate to be used for the selected, enabled
  /// button's elevation foreground.
  final double highlightElevation;

  /// The shape to be used for the floating action button's [Material].
  final ShapeBorder shape;
}

class LoginTheme with ChangeNotifier {
  LoginTheme({
    this.primaryColor,
    this.accentColor,
    this.errorColor,
    this.cardTheme = const CardTheme(),
    this.inputTheme = const InputDecorationTheme(
      filled: true,
    ),
    this.buttonTheme = const LoginButtonTheme(),
    this.titleStyle,
    this.bodyStyle,
    this.textFieldStyle,
    this.buttonStyle,
    this.beforeHeroFontSize = 48.0,
    this.afterHeroFontSize = 15.0,
  });

  final Color primaryColor;
  final Color accentColor;
  final Color errorColor;
  final CardTheme cardTheme;
  final InputDecorationTheme inputTheme;
  final LoginButtonTheme buttonTheme;
  final TextStyle titleStyle;
  final TextStyle bodyStyle;
  final TextStyle textFieldStyle;
  final TextStyle buttonStyle;
  final double beforeHeroFontSize;
  final double afterHeroFontSize;
}
