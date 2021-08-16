import 'package:quiver/core.dart';

class SignupData {
  final String? name;
  final String? password;

  final Map<String, String>? additionalSignupData;

  SignupData.fromSignupForm({
    required this.name,
    required this.password,
    this.additionalSignupData,
  });

  SignupData.fromProvider({
    required this.additionalSignupData,
  })  : name = null,
        password = null;

  @override
  bool operator ==(Object other) {
    if (other is SignupData) {
      return name == other.name &&
          password == other.password &&
          additionalSignupData == other.additionalSignupData;
    }
    return false;
  }

  @override
  int get hashCode => hash3(name, password, additionalSignupData);
}
