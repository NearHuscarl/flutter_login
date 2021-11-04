library flutter_login;

import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/src/models/login_user_type.dart';
import 'package:provider/provider.dart';
import 'src/providers/login_theme.dart';
import 'src/widgets/null_widget.dart';
import 'theme.dart';
import 'src/dart_helper.dart';
import 'src/color_helper.dart';
import 'src/providers/auth.dart';
import 'src/providers/login_messages.dart';
import 'src/regex.dart';
import 'src/widgets/auth_card.dart';
import 'src/widgets/fade_in.dart';
import 'src/widgets/hero_text.dart';
import 'src/widgets/gradient_box.dart';
export 'src/models/login_data.dart';
export 'src/models/login_user_type.dart';
export 'src/providers/login_messages.dart';
export 'src/providers/login_theme.dart';
import 'src/constants.dart';

class LoginProvider {
  final IconData icon;
  final String label;
  final ProviderAuthCallback callback;

  LoginProvider({required this.icon, required this.callback, this.label = ''});
}

class _AnimationTimeDilationDropdown extends StatelessWidget {
  _AnimationTimeDilationDropdown({
    required this.onChanged,
    this.initialValue = 1.0,
  });

  final Function onChanged;
  final double initialValue;
  static const animationSpeeds = [1, 2, 5, 10];

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
              onSelectedItemChanged: onChanged as void Function(int)?,
              children: animationSpeeds.map((x) => Text('x$x')).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatefulWidget {
  _Header({
    this.logoPath,
    this.logoTag,
    this.logoWidth = 0.75,
    this.title,
    this.titleTag,
    this.height = 250.0,
    this.logoController,
    this.titleController,
    required this.loginTheme,
    this.footer,
  });

  final String? logoPath;
  final String? logoTag;
  final double logoWidth;
  final String? title;
  final String? titleTag;
  final double height;
  final LoginTheme loginTheme;
  final AnimationController? logoController;
  final AnimationController? titleController;
  final String? footer;

  @override
  __HeaderState createState() => __HeaderState();
}

class __HeaderState extends State<_Header> {
  double _titleHeight = 0.0;

  /// https://stackoverflow.com/a/56997641/9449426
  double getEstimatedTitleHeight() {
    if (DartHelper.isNullOrEmpty(widget.title)) {
      return 0.0;
    }

    final theme = Theme.of(context);
    final renderParagraph = RenderParagraph(
      TextSpan(
        text: widget.title,
        style: theme.textTheme.headline3!.copyWith(
          fontSize: widget.loginTheme.beforeHeroFontSize,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );

    renderParagraph.layout(BoxConstraints());

    return renderParagraph
        .getMinIntrinsicHeight(widget.loginTheme.beforeHeroFontSize)
        .ceilToDouble();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _titleHeight = getEstimatedTitleHeight();
  }

  @override
  void didUpdateWidget(_Header oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.title != oldWidget.title) {
      _titleHeight = getEstimatedTitleHeight();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const gap = 5.0;
    final logoHeight = min(
        (widget.height - MediaQuery.of(context).padding.top) -
            _titleHeight -
            gap,
        kMaxLogoHeight);
    final displayLogo = widget.logoPath != null && logoHeight >= kMinLogoHeight;
    final cardWidth = min(MediaQuery.of(context).size.width * 0.75, 360.0);

    var logo = displayLogo
        ? Image.asset(
            widget.logoPath!,
            filterQuality: FilterQuality.high,
            height: logoHeight,
            width: widget.logoWidth * cardWidth,
          )
        : NullWidget();

    if (widget.logoTag != null) {
      logo = Hero(
        tag: widget.logoTag!,
        child: logo,
      );
    }

    Widget? title;
    if (widget.titleTag != null && !DartHelper.isNullOrEmpty(widget.title)) {
      title = HeroText(
        widget.title,
        key: kTitleKey,
        tag: widget.titleTag,
        largeFontSize: widget.loginTheme.beforeHeroFontSize,
        smallFontSize: widget.loginTheme.afterHeroFontSize,
        style: theme.textTheme.headline3,
        viewState: ViewState.enlarged,
      );
    } else if (!DartHelper.isNullOrEmpty(widget.title)) {
      title = Text(
        widget.title!,
        key: kTitleKey,
        style: theme.textTheme.headline3,
      );
    } else {
      title = null;
    }

    return SafeArea(
      child: SizedBox(
        height: (widget.height - MediaQuery.of(context).padding.top),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            if (displayLogo)
              FadeIn(
                controller: widget.logoController,
                offset: .25,
                fadeDirection: FadeDirection.topToBottom,
                child: logo,
              ),
            SizedBox(height: gap),
            FadeIn(
              controller: widget.titleController,
              offset: .5,
              fadeDirection: FadeDirection.topToBottom,
              child: title,
            ),
          ],
        ),
      ),
    );
  }
}

class FlutterLogin extends StatefulWidget {
  FlutterLogin(
      {Key? key,
      required this.onSignup,
      required this.onLogin,
      required this.onRecoverPassword,
      this.title,
      this.logo,
      this.messages,
      this.theme,
      this.userValidator,
      this.passwordValidator,
      this.onSubmitAnimationCompleted,
      this.logoTag,
      this.userType = LoginUserType.name,
      this.titleTag,
      this.showDebugButtons = false,
      this.loginProviders = const <LoginProvider>[],
      this.hideForgotPasswordButton = false,
      this.hideSignUpButton = false,
      this.loginAfterSignUp = true,
      this.footer,
      this.hideProvidersTitle = false,
      this.disableCustomPageTransformer = false,
      this.navigateBackAfterRecovery = false})
      : super(key: key);

  /// Called when the user hit the submit button when in sign up mode
  final AuthCallback onSignup;

  /// Called when the user hit the submit button when in login mode
  final AuthCallback onLogin;

  /// [LoginUserType] can be email, name or phone, by default is email. It will change how
  /// the edit text autofill and behave accordingly to your choice
  final LoginUserType userType;

  /// list of LoginProvider each have an icon and a callback that will be Called when
  /// the user hit the provider icon button
  /// if not specified nothing will be shown
  final List<LoginProvider> loginProviders;

  /// Called when the user hit the submit button when in recover password mode
  final RecoverCallback onRecoverPassword;

  /// The large text above the login [Card], usually the app or company name
  final String? title;

  /// The path to the asset image that will be passed to the `Image.asset()`
  final String? logo;

  /// Describes all of the labels, text hints, button texts and other auth
  /// descriptions
  final LoginMessages? messages;

  /// FlutterLogin's theme. If not specified, it will use the default theme as
  /// shown in the demo gifs and use the colorsheme in the closest `Theme`
  /// widget
  final LoginTheme? theme;

  /// Email validating logic, Returns an error string to display if the input is
  /// invalid, or null otherwise
  final FormFieldValidator<String>? userValidator;

  /// Same as [userValidator] but for password
  final FormFieldValidator<String>? passwordValidator;

  /// Called after the submit animation's completed. Put your route transition
  /// logic here. Recommend to use with [logoTag] and [titleTag]
  final Function? onSubmitAnimationCompleted;

  /// Hero tag for logo image. If not specified, it will simply fade out when
  /// changing route
  final String? logoTag;

  /// Hero tag for title text. Need to specify `LoginTheme.beforeHeroFontSize`
  /// and `LoginTheme.afterHeroFontSize` if you want different font size before
  /// and after hero animation
  final String? titleTag;

  /// Display the debug buttons to quickly forward/reverse login animations. In
  /// release mode, this will be overrided to false regardless of the value
  /// passed in
  final bool showDebugButtons;

  /// Set to true to hide the Forgot Password button
  final bool hideForgotPasswordButton;

  /// Set to true to hide the SignUp button
  final bool hideSignUpButton;

  /// Set to false to return back to sign in page after successful sign up
  final bool loginAfterSignUp;

  /// Optional footer text for example a copyright notice
  final String? footer;

  /// Hide the title above the login providers. If no providers are set this is uneffective
  final bool hideProvidersTitle;

  /// Disable the page transformation between switching authentication modes.
  /// Fixes #97 if disabled. https://github.com/NearHuscarl/flutter_login/issues/97
  final bool disableCustomPageTransformer;

  /// Navigate back to the login screen after recovery of password.
  final bool navigateBackAfterRecovery;

  static final FormFieldValidator<String> defaultEmailValidator = (value) {
    if (value!.isEmpty || !Regex.email.hasMatch(value)) {
      return 'Invalid email!';
    }
    return null;
  };

  static final FormFieldValidator<String> defaultPasswordValidator = (value) {
    if (value!.isEmpty || value.length <= 2) {
      return 'Password is too short!';
    }
    return null;
  };

  @override
  _FlutterLoginState createState() => _FlutterLoginState();
}

class _FlutterLoginState extends State<FlutterLogin>
    with TickerProviderStateMixin {
  final GlobalKey<AuthCardState> authCardKey = GlobalKey();
  static const loadingDuration = Duration(milliseconds: 400);
  AnimationController? _loadingController;
  AnimationController? _logoController;
  AnimationController? _titleController;
  double _selectTimeDilation = 1.0;

  @override
  void initState() {
    super.initState();

    _loadingController = AnimationController(
      vsync: this,
      duration: loadingDuration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.forward) {
          _logoController!.forward();
          _titleController!.forward();
        }
        if (status == AnimationStatus.reverse) {
          _logoController!.reverse();
          _titleController!.reverse();
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
      _loadingController!.forward();
    });
  }

  @override
  void dispose() {
    _loadingController!.dispose();
    _logoController!.dispose();
    _titleController!.dispose();
    super.dispose();
  }

  void _reverseHeaderAnimation() {
    if (widget.logoTag == null) {
      _logoController!.reverse();
    }
    if (widget.titleTag == null) {
      _titleController!.reverse();
    }
  }

  Widget _buildHeader(double height, LoginTheme loginTheme) {
    return _Header(
      logoController: _logoController,
      titleController: _titleController,
      height: height,
      logoPath: widget.logo,
      logoTag: widget.logoTag,
      logoWidth: widget.theme?.logoWidth ?? 0.75,
      title: widget.title,
      titleTag: widget.titleTag,
      loginTheme: loginTheme,
    );
  }

  Widget _buildDebugAnimationButtons() {
    const textStyle = TextStyle(fontSize: 12, color: Colors.white);

    return Positioned(
      bottom: 0,
      right: 0,
      child: Row(
        key: kDebugToolbarKey,
        children: <Widget>[
          MaterialButton(
            color: Colors.green,
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
            child: Text('OPTIONS', style: textStyle),
          ),
          MaterialButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            color: Colors.blue,
            onPressed: () => authCardKey.currentState!.runLoadingAnimation(),
            child: Text('LOADING', style: textStyle),
          ),
          MaterialButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            color: Colors.orange,
            onPressed: () => authCardKey.currentState!.runChangePageAnimation(),
            child: Text('PAGE', style: textStyle),
          ),
          MaterialButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            color: Colors.red,
            onPressed: () =>
                authCardKey.currentState!.runChangeRouteAnimation(),
            child: Text('NAV', style: textStyle),
          ),
        ],
      ),
    );
  }

  ThemeData _mergeTheme(
      {required ThemeData theme, required LoginTheme loginTheme}) {
    final blackOrWhite =
        theme.brightness == Brightness.light ? Colors.black54 : Colors.white;
    final primaryOrWhite = theme.brightness == Brightness.light
        ? theme.primaryColor
        : Colors.white;
    final originalPrimaryColor = loginTheme.primaryColor ?? theme.primaryColor;
    final primaryDarkShades = getDarkShades(originalPrimaryColor);
    final primaryColor = primaryDarkShades.length == 1
        ? lighten(primaryDarkShades.first!)
        : primaryDarkShades.first;
    final primaryColorDark = primaryDarkShades.length >= 3
        ? primaryDarkShades[2]
        : primaryDarkShades.last;
    final accentColor =
        loginTheme.accentColor ?? Theme.of(context).colorScheme.secondary;
    final errorColor = loginTheme.errorColor ?? theme.errorColor;
    // the background is a dark gradient, force to use white text if detect default black text color
    final isDefaultBlackText = theme.textTheme.headline3!.color ==
        Typography.blackMountainView.headline3!.color;
    final titleStyle = theme.textTheme.headline3!
        .copyWith(
          color: loginTheme.accentColor ??
              (isDefaultBlackText
                  ? Colors.white
                  : theme.textTheme.headline3!.color),
          fontSize: loginTheme.beforeHeroFontSize,
          fontWeight: FontWeight.w300,
        )
        .merge(loginTheme.titleStyle);
    final textStyle = theme.textTheme.bodyText2!
        .copyWith(color: blackOrWhite)
        .merge(loginTheme.bodyStyle);
    final textFieldStyle = theme.textTheme.subtitle1!
        .copyWith(color: blackOrWhite, fontSize: 14)
        .merge(loginTheme.textFieldStyle);
    final buttonStyle = theme.textTheme.button!
        .copyWith(color: Colors.white)
        .merge(loginTheme.buttonStyle);
    final cardTheme = loginTheme.cardTheme;
    final inputTheme = loginTheme.inputTheme;
    final buttonTheme = loginTheme.buttonTheme;
    final roundBorderRadius = BorderRadius.circular(100);

    LoginThemeHelper.loginTextStyle = titleStyle;

    var labelStyle;

    if (loginTheme.primaryColorAsInputLabel) {
      labelStyle = TextStyle(color: primaryColor);
    } else {
      labelStyle = TextStyle(color: blackOrWhite);
    }

    return theme.copyWith(
      primaryColor: primaryColor,
      primaryColorDark: primaryColorDark,
      colorScheme: theme.colorScheme.copyWith(secondary: accentColor),
      errorColor: errorColor,
      cardTheme: theme.cardTheme.copyWith(
        clipBehavior: cardTheme.clipBehavior,
        color: cardTheme.color ?? theme.cardColor,
        elevation: cardTheme.elevation ?? 12.0,
        margin: cardTheme.margin ?? const EdgeInsets.all(4.0),
        shape: cardTheme.shape ??
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      ),
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        filled: inputTheme.filled,
        fillColor: inputTheme.fillColor ??
            Color.alphaBlend(
              primaryOrWhite.withOpacity(.07),
              Colors.grey.withOpacity(.04),
            ),
        contentPadding: inputTheme.contentPadding ??
            const EdgeInsets.symmetric(vertical: 4.0),
        errorStyle: inputTheme.errorStyle ?? TextStyle(color: errorColor),
        labelStyle: inputTheme.labelStyle ?? labelStyle,
        enabledBorder: inputTheme.enabledBorder ??
            inputTheme.border ??
            OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
              borderRadius: roundBorderRadius,
            ),
        focusedBorder: inputTheme.focusedBorder ??
            inputTheme.border ??
            OutlineInputBorder(
              borderSide: BorderSide(color: primaryColor!, width: 1.5),
              borderRadius: roundBorderRadius,
            ),
        errorBorder: inputTheme.errorBorder ??
            inputTheme.border ??
            OutlineInputBorder(
              borderSide: BorderSide(color: errorColor),
              borderRadius: roundBorderRadius,
            ),
        focusedErrorBorder: inputTheme.focusedErrorBorder ??
            inputTheme.border ??
            OutlineInputBorder(
              borderSide: BorderSide(color: errorColor, width: 1.5),
              borderRadius: roundBorderRadius,
            ),
        disabledBorder: inputTheme.disabledBorder ?? inputTheme.border,
      ),
      floatingActionButtonTheme: theme.floatingActionButtonTheme.copyWith(
        backgroundColor: buttonTheme.backgroundColor ?? primaryColor,
        splashColor:
            buttonTheme.splashColor ?? Theme.of(context).colorScheme.secondary,
        elevation: buttonTheme.elevation ?? 4.0,
        highlightElevation: buttonTheme.highlightElevation ?? 2.0,
        shape: buttonTheme.shape ?? StadiumBorder(),
      ),
      // put it here because floatingActionButtonTheme doesnt have highlightColor property
      highlightColor:
          loginTheme.buttonTheme.highlightColor ?? theme.highlightColor,
      textTheme: theme.textTheme.copyWith(
        headline3: titleStyle,
        bodyText2: textStyle,
        subtitle1: textFieldStyle,
        button: buttonStyle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginTheme = widget.theme ?? LoginTheme();
    final theme = _mergeTheme(theme: Theme.of(context), loginTheme: loginTheme);
    final deviceSize = MediaQuery.of(context).size;
    const headerMargin = 15;
    const cardInitialHeight = 300;
    final cardTopPosition = deviceSize.height / 2 - cardInitialHeight / 2;
    final headerHeight = cardTopPosition - headerMargin;
    final userValidator =
        widget.userValidator ?? FlutterLogin.defaultEmailValidator;
    final passwordValidator =
        widget.passwordValidator ?? FlutterLogin.defaultPasswordValidator;

    Widget footerWidget = SizedBox();
    if (widget.footer != null) {
      footerWidget = Padding(
        padding: EdgeInsets.only(bottom: loginTheme.footerBottomPadding),
        child: Text(
          widget.footer!,
          style: loginTheme.footerTextStyle,
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: widget.messages ??
              LoginMessages(
                userHint: (widget.userType == LoginUserType.name)
                    ? LoginMessages.defaultUsernameHint
                    : LoginMessages.defaultUserHint,
              ),
        ),
        ChangeNotifierProvider.value(
          value: widget.theme ?? LoginTheme(),
        ),
        ChangeNotifierProvider(
          create: (context) => Auth(
            onLogin: widget.onLogin,
            onSignup: widget.onSignup,
            onRecoverPassword: widget.onRecoverPassword,
            loginProviders: widget.loginProviders,
          ),
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: <Widget>[
            GradientBox(
              colors: [
                loginTheme.pageColorLight ?? theme.primaryColor,
                loginTheme.pageColorDark ?? theme.primaryColorDark,
              ],
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
                        userType: widget.userType,
                        padding: EdgeInsets.only(top: cardTopPosition),
                        loadingController: _loadingController,
                        userValidator: userValidator,
                        passwordValidator: passwordValidator,
                        onSubmit: _reverseHeaderAnimation,
                        onSubmitCompleted: widget.onSubmitAnimationCompleted,
                        hideSignUpButton: widget.hideSignUpButton,
                        hideForgotPasswordButton:
                            widget.hideForgotPasswordButton,
                        loginAfterSignUp: widget.loginAfterSignUp,
                        hideProvidersTitle: widget.hideProvidersTitle,
                        disableCustomPageTransformer:
                            widget.disableCustomPageTransformer,
                        loginTheme: widget.theme,
                        navigateBackAfterRecovery:
                            widget.navigateBackAfterRecovery,
                      ),
                    ),
                    Positioned(
                      top: cardTopPosition - headerHeight - headerMargin,
                      child: _buildHeader(headerHeight, loginTheme),
                    ),
                    Positioned.fill(
                        child: Align(
                            alignment: Alignment.bottomCenter,
                            child: footerWidget))
                  ],
                ),
              ),
            ),
            if (!kReleaseMode && widget.showDebugButtons)
              _buildDebugAnimationButtons(),
          ],
        ),
      ),
    );
  }
}
