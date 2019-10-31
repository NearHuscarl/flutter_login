import 'package:flutter/material.dart';

class LoginTheme {
  static Color accentColor;
  static const double beforeHeroFontSize = 48.0;
  static const double afterHeroFontSize = 15.0;

  static TextStyle defaultLoginTitleStyle(ThemeData theme) =>
      theme.textTheme.display2.copyWith(
        color: accentColor ?? theme.accentColor,
        fontSize: beforeHeroFontSize,
        fontWeight: FontWeight.w300,
      );

  static TextStyle paragraphStyle(ThemeData theme) =>
      theme.textTheme.body1.copyWith(color: Colors.black54);
}
