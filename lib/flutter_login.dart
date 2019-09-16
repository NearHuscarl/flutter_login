library flutter_login;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'src/login_data.dart';
import 'src/regex.dart';
import 'src/widgets/auth_card.dart';

typedef TextStyleSetter = TextStyle Function(TextStyle);

class LoginScreen extends StatelessWidget {
  final String title;
  final TextStyleSetter titleTextStyle;
  final String logoAsset;
  final Function(LoginData) onSignup;
  final Function(LoginData) onLogin;
  final Function(String) onRecoverPassword;
  final FormFieldValidator<String> emailValidator;
  final FormFieldValidator<String> passwordValidator;

  LoginScreen({
    this.title = 'My App',
    this.titleTextStyle,
    this.logoAsset,
    this.onSignup,
    this.onLogin,
    this.onRecoverPassword,
    this.emailValidator,
    this.passwordValidator,
  }) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: SystemUiOverlayStyle.dark.systemNavigationBarColor,
    ));
  }

  static final FormFieldValidator<String> defaultEmailValidator = (value) {
    if (value.isEmpty || !Regex.email.hasMatch(value)) {
      return 'Invalid email!';
    }
    return null;
  };

  static final FormFieldValidator<String> defaultPasswordValidator = (value) {
    if (value.isEmpty || value.length <= 2) {
      return 'Password is too short!';
    }
    return null;
  };

  TextStyle _getTitleTextStyle(BuildContext context) {
    final defaultTextStyle = TextStyle(
      color: Theme.of(context).primaryTextTheme.title.color,
      fontSize: 50,
      fontWeight: FontWeight.normal,
    );
    return titleTextStyle != null
        ? titleTextStyle(defaultTextStyle)
        : defaultTextStyle;
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final displayLogo = logoAsset != null;

    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.9),
                  Theme.of(context).primaryColor.withOpacity(0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  if (displayLogo)
                    Image(
                      image: AssetImage(logoAsset),
                      height: 125,
                    ),
                  SizedBox(height: 5),
                  Text(title, style: _getTitleTextStyle(context)),
                  SizedBox(height: 15),
                  AuthCard(
                    onLogin: onLogin,
                    onSignup: onSignup,
                    onRecoverPassword: onRecoverPassword,
                    emailValidator: emailValidator ?? defaultEmailValidator,
                    passwordValidator:
                        passwordValidator ?? defaultPasswordValidator,
                  ),
                  SizedBox(height: 15),
                  Container(
                    // empty container to push the login form up a bit
                    // the logo and title widgets is about 150px height
                    height: (displayLogo ? 150 : 25) / 2,
                    // color: Colors.red,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
