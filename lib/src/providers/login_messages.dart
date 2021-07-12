import 'package:flutter/material.dart';

class LoginMessages with ChangeNotifier {
  LoginMessages(
      {this.userHint = defaultUserHint,
      this.passwordHint = defaultPasswordHint,
      this.confirmPasswordHint = defaultConfirmPasswordHint,
      this.forgotPasswordButton = defaultForgotPasswordButton,
      this.loginButton = defaultLoginButton,
      this.signupButton = defaultSignupButton,
      this.recoverPasswordButton = defaultRecoverPasswordButton,
      this.recoverPasswordIntro = defaultRecoverPasswordIntro,
      this.recoverPasswordDescription = defaultRecoverPasswordDescription,
      this.recoverCodePasswordDescription =
          defaultRecoverCodePasswordDescription,
      this.goBackButton = defaultGoBackButton,
      this.confirmPasswordError = defaultConfirmPasswordError,
      this.recoverPasswordSuccess = defaultRecoverPasswordSuccess,
      this.confirmRecoverIntro = defaultConfirmRecoverIntro,
      this.recoveryCodeHint = defaultRecoveryCodeHint,
      this.recoveryCodeValidationError = defaultRecoveryCodeValidationError,
      this.setPasswordButton = defaultSetPasswordButton,
      this.confirmRecoverSuccess = defaultConfirmRecoverSuccess,
      this.flushbarTitleError = defaultflushbarTitleError,
      this.flushbarTitleSuccess = defaultflushbarTitleSuccess,
      this.confirmSignupIntro = defaultConfirmSignupIntro,
      this.confirmationCodeHint = defaultConfirmationCodeHint,
      this.confirmationCodeValidationError =
          defaultConfirmationCodeValidationError,
      this.resendCodeButton = defaultResendCodeButton,
      this.resendCodeSuccess = defaultResendCodeSuccess,
      this.confirmSignupButton = defaultConfirmSignupButton,
      this.confirmSignupSuccess = defaultConfirmSignupSuccess,
      this.signUpSuccess = defaultSignUpSuccess,
      this.providersTitle = defaultProvidersTitle});

  static const defaultUserHint = 'Email';
  static const defaultPasswordHint = 'Password';
  static const defaultConfirmPasswordHint = 'Confirm Password';
  static const defaultForgotPasswordButton = 'Forgot Password?';
  static const defaultLoginButton = 'LOGIN';
  static const defaultSignupButton = 'SIGNUP';
  static const defaultRecoverPasswordButton = 'RECOVER';
  static const defaultRecoverPasswordIntro = 'Reset your password here';
  static const defaultRecoverPasswordDescription =
      'We will send your password to your email.';
  static const defaultRecoverCodePasswordDescription =
      'We will send a password recovery code to your email.';
  static const defaultGoBackButton = 'BACK';
  static const defaultConfirmPasswordError = 'Passwords do not match!';
  static const defaultRecoverPasswordSuccess = 'An email has been sent.';
  static const defaultConfirmRecoverIntro =
      'The recovery code to set a new password was sent to your email.';
  static const defaultRecoveryCodeHint = 'Recovery Code';
  static const defaultRecoveryCodeValidationError = 'Recovery code is empty';
  static const defaultSetPasswordButton = 'SET PASSWORD';
  static const defaultConfirmRecoverSuccess = 'Password recovered.';
  static const defaultflushbarTitleSuccess = 'Success';
  static const defaultflushbarTitleError = 'Error';
  static const defaultConfirmSignupIntro =
      'A confirmation code was sent to your email. '
      'Please enter the code to confirm your account.';
  static const defaultConfirmationCodeHint = 'Confirmation Code';
  static const defaultConfirmationCodeValidationError =
      'Confirmation code is empty';
  static const defaultResendCodeButton = 'Resend Code';
  static const defaultResendCodeSuccess = 'A new email has been sent.';
  static const defaultConfirmSignupButton = 'CONFIRM';
  static const defaultConfirmSignupSuccess = 'Account confirmed.';
  static const defaultSignUpSuccess = 'An activation link has been sent';
  static const defaultProvidersTitle = 'or login with';

  /// Hint text of the userHint [TextField]
  /// By default is Email
  final String userHint;

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

  /// Description in password recovery form, shown when the onConfirmRecover
  /// callback is provided
  final String recoverCodePasswordDescription;

  /// Go back button's label. Go back button is used to go back to to
  /// login/signup form from the recover password form
  final String goBackButton;

  /// The error message to show when the confirm password not match with the
  /// original password
  final String confirmPasswordError;

  /// The success message to show after submitting recover password
  final String recoverPasswordSuccess;

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

  /// Title on top of Flushbar on errors
  final String flushbarTitleError;

  /// Title on top of Flushbar on successes
  final String flushbarTitleSuccess;

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

  /// The success message to show after signing up
  final String signUpSuccess;

  /// The string shown above the Providers buttons
  final String providersTitle;
}
