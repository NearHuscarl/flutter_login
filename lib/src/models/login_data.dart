import 'package:quiver/core.dart';

class LoginData {
  final String name;
  final String password;
  final bool rememberMe;

  LoginData(
      {required this.name, required this.password, required this.rememberMe,});

  @override
  String toString() {
    return 'LoginData($name, $password)';
  }

  @override
  bool operator ==(Object other) {
    if (other is LoginData) {
      return name == other.name && password == other.password && rememberMe == other.rememberMe;
    }
    return false;
  }

  @override
  int get hashCode => hash3(name, password, rememberMe);
}
