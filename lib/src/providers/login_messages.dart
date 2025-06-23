import 'package:flutter/material.dart';

/// Provides all user-facing messages used in the login and signup flows.
///
/// This includes labels, hints, error messages, button text, and success messages
/// for login, signup, password recovery, and provider authentication.
///
/// You can customize this class to support localization or override specific strings.
class LoginMessages with ChangeNotifier {
  /// Creates a set of customizable login and signup messages.
  ///
  /// Most values have default fallbacks, but you may override any to support
  /// localization or specific UI requirements.
  LoginMessages({
    this.userHint,
    this.passwordHint = defaultPasswordHint,
    this.confirmPasswordHint = defaultConfirmPasswordHint,
    this.forgotPasswordButton = defaultForgotPasswordButton,
    this.loginButton = defaultLoginButton,
    this.signupButton = defaultSignupButton,
    this.recoverPasswordButton = defaultRecoverPasswordButton,
    this.recoverPasswordIntro = defaultRecoverPasswordIntro,
    this.recoverPasswordDescription = defaultRecoverPasswordDescription,
    this.goBackButton = defaultGoBackButton,
    this.confirmPasswordError = defaultConfirmPasswordError,
    this.recoverPasswordSuccess = defaultRecoverPasswordSuccess,
    this.flushbarTitleError = defaultflushbarTitleError,
    this.flushbarTitleSuccess = defaultflushbarTitleSuccess,
    this.signUpSuccess = defaultSignUpSuccess,
    this.providersTitleFirst = defaultProvidersTitleFirst,
    this.providersTitleSecond = defaultProvidersTitleSecond,
    this.additionalSignUpSubmitButton = defaultAdditionalSignUpSubmitButton,
    this.additionalSignUpFormDescription =
        defaultAdditionalSignUpFormDescription,
    this.confirmSignupIntro = defaultConfirmSignupIntro,
    this.confirmationCodeHint = defaultConfirmationCodeHint,
    this.confirmationCodeValidationError =
        defaultConfirmationCodeValidationError,
    this.resendCodeButton = defaultResendCodeButton,
    this.resendCodeSuccess = defaultResendCodeSuccess,
    this.confirmSignupButton = defaultConfirmSignupButton,
    this.confirmSignupSuccess = defaultConfirmSignupSuccess,
    this.confirmRecoverIntro = defaultConfirmRecoverIntro,
    this.recoveryCodeHint = defaultRecoveryCodeHint,
    this.recoveryCodeValidationError = defaultRecoveryCodeValidationError,
    this.setPasswordButton = defaultSetPasswordButton,
    this.confirmRecoverSuccess = defaultConfirmRecoverSuccess,
    this.recoverCodePasswordDescription = defaultRecoverCodePasswordDescription,
  });

  /// Default hint for password field.
  static const defaultPasswordHint = 'Password';

  /// Default hint for confirm password field.
  static const defaultConfirmPasswordHint = 'Confirm Password';

  /// Default label for "Forgot Password?" button.
  static const defaultForgotPasswordButton = 'Forgot Password?';

  /// Default label for login button.
  static const defaultLoginButton = 'LOGIN';

  /// Default label for signup button.
  static const defaultSignupButton = 'SIGNUP';

  /// Default label for password recovery button.
  static const defaultRecoverPasswordButton = 'RECOVER';

  /// Default intro text for password recovery form.
  static const defaultRecoverPasswordIntro = 'Reset your password here';

  /// Default description for password recovery (if no confirm recovery).
  static const defaultRecoverPasswordDescription =
      'We will send your plain-text password to this email account.';

  /// Default description when confirm recovery is used.
  static const defaultRecoverCodePasswordDescription =
      'We will send a password recovery code to your email.';

  /// Default label for back button.
  static const defaultGoBackButton = 'BACK';

  /// Default error message when passwords do not match.
  static const defaultConfirmPasswordError = 'Password do not match!';

  /// Default success message after requesting password recovery.
  static const defaultRecoverPasswordSuccess = 'An email has been sent';

  /// Default title for error toast/snackbar.
  static const defaultflushbarTitleError = 'Error';

  /// Default title for success toast/snackbar.
  static const defaultflushbarTitleSuccess = 'Success';

  /// Default success message after signup.
  static const defaultSignUpSuccess = 'An activation link has been sent';

  /// Default title for first line above login providers.
  static const defaultProvidersTitleFirst = 'or login with';

  /// Default title for second line above login providers.
  static const defaultProvidersTitleSecond = 'or';

  /// Default label for additional signup submit button.
  static const defaultAdditionalSignUpSubmitButton = 'SUBMIT';

  /// Default description text for additional signup form.
  static const defaultAdditionalSignUpFormDescription =
      'Please fill in this form to complete the signup';

  /// Default intro for confirm recover card.
  static const defaultConfirmRecoverIntro =
      'The recovery code to set a new password was sent to your email.';

  /// Default hint text for the recovery code input field.
  static const defaultRecoveryCodeHint = 'Recovery Code';

  /// Default validation message if recovery code is empty.
  static const defaultRecoveryCodeValidationError = 'Recovery code is empty';

  /// Default label for set password button (after code is entered).
  static const defaultSetPasswordButton = 'SET PASSWORD';

  /// Default success message after confirming password recovery.
  static const defaultConfirmRecoverSuccess = 'Password recovered.';

  /// Default intro for confirm signup card.
  static const defaultConfirmSignupIntro =
      'A confirmation code was sent to your email. '
      'Please enter the code to confirm your account.';

  /// Default hint for confirmation code input.
  static const defaultConfirmationCodeHint = 'Confirmation Code';

  /// Default validation error for empty confirmation code.
  static const defaultConfirmationCodeValidationError =
      'Confirmation code is empty';

  /// Default label for resend code button.
  static const defaultResendCodeButton = 'Resend Code';

  /// Default message after resending the confirmation code.
  static const defaultResendCodeSuccess = 'A new email has been sent.';

  /// Default label for confirm signup button.
  static const defaultConfirmSignupButton = 'CONFIRM';

  /// Default message after successful signup confirmation.
  static const defaultConfirmSignupSuccess = 'Account confirmed.';

  /// Hint text of the userHint [TextField]
  /// Default will be selected based on userType
  final String? userHint;

  /// Additional signup form button's label
  final String additionalSignUpSubmitButton;

  /// Description in the additional signup form
  final String additionalSignUpFormDescription;

  /// Hint text of the password [TextField]
  final String passwordHint;

  /// Hint text of the confirm password [TextField]
  final String confirmPasswordHint;

  /// Forgot password button's label
  final String forgotPasswordButton;

  /// Login button's label
  final String loginButton;

  /// Signup button's label
  final String signupButton;

  /// Recover password button's label
  final String recoverPasswordButton;

  /// Intro in password recovery form
  final String recoverPasswordIntro;

  /// Description in password recovery form, shown when the onConfirmRecover
  /// callback is not provided
  final String recoverPasswordDescription;

  /// Go back button's label. Go back button is used to go back to to
  /// login/signup form from the recover password form
  final String goBackButton;

  /// The error message to show when the confirm password not match with the
  /// original password
  final String confirmPasswordError;

  /// The success message to show after submitting recover password
  final String recoverPasswordSuccess;

  /// Title on top of Flushbar on errors
  final String flushbarTitleError;

  /// Title on top of Flushbar on successes
  final String flushbarTitleSuccess;

  /// The success message to show after signing up
  final String signUpSuccess;

  /// The string shown above the Providers buttons
  final String providersTitleFirst;

  /// The string shown above the Providers icons
  final String providersTitleSecond;

  /// The intro text for the confirm recover password card
  final String confirmRecoverIntro;

  /// Hint text of the password recovery code [TextField]
  final String recoveryCodeHint;

  /// The validation error message  to show for an empty recovery code
  final String recoveryCodeValidationError;

  /// Set password button's label for password recovery confirmation
  final String setPasswordButton;

  /// The success message to show after confirming recovered password
  final String confirmRecoverSuccess;

  /// The intro text for the confirm signup card
  final String confirmSignupIntro;

  /// Hint text of the confirmation code for confirming signup
  final String confirmationCodeHint;

  /// The validation error message to show for an empty confirmation code
  final String confirmationCodeValidationError;

  /// Resend code button's label
  final String resendCodeButton;

  /// The success message to show after resending confirmation code
  final String resendCodeSuccess;

  /// Confirm signup button's label
  final String confirmSignupButton;

  /// The success message to show after confirming signup
  final String confirmSignupSuccess;

  /// Description in password recovery form, shown when the onConfirmRecover
  /// callback is provided
  final String recoverCodePasswordDescription;
}
