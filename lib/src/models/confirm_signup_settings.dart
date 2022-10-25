import 'package:flutter/widgets.dart';
import 'package:flutter_login/flutter_login.dart';

/// Settings for tuning up confirm signup form.
///
/// If this is not set, it's considered that confirm signup form step is omitted.
class ConfirmSignupSettings {
  /// Called when the user hits the submit button when in confirm signup mode.
  final ConfirmSignupCallback? onConfirmSignup;

  /// Sets [TextInputType] of sign up confirmation form.
  ///
  /// Defaults to [TextInputType.text].
  final TextInputType keyboardType;

  const ConfirmSignupSettings({
    this.onConfirmSignup,
    this.keyboardType = TextInputType.text,
  });
}
