import 'package:flutter_login/src/models/term_of_service.dart';
import 'package:quiver/core.dart';

class SignupData {
  final String? name;
  final String? password;
  final String? extraEmail;
  final List<TermOfServiceResult> termsOfService;
  final Map<String, String>? additionalSignupData;

  SignupData.fromSignupForm(
      {required this.name,
      required this.password,
      required this.extraEmail,
      this.additionalSignupData,
      this.termsOfService = const []});

  SignupData.fromProvider({
    required this.additionalSignupData,
    this.termsOfService = const [],
  })  : name = null,
        extraEmail = null,
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
