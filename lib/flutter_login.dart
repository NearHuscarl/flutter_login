library flutter_login;

import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/providers/login_theme.dart';
import 'theme.dart';
import 'src/color_helper.dart';
import 'src/providers/auth.dart';
import 'src/providers/login_messages.dart';
import 'src/regex.dart';
import 'src/widgets/auth_card.dart';
import 'src/widgets/fade_in.dart';
import 'src/widgets/hero_text.dart';
import 'src/widgets/gradient_box.dart';
export 'src/models/login_data.dart';
export 'src/providers/login_messages.dart';
export 'src/providers/login_theme.dart';

typedef TextStyleSetter = TextStyle Function(TextStyle);

class _AnimationTimeDilationDropdown extends StatelessWidget {
  _AnimationTimeDilationDropdown({
    @required this.onChanged,
    this.initialValue = 1.0,
  });

  final Function onChanged;
  final double initialValue;
  static const animationSpeeds = const [1, 2, 5, 10];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'x1 is normal time, x5 means the animation is 5x times slower for debugging purpose',
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 125,
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: animationSpeeds.indexOf(initialValue.toInt()),
              ),
              itemExtent: 30.0,
              backgroundColor: Colors.white,
              onSelectedItemChanged: onChanged,
              children: animationSpeeds.map((x) => Text('x$x')).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  _Header({
    this.logoPath,
    this.logoTag,
    this.title,
    this.titleTag,
    this.height = 250.0,
    this.logoController,
    this.titleController,
    @required this.loginTheme,
  });

  final String logoPath;
  final String logoTag;
  final String title;
  final String titleTag;
  final double height;
  final LoginTheme loginTheme;
  final AnimationController logoController;
  final AnimationController titleController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayLogo = logoPath != null;
    Widget logo = Image.asset(
      logoPath,
      filterQuality: FilterQuality.high,
      height: 125,
    );

    if (logoTag != null) {
      logo = Hero(
        tag: logoTag,
        child: logo,
      );
    }

    Widget header;

    if (titleTag != null) {
      header = HeroText(
        title,
        tag: titleTag,
        largeFontSize: loginTheme.beforeHeroFontSize,
        smallFontSize: loginTheme.afterHeroFontSize,
        style: theme.textTheme.display2,
        viewState: ViewState.enlarged,
      );
    } else {
      header = Text(
        title,
        style: theme.textTheme.display2,
      );
    }

    return SizedBox(
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          if (displayLogo)
            FadeIn(
              controller: logoController,
              offset: .25,
              fadeDirection: FadeDirection.topToBottom,
              child: logo,
            ),
          SizedBox(height: 5),
          FadeIn(
            controller: titleController,
            offset: .5,
            fadeDirection: FadeDirection.topToBottom,
            child: header,
          ),
        ],
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  LoginScreen({
    Key key,
    @required this.onSignup,
    @required this.onLogin,
    @required this.onRecoverPassword,
    this.title = 'Login',
    this.messages,
    this.theme,
    this.logo,
    this.emailValidator,
    this.passwordValidator,
    this.onChangeRouteAnimationCompleted,
    this.logoTag,
    this.titleTag,
  }) : super(key: key);

  final AuthCallback onSignup;
  final AuthCallback onLogin;
  final RecoverCallback onRecoverPassword;
  final String title;
  final LoginMessages messages;
  final LoginTheme theme;
  final String logo;
  final FormFieldValidator<String> emailValidator;
  final FormFieldValidator<String> passwordValidator;
  final Function onChangeRouteAnimationCompleted;
  final String logoTag;
  final String titleTag;

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
  static const loadingDuration = const Duration(milliseconds: 400);
  AnimationController _loadingController;
  AnimationController _logoController;
  AnimationController _titleController;
  double _selectTimeDilation = 1.0;

  @override
  void initState() {
    super.initState();

    _loadingController = AnimationController(
      vsync: this,
      duration: loadingDuration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.forward) {
          _logoController.forward();
          _titleController.forward();
        }
        if (status == AnimationStatus.reverse) {
          _logoController.reverse();
          _titleController.reverse();
        }
      });
    _logoController = AnimationController(
      vsync: this,
      duration: loadingDuration,
    );
    _titleController = AnimationController(
      vsync: this,
      duration: loadingDuration,
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
    _titleController.dispose();
  }

  void _reverseHeaderAnimation() {
    if (widget.logoTag == null) {
      _logoController.reverse();
    }
    if (widget.titleTag == null) {
      _titleController.reverse();
    }
  }

  Widget _buildHeader(double height, LoginTheme loginTheme) {
    return _Header(
      logoController: _logoController,
      titleController: _titleController,
      height: height,
      logoPath: widget.logo,
      logoTag: widget.logoTag,
      title: widget.title,
      titleTag: widget.titleTag,
      loginTheme: loginTheme,
    );
  }

  Widget _buildDebugAnimationButtons(Size deviceSize) {
    const textStyle = TextStyle(fontSize: 12, color: Colors.white);

    return Positioned(
      bottom: 0,
      right: 0,
      child: Row(
        children: <Widget>[
          RaisedButton(
            color: Colors.green,
            child: Text('OPTIONS', style: textStyle),
            onPressed: () {
              timeDilation = 1.0;

              showModalBottomSheet(
                context: context,
                builder: (_) {
                  return _AnimationTimeDilationDropdown(
                    initialValue: _selectTimeDilation,
                    onChanged: (int index) {
                      setState(() {
                        _selectTimeDilation = _AnimationTimeDilationDropdown
                            .animationSpeeds[index]
                            .toDouble();
                      });
                    },
                  );
                },
              ).then((_) {
                // wait until the BottomSheet close animation finishing before
                // assigning or you will have to watch x100 time slower animation
                Future.delayed(const Duration(milliseconds: 300), () {
                  timeDilation = _selectTimeDilation;
                });
              });
            },
          ),
          RaisedButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            color: Colors.blue,
            child: Text('LOADING', style: textStyle),
            onPressed: () => authCardKey.currentState.runLoadingAnimation(),
          ),
          RaisedButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            color: Colors.orange,
            child: Text('PAGE', style: textStyle),
            onPressed: () => authCardKey.currentState.runChangePageAnimation(),
          ),
          RaisedButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            color: Colors.red,
            child: Text('NAV', style: textStyle),
            onPressed: () =>
                authCardKey.currentState.runChangeRouteAnimation(deviceSize),
          ),
        ],
      ),
    );
  }

  ThemeData _mergeTheme({ThemeData theme, LoginTheme loginTheme}) {
    final originalPrimaryColor = loginTheme.primaryColor ?? theme.primaryColor;
    final primaryDarkShades = getDarkShades(originalPrimaryColor);
    final primaryColor = primaryDarkShades.length == 1
        ? lighten(primaryDarkShades.first)
        : primaryDarkShades.first;
    final primaryColorDark = primaryDarkShades.length >= 3
        ? primaryDarkShades[2]
        : primaryDarkShades[1];
    final accentColor = loginTheme.accentColor ?? theme.accentColor;
    final errorColor = loginTheme.errorColor ?? theme.errorColor;
    final titleStyle = theme.textTheme.display2
        .copyWith(
          color: accentColor,
          fontSize: loginTheme.beforeHeroFontSize,
          fontWeight: FontWeight.w300,
        )
        .merge(loginTheme.titleStyle);
    final textStyle = theme.textTheme.body1
        .copyWith(color: Colors.black54)
        .merge(loginTheme.bodyStyle);
    final textFieldStyle = theme.textTheme.subhead
        .copyWith(color: Colors.black.withOpacity(.65))
        .merge(loginTheme.textFieldStyle);
    final buttonStyle = theme.textTheme.button
        .copyWith(color: Colors.white)
        .merge(loginTheme.buttonStyle);
    final cardTheme = loginTheme.cardTheme;
    final inputTheme = loginTheme.inputTheme;
    final buttonTheme = loginTheme.buttonTheme;
    final roundBorderRadius = BorderRadius.circular(100);

    LoginThemeHelper.loginTextStyle = titleStyle;

    return theme.copyWith(
      primaryColor: primaryColor,
      primaryColorDark: primaryColorDark,
      accentColor: accentColor,
      errorColor: errorColor,
      cardTheme: theme.cardTheme.copyWith(
        clipBehavior: cardTheme.clipBehavior,
        color: cardTheme.color ?? theme.cardColor,
        elevation: cardTheme.elevation ?? 15.0,
        margin: cardTheme.margin,
        shape: cardTheme.shape ??
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      ),
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        filled: inputTheme.filled,
        fillColor: inputTheme.fillColor ??
            Color.alphaBlend(
              primaryColor.withOpacity(.07),
              Colors.grey.withOpacity(.04),
            ),
        contentPadding: inputTheme.contentPadding ??
            const EdgeInsets.symmetric(vertical: 4.0),
        errorStyle: inputTheme.errorStyle ?? TextStyle(color: errorColor),
        labelStyle: inputTheme.labelStyle,
        enabledBorder: inputTheme.enabledBorder ??
            OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
              borderRadius: roundBorderRadius,
            ),
        focusedBorder: inputTheme.focusedBorder ??
            OutlineInputBorder(
              borderSide: BorderSide(color: primaryColor, width: 1.5),
              borderRadius: roundBorderRadius,
            ),
        errorBorder: inputTheme.errorBorder ??
            OutlineInputBorder(
              borderSide: BorderSide(color: errorColor),
              borderRadius: roundBorderRadius,
            ),
        focusedErrorBorder: inputTheme.focusedErrorBorder ??
            OutlineInputBorder(
              borderSide: BorderSide(color: errorColor, width: 1.5),
              borderRadius: roundBorderRadius,
            ),
        border: inputTheme.border ??
            OutlineInputBorder(borderRadius: roundBorderRadius),
      ),
      floatingActionButtonTheme: theme.floatingActionButtonTheme.copyWith(
        backgroundColor: buttonTheme?.backgroundColor ?? primaryColor,
        splashColor: buttonTheme.splashColor ?? theme.accentColor,
        elevation: buttonTheme.elevation ?? 4.0,
        highlightElevation: buttonTheme.highlightElevation ?? 2.0,
        shape: buttonTheme.shape ?? StadiumBorder(),
      ),
      // put it here because floatingActionButtonTheme doesnt have highlightColor property
      highlightColor:
          loginTheme.buttonTheme.highlightColor ?? theme.highlightColor,
      textTheme: theme.textTheme.copyWith(
        display2: titleStyle,
        body1: textStyle,
        subhead: textFieldStyle,
        button: buttonStyle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginTheme = widget.theme ?? LoginTheme();
    final theme = _mergeTheme(theme: Theme.of(context), loginTheme: loginTheme);
    final deviceSize = MediaQuery.of(context).size;
    final headerHeight = deviceSize.height * .3;
    const logoMargin = 15;
    const cardInitialHeight = 300;
    final cardTopPosition = deviceSize.height / 2 - cardInitialHeight / 2;
    final emailValidator =
        widget.emailValidator ?? LoginScreen.defaultEmailValidator;
    final passwordValidator =
        widget.passwordValidator ?? LoginScreen.defaultPasswordValidator;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: widget.messages ?? LoginMessages(),
        ),
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
            GradientBox(
              colors: [theme.primaryColor, theme.primaryColorDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            SingleChildScrollView(
              child: Theme(
                data: theme,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Positioned(
                      child: AuthCard(
                        key: authCardKey,
                        padding: EdgeInsets.only(top: cardTopPosition),
                        loadingController: _loadingController,
                        emailValidator: emailValidator,
                        passwordValidator: passwordValidator,
                        onSubmit: _reverseHeaderAnimation,
                        onSubmitCompleted:
                            widget.onChangeRouteAnimationCompleted,
                      ),
                    ),
                    Positioned(
                      top: cardTopPosition - headerHeight - logoMargin,
                      child: _buildHeader(headerHeight, loginTheme),
                    ),
                  ],
                ),
              ),
            ),
            if (!kReleaseMode) _buildDebugAnimationButtons(deviceSize),
          ],
        ),
      ),
    );
  }
}
