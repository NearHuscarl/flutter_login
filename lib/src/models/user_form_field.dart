import 'package:flutter/material.dart';
import 'package:flutter_login/src/models/login_user_type.dart';

/// Represents a customizable field used in the signup or login form.
///
/// This class allows you to define additional user input fields beyond the
/// standard email/username and password. Each field is uniquely identified
/// by a [keyName] and can include custom validation, icon, tooltips, and more.
class UserFormField {
  /// Creates a [UserFormField].
  ///
  /// The [keyName] must be unique across all form fields. If [displayName] is
  /// not provided, it defaults to [keyName].
  ///
  /// Optional customization includes [defaultValue], [fieldValidator], [icon],
  /// [linkUrl], [userType], and [tooltip].
  const UserFormField({
    required this.keyName,
    String? displayName,
    this.defaultValue = '',
    this.linkUrl,
    this.icon,
    this.fieldValidator,
    this.userType = LoginUserType.name,
    this.tooltip,
  }) : displayName = displayName ?? keyName;

  /// A unique key used to identify this field's value in the form results.
  ///
  /// Must be unique across all form fields or an error will be thrown.
  final String keyName;

  /// The label text displayed to the user.
  ///
  /// If not provided, it defaults to [keyName].
  final String displayName;

  /// The initial value for this field.
  ///
  /// Defaults to an empty string.
  final String defaultValue;

  /// A validator function for the field input.
  ///
  /// Should return `null` if the input is valid,
  /// or a string with an error message otherwise.
  final FormFieldValidator<String>? fieldValidator;

  /// An optional icon shown at the start of the text input field.
  ///
  /// If not provided, a default user icon will be used based on [userType].
  final Icon? icon;

  /// An optional URL that may be associated with this field (e.g. terms links).
  final String? linkUrl;

  /// Defines the input type, keyboard layout, autofill hint, and more.
  ///
  /// This controls how the field behaves and appears. Defaults to [LoginUserType.name].
  final LoginUserType userType;

  /// An optional tooltip that may be shown alongside the field.
  ///
  /// Typically used to explain the purpose or constraints of the field.
  final InlineSpan? tooltip;
}
