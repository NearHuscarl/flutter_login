import 'package:quiver/core.dart';

class LoginData {
  final String name;
  final String password;
  final Map<String, String>? customLoginData;

  LoginData({required this.name, required this.password, this.customLoginData});

  @override
  String toString() {
    return '$runtimeType($name, $password)';
  }

  @override
  bool operator ==(Object other) {
    if (other is LoginData) {
      return name == other.name &&
          password == other.password &&
          customLoginData == other.customLoginData;
    }
    return false;
  }

  @override
  int get hashCode => hash3(name, password, customLoginData);
}
