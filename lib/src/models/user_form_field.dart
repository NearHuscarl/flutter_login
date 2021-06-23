import 'package:flutter/material.dart';
import 'package:flutter_login/src/models/login_user_type.dart';

class UserFormField {
  /// The name of the field retrieved as key.
  /// Please ensure this is unique, otherwise an Error will be thrown
  final String keyName;

  /// The name of the field displayed on the form. Defaults to `keyName` if not given
  final String displayName;

  /// The default value of the field
  final String defaultValue;

  /// A function to validate the field.
  /// It should return null on success, or a string with the explanation of the error
  final FormFieldValidator<String>? fieldValidator;

  /// The icon shown on the left of the field. Defaults to the user icon
  final Icon? icon;

  /// The LoginUserType of the form. The right keyboard and suggestions will be shown accordingly
  /// Defaults to LoginUserType.user
  final LoginUserType userType;

  const UserFormField({
    required this.keyName,
    displayName,
    this.defaultValue = '',
    this.icon,
    this.fieldValidator,
    this.userType = LoginUserType.name,
  }) : displayName = displayName ?? keyName;
}
