import 'package:quiver/core.dart';

class LoginData {
  final String name;
  final String password;

  LoginData({required this.name, required this.password});

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
