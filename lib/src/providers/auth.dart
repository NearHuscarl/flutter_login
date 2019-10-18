import 'package:flutter/cupertino.dart';
import '../models/login_data.dart';

enum AuthMode { Signup, Login }

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

  final Future<void> Function(LoginData) onLogin;
  final Future<void> Function(LoginData) onSignup;
  final Future<void> Function(String) onRecoverPassword;

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
