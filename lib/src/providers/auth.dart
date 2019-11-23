import 'package:flutter/material.dart';

import '../models/login_data.dart';

enum AuthMode { Signup, Login }

/// The result is an error message, callback successes if message is null
typedef AuthCallback = Future<String> Function(LoginData);

/// The result is an error message, callback successes if message is null
typedef RecoverCallback = Future<String> Function(String);

class Auth with ChangeNotifier {
  Auth({
    this.onLogin,
    this.onSignup,
    this.onRecoverPassword,
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
          previous: null,
        );

  final AuthCallback onLogin;
  final AuthCallback onSignup;
  final RecoverCallback onRecoverPassword;

  var _authData = {'email': '', 'password': ''};

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

  get email => _authData['email'];
  set email(String email) {
    _authData['email'] = email;
    notifyListeners();
  }

  get password => _authData['password'];
  set password(String password) {
    _authData['password'] = password;
    notifyListeners();
  }
}
