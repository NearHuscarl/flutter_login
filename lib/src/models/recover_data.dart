import 'package:quiver/core.dart';

class RecoverData {
  final String phone;
  final String email;
  final String newPassword;

  RecoverData({required this.phone, required this.email, required this.newPassword});

  @override
  String toString() {
    return '$runtimeType($phone, $email, $newPassword)';
  }

  @override
  bool operator ==(Object other) {
    if (other is RecoverData) {
      return phone == other.phone && email == other.email && newPassword == other.newPassword;
    }
    return false;
  }

  @override
  int get hashCode => hash3(phone, email, newPassword);
}
