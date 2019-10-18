import 'package:flutter/foundation.dart';

class LoginData {
  final String name;
  final String password;

  LoginData({
    @required this.name,
    @required this.password,
  });

  @override
  String toString() {
    return '$runtimeType($name, $password)';
  }
}
