import 'package:quiver/core.dart';

class LoginData {
  final String phoneNumber;
  final String password;

  LoginData({
    required this.phoneNumber,
    required this.password,
  });

  @override
  String toString() {
    return '$runtimeType($phoneNumber, $password)';
  }

  @override
  bool operator ==(Object other) {
    if (other is LoginData) {
      return phoneNumber == other.phoneNumber && password == other.password;
    }
    return false;
  }

  @override
  int get hashCode => hash2(phoneNumber, password);
}
