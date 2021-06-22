import 'package:flutter/material.dart';
import 'package:flutter_login/src/models/login_user_type.dart';

class UserFormField {
  final String name;
  final FormFieldValidator<String>? fieldValidator;
  final Icon? icon;
  final LoginUserType userType;
  String value;

  UserFormField({
    required this.name,
    this.value = '',
    this.icon,
    this.fieldValidator,
    this.userType = LoginUserType.name,
  });
}
