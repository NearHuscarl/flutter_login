import 'package:flutter/material.dart';
import 'package:flutter_login/src/models/term_of_service.dart';
import 'package:quiver/core.dart';

/// A data model representing signup form input or provider-based registration.
///
/// This class is used to encapsulate all the data collected during the
/// signup process, including optional terms of service and custom fields.
@immutable
class SignupData {
  /// Creates a [SignupData] instance for traditional signup forms.
  ///
  /// Includes [name], [password], optional [additionalSignupData], and
  /// agreed-to [termsOfService].
  const SignupData.fromSignupForm({
    required this.name,
    required this.password,
    this.additionalSignupData,
    this.termsOfService = const [],
  });

  /// Creates a [SignupData] instance for third-party provider signups.
  ///
  /// Skips [name] and [password], which are expected to be handled by the provider.
  /// Includes [additionalSignupData] and [termsOfService].
  const SignupData.fromProvider({
    required this.additionalSignupData,
    this.termsOfService = const [],
  })  : name = null,
        password = null;

  /// The user's identifier (e.g. email, username).
  ///
  /// `null` when using a third-party provider.
  final String? name;

  /// The user's password.
  ///
  /// `null` when using a third-party provider.
  final String? password;

  /// List of terms of service and their acceptance status.
  final List<TermOfServiceResult> termsOfService;

  /// Additional fields collected during signup (e.g. first name, phone).
  final Map<String, String>? additionalSignupData;

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
