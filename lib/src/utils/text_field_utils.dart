import 'package:flutter/material.dart';
import 'package:flutter_login/src/models/login_user_type.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Returns the appropriate autofill hint for a given [LoginUserType].
///
/// This is used to provide contextual autofill support for form fields.
String getAutofillHints(LoginUserType userType) {
  switch (userType) {
    case LoginUserType.name:
    case LoginUserType.text:
    case LoginUserType.checkbox:
      return AutofillHints.username;
    case LoginUserType.firstName:
      return AutofillHints.givenName;
    case LoginUserType.lastName:
      return AutofillHints.familyName;
    case LoginUserType.phone:
    case LoginUserType.intlPhone:
      return AutofillHints.telephoneNumber;
    case LoginUserType.email:
      return AutofillHints.email;
  }
}

/// Returns the appropriate [TextInputType] (keyboard type) for the given [LoginUserType].
///
/// This helps present the most relevant keyboard layout for each field type.
TextInputType getKeyboardType(LoginUserType userType) {
  switch (userType) {
    case LoginUserType.name:
      return TextInputType.name;
    case LoginUserType.firstName:
    case LoginUserType.lastName:
    case LoginUserType.text:
    case LoginUserType.checkbox:
      return TextInputType.text;
    case LoginUserType.phone:
    case LoginUserType.intlPhone:
      return TextInputType.phone;
    case LoginUserType.email:
      return TextInputType.emailAddress;
  }
}

/// Returns a contextual icon widget based on the [LoginUserType].
///
/// These icons are shown as prefix icons in text fields to visually indicate the field's purpose.
Icon getPrefixIcon(LoginUserType userType) {
  switch (userType) {
    case LoginUserType.name:
    case LoginUserType.firstName:
    case LoginUserType.lastName:
    case LoginUserType.text:
    case LoginUserType.checkbox:
      return const Icon(FontAwesomeIcons.circleUser);
    case LoginUserType.phone:
    case LoginUserType.intlPhone:
      return const Icon(FontAwesomeIcons.squarePhoneFlip);
    case LoginUserType.email:
      return const Icon(FontAwesomeIcons.squareEnvelope);
  }
}

/// Returns a human-readable label text for a form field based on [LoginUserType].
///
/// This is typically used as the `labelText` in a [TextField] or [TextFormField].
String getLabelText(LoginUserType userType) {
  switch (userType) {
    case LoginUserType.name:
      return 'Name';
    case LoginUserType.firstName:
      return 'First Name';
    case LoginUserType.lastName:
      return 'Last Name';
    case LoginUserType.phone:
    case LoginUserType.intlPhone:
      return 'Phone';
    case LoginUserType.email:
      return 'Email';
    case LoginUserType.text:
      return 'Text';
    case LoginUserType.checkbox:
      return 'Checkbox';
  }
}
