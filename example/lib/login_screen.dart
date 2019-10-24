import 'dart:async';

import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart' as Login;
import 'constants.dart';
import 'custom_route.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/auth';

  Future<void> _loginUser(BuildContext context) {
    return Future.delayed(Duration(milliseconds: timeDilation.ceil() * 1250));
  }

  Future _recoverPassword() {
    return Future.delayed(Duration(milliseconds: timeDilation.ceil() * 1250),
        () {
      // send email
    });
  }

  @override
  Widget build(BuildContext context) {
    return Login.LoginScreen(
      title: Constants.appName,
      logo: 'assets/images/ecorp.png',
      logoTag: Constants.logoTag,
      titleTag: Constants.titleTag,
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
        return _loginUser(context);
      },
      onSignup: (loginData) {
        print('Signup info');
        print('Name: ${loginData.name}');
        print('Password: ${loginData.password}');
        return _loginUser(context);
      },
      onChangeRouteAnimationCompleted: () {
        Navigator.of(context).pushReplacement(FadePageRoute(
          builder: (context) => DashboardScreen(),
        ));
      },
      onRecoverPassword: (name) async {
        print('Recover password info');
        print('Name: $name');
        return _recoverPassword();
        // Show new password dialog
      },
    );
  }
}
