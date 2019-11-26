import 'package:flutter/material.dart';

class LoginMessages with ChangeNotifier {
  LoginMessages({
    this.usernameHint: defaultUsernameHint,
    this.passwordHint: defaultPasswordHint,
    this.confirmPasswordHint: defaultConfirmPasswordHint,
    this.forgotPasswordButton: defaultForgotPasswordButton,
    this.loginButton: defaultLoginButton,
    this.signupButton: defaultSignupButton,
    this.recoverPasswordButton: defaultRecoverPasswordButton,
    this.recoverPasswordDescription: defaultRecoverPasswordDescription,
    this.goBackButton: defaultGoBackButton,
    this.confirmPasswordError: defaultConfirmPasswordError,
    this.recoverPasswordSuccess: defaultRecoverPasswordSuccess,
    this.confirmSignupIntro: defaultConfirmSignupIntro,
    this.confirmationCodeHint: defaultConfirmationCodeHint,
    this.confirmationCodeValidationError:
    defaultConfirmationCodeValidationError,
    this.resendCodeButton: defaultResendCodeButton,
    this.resendCodeSuccess: defaultResendCodeSuccess,
    this.confirmSignupButton: defaultConfirmSignupButton,
    this.confirmSignupSuccess: defaultConfirmSignupSuccess,
  });

  static const defaultUsernameHint = 'Email';
  static const defaultPasswordHint = 'Password';
  static const defaultConfirmPasswordHint = 'Confirm Password';
  static const defaultForgotPasswordButton = 'Forgot Password?';
  static const defaultLoginButton = 'LOGIN';
  static const defaultSignupButton = 'SIGNUP';
  static const defaultRecoverPasswordButton = 'RECOVER';
  static const defaultRecoverPasswordDescription =
      'We will send your plain-text password to this email account';
  static const defaultGoBackButton = 'BACK';
  static const defaultConfirmPasswordError = 'Password do not match!';
  static const defaultRecoverPasswordSuccess = 'An email has been sent';
  static const defaultConfirmSignupIntro =
      'A confirmation code was sent to your email. ' +
          'Please enter the code to confirm your account.';
  static const defaultConfirmationCodeHint = 'Confirmation Code';
  static const defaultConfirmationCodeValidationError =
      'Confirmation code is empty';
  static const defaultResendCodeButton = 'Resend Code';
  static const defaultResendCodeSuccess = 'A new email has been sent.';
  static const defaultConfirmSignupButton = 'CONFIRM';
  static const defaultConfirmSignupSuccess = 'Account confirmed.';

  /// Hint text of the user name [TextField]
  final String usernameHint;

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

  /// Description in password recovery form
  final String recoverPasswordDescription;

  /// Go back button's label. Go back button is used to go back to to
  /// login/signup form from the recover password form
  final String goBackButton;

  /// The error message to show when the confirm password not match with the
  /// original password
  final String confirmPasswordError;

  /// The success message to show after submitting recover password
  final String recoverPasswordSuccess;

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
}
