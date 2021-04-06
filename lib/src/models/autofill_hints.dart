import 'package:flutter_login/src/models/login_user_type.dart';
import 'package:flutter/material.dart';

class AutofillHintsHelper {
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
}
