library flutter_login;

import 'package:flutter/material.dart';
import 'src/login_data.dart';
import 'src/regex.dart';
import 'src/widgets/auth_card.dart';
import 'src/widgets/fade_in.dart';

enum BuildMode { debug, profile, release }

// https://github.com/flutter/flutter/issues/11392#issuecomment-461668769
BuildMode buildMode = (() {
  if (const bool.fromEnvironment('dart.vm.product')) {
    return BuildMode.release;
  }
  var result = BuildMode.profile;
  assert(() {
    result = BuildMode.debug;
    return true;
  }());
  return result;
}());

typedef TextStyleSetter = TextStyle Function(TextStyle);

class LoginScreen extends StatefulWidget {
  final String title;
  final TextStyleSetter titleTextStyle;
  final String logoAsset;
  final Future<void> Function(LoginData) onSignup;
  final Future<void> Function(LoginData) onLogin;
  final Future<void> Function(String) onRecoverPassword;
  final FormFieldValidator<String> emailValidator;
  final FormFieldValidator<String> passwordValidator;

  LoginScreen({
    this.title = 'Login',
    this.titleTextStyle,
    this.logoAsset,
    this.onSignup,
    this.onLogin,
    this.onRecoverPassword,
    this.emailValidator,
    this.passwordValidator,
  });

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

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// [authCardKey] is a state since hot reload preserves the state of widget,
  /// changes in [AuthCardState] will not trigger rebuilding the whole
  /// [LoginScreen], prevent running the loading animation again after every small
  /// changes
  /// https://flutter.dev/docs/development/tools/hot-reload#previous-state-is-combined-with-new-code
  final GlobalKey<AuthCardState> authCardKey = GlobalKey();

  TextStyle _getTitleTextStyle(ThemeData theme) {
    final defaultTextStyle = TextStyle(
      color: theme.primaryTextTheme.title.color,
      fontSize: 50,
      fontWeight: FontWeight.w300,
    );
    return widget.titleTextStyle != null
        ? widget.titleTextStyle(defaultTextStyle)
        : defaultTextStyle;
  }

  Widget _buildDebugAnimationButton() {
    if (buildMode != BuildMode.release) {
      return Positioned(
        bottom: 0,
        child: InkWell(
          child: Container(
            width: 50,
            height: 50,
            color: buildMode == BuildMode.debug
                ? Colors.red
                : Colors.transparent, // BuildMode.profile
          ),
          onTap: () {
            authCardKey.currentState.runLoadingAnimation();
          },
        ),
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceSize = MediaQuery.of(context).size;
    final displayLogo = widget.logoAsset != null;

    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor.withOpacity(1.0),
                  theme.primaryColor.withOpacity(0.7),
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
                      image: AssetImage(widget.logoAsset),
                      height: 125,
                    ),
                  SizedBox(height: 5),
                  FadeIn(
                    fadeDirection: FadeDirection.bottomToTop,
                    duration: Duration(milliseconds: 1200),
                    child: Text(widget.title, style: _getTitleTextStyle(theme)),
                  ),
                  SizedBox(height: 15),
                  AuthCard(
                    key: authCardKey,
                    onLogin: widget.onLogin,
                    onSignup: widget.onSignup,
                    onRecoverPassword: widget.onRecoverPassword,
                    emailValidator: widget.emailValidator ?? LoginScreen.defaultEmailValidator,
                    passwordValidator:
                        widget.passwordValidator ?? LoginScreen.defaultPasswordValidator,
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
          _buildDebugAnimationButton(),
        ],
      ),
    );
  }
}
