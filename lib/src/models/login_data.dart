import 'package:flutter/material.dart';
import 'package:quiver/core.dart';

/// A simple data model representing login credentials.
///
/// Used to pass the username (or email/identifier) and password
/// into login callback functions.
@immutable
class LoginData {
  /// Creates a [LoginData] instance with the given [name] and [password].
  ///
  /// Both parameters are required.
  const LoginData({
    required this.name,
    required this.password,
  });

  /// The username, email, or login identifier entered by the user.
  final String name;

  /// The password entered by the user.
  final String password;

  @override
  String toString() {
    return 'LoginData($name, $password)';
  }

  @override
  bool operator ==(Object other) {
    if (other is LoginData) {
      return name == other.name && password == other.password;
    }
    return false;
  }

  @override
  int get hashCode => hash2(name, password);
}
