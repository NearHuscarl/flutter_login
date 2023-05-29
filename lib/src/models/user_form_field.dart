import 'package:flutter/material.dart';
import 'package:flutter_login/src/models/login_user_type.dart';

abstract class UserFormField {
  /// The name of the field retrieved as key.
  /// Please ensure this is unique, otherwise an Error will be thrown
  final String keyName;

  /// The name of the field displayed on the form. Defaults to `keyName` if not given
  final String displayName;

  const UserFormField({
    required this.keyName,
    String? displayName,
  }) : displayName = displayName ?? keyName;
}

class UserCheckboxFormField extends UserFormField {
  /// The initial value of the checkbox
  final bool initialValue;

  /// Url to open when the user taps on the title
  final String? linkUrl;

  /// The validator of the checkbox
  final FormFieldValidator<bool>? validator;

  final InlineSpan? tooltip;

  const UserCheckboxFormField({
    required super.keyName,
    this.validator,
    super.displayName,
    this.tooltip,
    this.linkUrl,
    this.initialValue = false,
  });
}

class UserTextFormField extends UserFormField {
  /// A function to validate the field.
  /// It should return null on success, or a string with the explanation of the error
  final FormFieldValidator<String>? fieldValidator;

  /// The icon shown on the left of the field. Defaults to the user icon
  final Icon? icon;

  /// The LoginUserType of the form. The right keyboard and suggestions will be shown accordingly
  /// Defaults to LoginUserType.user
  final LoginUserType userType;

  /// The default value of the field
  final String defaultValue;

  final InlineSpan? tooltip;

  const UserTextFormField({
    required super.keyName,
    super.displayName,
    this.defaultValue = '',
    this.icon,
    this.fieldValidator,
    this.userType = LoginUserType.name,
    this.tooltip,
  });
}
