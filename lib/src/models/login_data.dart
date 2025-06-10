import 'package:quiver/core.dart';

class LoginData {
  LoginData({required this.name, required this.password});
  final String name;
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
