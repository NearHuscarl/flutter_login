import 'package:flutter/material.dart';

import '../models/login_data.dart';

enum AuthMode { Signup, Login }

/// The result is an error message, callback successes if message is null
typedef AuthCallback = Future<String> Function(LoginData);

/// The result is an error message, callback successes if message is null
typedef RecoverCallback = Future<String> Function(String);

/// The result is an error message, callback successes if message is null
typedef ConfirmSignupCallback = Future<String> Function(String code, LoginData);

class Auth with ChangeNotifier {
  Auth({
    this.onLogin,
    this.onSignup,
    this.onRecoverPassword,
    this.onConfirmSignup,
    this.onResendCode,
    Auth previous,
  }) {
    if (previous != null) {
      _mode = previous.mode;
    }
  }

  Auth.empty()
      : this(
          onLogin: null,
          onSignup: null,
          onRecoverPassword: null,
          onConfirmSignup: null,
          onResendCode: null,
          previous: null,
        );

  final AuthCallback onLogin;
  final AuthCallback onSignup;
  final RecoverCallback onRecoverPassword;
  final ConfirmSignupCallback onConfirmSignup;
  final AuthCallback onResendCode;

  AuthMode _mode = AuthMode.Login;

  AuthMode get mode => _mode;
  set mode(AuthMode value) {
    _mode = value;
    notifyListeners();
  }

  bool get isLogin => _mode == AuthMode.Login;
  bool get isSignup => _mode == AuthMode.Signup;
  bool isRecover = false;

  AuthMode opposite() {
    return _mode == AuthMode.Login ? AuthMode.Signup : AuthMode.Login;
  }

  AuthMode switchAuth() {
    if (mode == AuthMode.Login) {
      mode = AuthMode.Signup;
    } else if (mode == AuthMode.Signup) {
      mode = AuthMode.Login;
    }
    return mode;
  }
}
