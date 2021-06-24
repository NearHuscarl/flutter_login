import 'package:flutter/material.dart';

import '../../flutter_login.dart';
import '../models/login_data.dart';

enum AuthMode { Signup, Login }

/// The result is an error message, callback successes if message is null
typedef AuthCallback = Future<String?>? Function(LoginData);

/// The additional fields are provided as an `HashMap<String, String>`
/// The result is an error message, callback successes if message is null
typedef AdditionalFieldsCallback = Future<String?>? Function(
    Map<String, String>);

/// If the callback returns true, the additional data card is shown
typedef ProviderNeedsSignUpCallback = Future<bool> Function();

/// The result is an error message, callback successes if message is null
typedef ProviderAuthCallback = Future<String?>? Function();

/// The result is an error message, callback successes if message is null
typedef RecoverCallback = Future<String?>? Function(String);

class Auth with ChangeNotifier {
  Auth({
    this.loginProviders = const [],
    this.onLogin,
    this.onSignup,
    this.onRecoverPassword,
    this.onAdditionalFieldsSubmit,
    String email = '',
    String password = '',
    String confirmPassword = '',
  })  : _email = email,
        _password = password,
        _confirmPassword = confirmPassword;

  final AuthCallback? onLogin;
  final AuthCallback? onSignup;
  final AdditionalFieldsCallback? onAdditionalFieldsSubmit;
  final RecoverCallback? onRecoverPassword;
  final List<LoginProvider> loginProviders;

  AuthMode _mode = AuthMode.Login;

  AuthMode get mode => _mode;
  set mode(AuthMode value) {
    _mode = value;
    notifyListeners();
  }

  bool get isLogin => _mode == AuthMode.Login;
  bool get isSignup => _mode == AuthMode.Signup;
  int currentCardIndex = 0;

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

  String _email = '';
  String get email => _email;
  set email(String email) {
    _email = email;
    notifyListeners();
  }

  String _password = '';
  String get password => _password;
  set password(String password) {
    _password = password;
    notifyListeners();
  }

  String _confirmPassword = '';
  String get confirmPassword => _confirmPassword;
  set confirmPassword(String confirmPassword) {
    _confirmPassword = confirmPassword;
    notifyListeners();
  }
}
