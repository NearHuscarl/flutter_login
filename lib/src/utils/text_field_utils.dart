import 'package:flutter/material.dart';
import 'package:flutter_login/src/models/login_user_type.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TextFieldUtils {
  static String getAutofillHints(LoginUserType userType) {
    switch (userType) {
      case LoginUserType.name:
        return AutofillHints.username;
      case LoginUserType.firstName:
        return AutofillHints.givenName;
      case LoginUserType.lastName:
        return AutofillHints.familyName;
      case LoginUserType.phone:
      case LoginUserType.intlPhone:
        return AutofillHints.telephoneNumber;
      case LoginUserType.email:
      default:
        return AutofillHints.email;
    }
  }

  static TextInputType getKeyboardType(LoginUserType userType) {
    switch (userType) {
      case LoginUserType.name:
        return TextInputType.name;
      case LoginUserType.firstName:
      case LoginUserType.lastName:
      case LoginUserType.text:
        return TextInputType.text;
      case LoginUserType.phone:
      case LoginUserType.intlPhone:
        return TextInputType.phone;
      case LoginUserType.email:
      default:
        return TextInputType.emailAddress;
    }
  }

  static Icon getPrefixIcon(LoginUserType userType) {
    switch (userType) {
      case LoginUserType.name:
      case LoginUserType.firstName:
      case LoginUserType.lastName:
        return const Icon(FontAwesomeIcons.circleUser);
      case LoginUserType.phone:
      case LoginUserType.intlPhone:
        return const Icon(FontAwesomeIcons.squarePhoneFlip);
      case LoginUserType.email:
      default:
        return const Icon(FontAwesomeIcons.squareEnvelope);
    }
  }

  static String getLabelText(LoginUserType userType) {
    switch (userType) {
      case LoginUserType.name:
        return "Name";
      case LoginUserType.firstName:
        return "First Name";
      case LoginUserType.lastName:
        return "Last Name";
      case LoginUserType.phone:
      case LoginUserType.intlPhone:
        return "Phone";
      case LoginUserType.email:
      default:
        return "Email";
    }
  }
}
