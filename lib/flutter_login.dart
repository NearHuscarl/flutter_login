library flutter_login;

import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    this.titleTextStyle,
    this.titleTag,
    this.height = 250.0,
    this.logoController,
    this.titleController,
  });

  final String logoPath;
  final String logoTag;
  final String title;
  final TextStyleSetter titleTextStyle;
  final String titleTag;
  final double height;
  final AnimationController logoController;
  final AnimationController titleController;

  TextStyle _getTitleTextStyle(ThemeData theme) {
    final defaultStyle = LoginTheme.defaultLoginTitleStyle(theme);

    return titleTextStyle != null ? titleTextStyle(defaultStyle) : defaultStyle;
  }

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
        largeFontSize: LoginTheme.beforeHeroFontSize,
        smallFontSize: LoginTheme.afterHeroFontSize,
        style: _getTitleTextStyle(theme),
        viewState: ViewState.enlarged,
      );
    } else {
      header = Text(
        title,
        style: _getTitleTextStyle(theme),
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
    this.primaryColor,
    this.accentColor,
    this.errorColor,
    this.title = 'Login',
    this.titleTextStyle,
    this.messages,
    this.logo,
    this.emailValidator,
    this.passwordValidator,
    this.onChangeRouteAnimationCompleted,
    this.logoTag,
    this.titleTag,
  }) : super(key: key) {
    LoginTheme.accentColor = accentColor;
  }

  final AuthCallback onSignup;
  final AuthCallback onLogin;
  final RecoverCallback onRecoverPassword;
  final MaterialColor primaryColor;
  final Color accentColor;
  final Color errorColor;
  final String title;
  final LoginMessages messages;
  final TextStyleSetter titleTextStyle;
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

  Widget _buildHeader(double height) {
    return _Header(
      logoController: _logoController,
      titleController: _titleController,
      height: height,
      logoPath: widget.logo,
      logoTag: widget.logoTag,
      title: widget.title,
      titleTag: widget.titleTag,
      titleTextStyle: widget.titleTextStyle,
    );
  }

  Widget _buildTheme({Widget child, ThemeData theme, Color primaryColor}) =>
      Theme(
        data: theme.copyWith(
          primaryColor: primaryColor,
          accentColor: widget.accentColor ?? theme.accentColor,
          errorColor: widget.errorColor ?? theme.errorColor,
        ),
        child: child,
      );

  Widget _buildDebugAnimationButton(Size deviceSize) {
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

  List<Color> _getBackgroundGradientColors(Color color) {
    final primaryDarkShades = getDarkShades(color);

    if (primaryDarkShades.length == 1) {
      primaryDarkShades.insert(0, lighten(primaryDarkShades.first));
    }

    return [
      primaryDarkShades[0],
      primaryDarkShades.length >= 3
          ? primaryDarkShades[2]
          : primaryDarkShades[1],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeColor = widget.primaryColor ?? theme.primaryColor;
    final backgroundColors = _getBackgroundGradientColors(themeColor);
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
              colors: backgroundColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints.tightFor(
                  width: deviceSize.width,
                  height: deviceSize.height,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Positioned(
                      child: _buildTheme(
                        theme: theme,
                        primaryColor: backgroundColors.first,
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
                    ),
                    Positioned(
                      top: cardTopPosition - headerHeight - logoMargin,
                      child: _buildHeader(headerHeight),
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
