library flutter_login;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/models/login_data.dart';
import 'src/providers/auth.dart';
import 'src/regex.dart';
import 'src/widgets/auth_card.dart';
import 'src/widgets/fade_in.dart';

typedef TextStyleSetter = TextStyle Function(TextStyle);

class LoginScreen extends StatefulWidget {
  final String title;
  final TextStyleSetter titleTextStyle;
  final String logo;
  final Future<void> Function(LoginData) onSignup;
  final Future<void> Function(LoginData) onLogin;
  final Future<void> Function(String) onRecoverPassword;
  final FormFieldValidator<String> emailValidator;
  final FormFieldValidator<String> passwordValidator;
  final Function onChangeRouteAnimationCompleted;

  LoginScreen({
    this.title = 'Login',
    this.titleTextStyle,
    this.logo,
    this.onSignup,
    this.onLogin,
    this.onRecoverPassword,
    this.emailValidator,
    this.passwordValidator,
    this.onChangeRouteAnimationCompleted,
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

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  /// [authCardKey] is a state since hot reload preserves the state of widget,
  /// changes in [AuthCardState] will not trigger rebuilding the whole
  /// [LoginScreen], prevent running the loading animation again after every small
  /// changes
  /// https://flutter.dev/docs/development/tools/hot-reload#previous-state-is-combined-with-new-code
  final GlobalKey<AuthCardState> authCardKey = GlobalKey();
  AnimationController _loadingController;
  AnimationController _logoController;

  @override
  void initState() {
    super.initState();

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..addStatusListener((status) {
      if (status == AnimationStatus.forward) {
        _logoController.forward();
      }
      if (status == AnimationStatus.reverse) {
        _logoController.reverse();
      }
    });
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    Future.delayed(const Duration(seconds: 1), () {
      _loadingController.forward();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _loadingController.dispose();
    _logoController.dispose();
  }

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

  Widget _buildHeader(ThemeData theme, double height) {
    final displayLogo = widget.logo != null;

    return FadeIn(
      controller: _logoController,
      offset: .2,
      fadeDirection: FadeDirection.topToBottom,
      child: Container(
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            if (displayLogo)
              Image(
                image: AssetImage(widget.logo),
                height: 125,
              ),
            SizedBox(height: 5),
            Text(widget.title, style: _getTitleTextStyle(theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugAnimationButton(Size deviceSize) {
    final textStyle = TextStyle(fontSize: 12, color: Colors.white);
    return Positioned(
      bottom: 0,
      right: 0,
      child: Row(
        children: <Widget>[
          RaisedButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            color: Colors.blue,
            child: Text('loading', style: textStyle),
            onPressed: () => authCardKey.currentState.runLoadingAnimation(),
          ),
          RaisedButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            color: Colors.orange,
            child: Text('page', style: textStyle),
            onPressed: () => authCardKey.currentState.runChangePageAnimation(),
          ),
          RaisedButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            color: Colors.red,
            child: Text('nav', style: textStyle),
            onPressed: () =>
                authCardKey.currentState.runChangeRouteAnimation(deviceSize),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceSize = MediaQuery.of(context).size;
    final headerHeight = deviceSize.height * .3;
    const logoMargin = 15;
    const cardInitialHeight = 300;
    final cardTopPosition = deviceSize.height / 2 - cardInitialHeight / 2;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          /// dummy value for the second argument of [ProxyProviderBuilder] below
          value: Auth.empty(),
        ),

        /// use [ChangeNotifierProxyProvider] to get access to the previous
        /// [Auth] state since the state will keep being created when the soft
        /// keyboard trigger rebuilding
        ChangeNotifierProxyProvider<Auth, Auth>(
          builder: (context, auth, prevAuth) => Auth(
            onLogin: widget.onLogin,
            onSignup: widget.onSignup,
            onRecoverPassword: widget.onRecoverPassword,
            previous: prevAuth,
          ),
        ),
      ],
      child: Scaffold(
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
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Positioned(
                      child: AuthCard(
                        key: authCardKey,
                        padding: EdgeInsets.only(top: cardTopPosition),
                        loadingController: _loadingController,
                        emailValidator: widget.emailValidator ??
                            LoginScreen.defaultEmailValidator,
                        passwordValidator: widget.passwordValidator ??
                            LoginScreen.defaultPasswordValidator,
                        onSubmit: () => _logoController.reverse(),
                        onSubmitCompleted: widget.onChangeRouteAnimationCompleted,
                      ),
                    ),
                    Positioned(
                      top: cardTopPosition - headerHeight - logoMargin,
                      child: _buildHeader(theme, headerHeight),
                    ),
                  ],
                ),
              ),
            ),
            if (!kReleaseMode) _buildDebugAnimationButton(deviceSize),
          ],
        ),
      ),
    );
  }
}
