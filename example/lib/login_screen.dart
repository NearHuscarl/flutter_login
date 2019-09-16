import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart' as Login;
import 'dashboard_screen.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    return Login.LoginScreen(
      title: 'ECorp',
      logoAsset: 'assets/images/ecorp.png',
      titleTextStyle: (defaultTextStyle) =>
          defaultTextStyle.copyWith(color: Colors.orange),
      emailValidator: (value) {
        if (!value.contains('@') || !value.endsWith('.com')) {
          return "Email must contain '@' and end with '.com'";
        }
        return null;
      },
      passwordValidator: (value) {
        if (value.isEmpty) {
          return 'Password is empty';
        }
        return null;
      },
      onLogin: (loginData) {
        print('Login info');
        print('Name: ${loginData.name}');
        print('Password: ${loginData.password}');
        Navigator.of(context).pushNamed(DashboardScreen.routeName);
      },
      onSignup: (loginData) {
        print('Signup info');
        print('Name: ${loginData.name}');
        print('Password: ${loginData.password}');
        Navigator.of(context).pushNamed(DashboardScreen.routeName);
      },
      onRecoverPassword: (name) {
        print('Recover password info');
        print('Name: $name');
        // Show new password dialog
      },
    );
  }
}
