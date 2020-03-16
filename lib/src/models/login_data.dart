import 'package:flutter/foundation.dart';
import 'package:quiver/core.dart';

class LoginData {
  final String name;
  final String password;

  const LoginData({
    @required this.name,
    @required this.password,
  });

  @override
  String toString() => '$runtimeType($name, $password)';

  @override
  bool operator ==(Object otherObject) =>
      otherObject is LoginData &&
      (name == otherObject.name && password == otherObject.password);

  @override
  int get hashCode => hash2(name, password);
}
