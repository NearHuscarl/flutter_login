import 'package:flutter/material.dart';
import 'package:flutter_login/src/models/login_user_type.dart';

class TextFieldUtils {
  static String getAutofillHints(LoginUserType userType) {
    switch (userType) {
      case LoginUserType.name:
        return AutofillHints.username;
      case LoginUserType.phone:
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
      case LoginUserType.phone:
        return TextInputType.number;
      case LoginUserType.email:
      default:
        return TextInputType.emailAddress;
    }
  }
}
