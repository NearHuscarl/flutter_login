import 'package:flutter/foundation.dart';

/// Key used to identify the login screen title widget in tests.
const kTitleKey = Key('FLUTTER_LOGIN_TITLE');

/// Key used to identify the intro text widget on the password recovery screen.
const kRecoverPasswordIntroKey = Key('RECOVER_PASSWORD_INTRO');

/// Key used to identify the description widget on the password recovery screen.
const kRecoverPasswordDescriptionKey = Key('RECOVER_PASSWORD_DESCRIPTION');

/// Key used to identify the debug toolbar for test and development environments.
const kDebugToolbarKey = Key('DEBUG_TOOLBAR');

/// The minimum logo height at which the logo is still shown.
///
/// If the layout height available is less than this, the logo is hidden.
const kMinLogoHeight = 50.0;

/// The maximum height at which the logo will be displayed.
///
/// Used to limit scaling of the logo in larger layouts.
const kMaxLogoHeight = 125.0;
