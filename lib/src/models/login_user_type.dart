/// Represents the type of input field used for login or signup.
///
/// This enum is used to determine how each field should behave, including
/// keyboard type, autofill hint, label, and icon.
enum LoginUserType {
  /// Email address input field.
  ///
  /// Uses an email keyboard and validates email format.
  email,

  /// Full name input field.
  ///
  /// Treated as a free-form text field with name-specific autofill.
  name,

  /// Phone number input field (non-international).
  ///
  /// Uses the standard phone keyboard.
  phone,

  /// First name input field.
  ///
  /// Autofill and validation are tailored to first names.
  firstName,

  /// Last name input field.
  ///
  /// Autofill and validation are tailored to last names.
  lastName,

  /// Generic text input field.
  ///
  /// Can be used for arbitrary user-defined content.
  text,

  /// International phone number input field.
  ///
  /// May provide country code selection and international formatting.
  intlPhone,

  /// Checkbox field (e.g. terms and conditions).
  ///
  /// Used for non-text boolean agreement inputs.
  checkbox,
}
