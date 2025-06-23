// ignore_for_file: avoid_classes_with_only_static_members due to being migrated

import 'package:flutter/material.dart';

/// A helper class for managing login-related theming across screens.
///
/// This class is intended to provide shared styles, such as text styling,
/// that can be used consistently in login and post-login flows.
class LoginThemeHelper {
  /// Text style used by the screen shown after a successful login.
  ///
  /// Typically applied to the "hero" or welcome text to maintain
  /// a consistent visual theme.
  static TextStyle? loginTextStyle;
}
