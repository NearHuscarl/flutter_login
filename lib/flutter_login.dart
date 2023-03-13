library flutter_login;

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter_login/src/color_helper.dart';
import 'package:flutter_login/src/constants.dart';
import 'package:flutter_login/src/dart_helper.dart';
import 'package:flutter_login/src/models/login_user_type.dart';
import 'package:flutter_login/src/models/term_of_service.dart';
import 'package:flutter_login/src/models/user_form_field.dart';
import 'package:flutter_login/src/providers/auth.dart';
import 'package:flutter_login/src/providers/login_messages.dart';
import 'package:flutter_login/src/providers/login_theme.dart';
import 'package:flutter_login/src/regex.dart';
import 'package:flutter_login/src/widgets/cards/auth_card_builder.dart';
import 'package:flutter_login/src/widgets/fade_in.dart';
import 'package:flutter_login/src/widgets/gradient_box.dart';
import 'package:flutter_login/src/widgets/hero_text.dart';
import 'package:flutter_login/theme.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_button/sign_in_button.dart';

export 'package:sign_in_button/src/button_list.dart';

export 'src/models/login_data.dart';
export 'src/models/login_user_type.dart';
export 'src/models/signup_data.dart';
export 'src/models/term_of_service.dart';
export 'src/models/user_form_field.dart';
export 'src/providers/auth.dart';
export 'src/providers/login_messages.dart';
export 'src/providers/login_theme.dart';

class LoginProvider {
  /// Used for custom sign-in buttons.
  ///
  /// NOTE: Both [button] and [icon] can be added to [LoginProvider],
  /// but [button] will take preference over [icon]
  final Buttons? button;

  /// The icon shown on the provider button
  ///
  /// NOTE: Both [button] and [icon] can be added to [LoginProvider],
  /// but [button] will take preference over [icon]
  final IconData? icon;

  /// The label shown under the provider
  final String label;

  /// A Function called when the provider button is pressed.
  /// It must return null on success, or a `String` describing the error on failure.
  final ProviderAuthCallback callback;

  /// Optional
  ///
  /// Requires that the `additionalSignUpFields` argument is passed to `FlutterLogin`.
  /// When given, this callback must return a `Future<bool>`.
  /// If it evaluates to `true` the card containing the additional signup fields is shown, right after the evaluation of `callback`.
  /// If not given the default behaviour is not to show the signup card.
  final ProviderNeedsSignUpCallback? providerNeedsSignUpCallback;

  /// Enable or disable the animation of the button.
  ///
  /// Default: true
  final bool animated;

  const LoginProvider({
    this.button,
    this.icon,
    required this.callback,
    this.label = '',
    this.providerNeedsSignUpCallback,
    this.animated = true,
  }) : assert(button != null || icon != null);
}

class _AnimationTimeDilationDropdown extends StatelessWidget {
  const _AnimationTimeDilationDropdown({
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
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(10.0),
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
  const _Header({
    this.logo,
    this.logoTag,
    this.logoWidth = 0.75,
    this.title,
    this.titleTag,
    this.height = 250.0,
    this.logoController,
    this.titleController,
    required this.loginTheme,
  });

  final ImageProvider? logo;
  final String? logoTag;
  final double logoWidth;
  final String? title;
  final String? titleTag;
  final double height;
  final LoginTheme loginTheme;
  final AnimationController? logoController;
  final AnimationController? titleController;

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

    renderParagraph.layout(const BoxConstraints());

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
      (widget.height - MediaQuery.of(context).padding.top) - _titleHeight - gap,
      kMaxLogoHeight,
    );
    final displayLogo = widget.logo != null && logoHeight >= kMinLogoHeight;
    final cardWidth = min(MediaQuery.of(context).size.width * 0.75, 360.0);

    var logo = displayLogo
        ? Image(
            image: widget.logo!,
            filterQuality: FilterQuality.high,
            height: logoHeight,
            width: widget.logoWidth * cardWidth,
          )
        : const SizedBox.shrink();

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
        height: widget.height - MediaQuery.of(context).padding.top,
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
            const SizedBox(height: gap),
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
  FlutterLogin({
    super.key,
    this.onSignup,
    required this.onLogin,
    required this.onRecoverPassword,
    this.title,

    /// The [ImageProvider] or asset path [String] for the logo image to be displayed
    dynamic logo,
    this.messages,
    this.theme,
    this.userValidator,
    this.validateUserImmediately,
    this.passwordValidator,
    this.onSubmitAnimationCompleted,
    this.logoTag,
    this.userType = LoginUserType.email,
    this.titleTag,
    this.showDebugButtons = false,
    this.loginProviders = const <LoginProvider>[],
    this.hideForgotPasswordButton = false,
    this.loginAfterSignUp = true,
    this.footer,
    this.hideProvidersTitle = false,
    this.additionalSignupFields,
    this.disableCustomPageTransformer = false,
    this.navigateBackAfterRecovery = false,
    this.termsOfService = const <TermOfService>[],
    this.onConfirmRecover,
    this.onConfirmSignup,
    this.confirmSignupRequired,
    this.onResendCode,
    this.savedEmail = '',
    this.savedPassword = '',
    this.initialAuthMode = AuthMode.login,
    this.children,
    this.scrollable = false,
    this.confirmSignupKeyboardType,
    this.headerWidget,
    this.onSwitchToAdditionalFields,
  })  : assert((logo is String?) || (logo is ImageProvider?)),
        logo = logo is String ? AssetImage(logo) : logo as ImageProvider?;

  /// Called when the user hit the submit button when in sign up mode
  ///
  /// Can be null to disable signup.
  final SignupCallback? onSignup;

  /// Called when the user hit the submit button when in login mode
  final LoginCallback onLogin;

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

  /// The image provider for the logo image to be displayed
  final ImageProvider? logo;

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

  /// Should email be validated after losing focus [true] or after form
  /// submissions [false]. Default: [false]
  final bool? validateUserImmediately;

  /// Same as [userValidator] but for password
  final FormFieldValidator<String>? passwordValidator;

  /// Called after the submit animation's completed. Put your route transition
  /// logic here. Recommend to use with [logoTag] and [titleTag]
  final VoidCallback? onSubmitAnimationCompleted;

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

  /// This List contains the additional signup fields.
  /// By setting this, after signup another card with a form for additional user data is shown
  final List<UserFormField>? additionalSignupFields;

  /// Called when the user hit the submit button when in sign up mode, before
  /// additionalSignupFields are shown
  /// Optional
  final BeforeAdditionalFieldsCallback? onSwitchToAdditionalFields;

  /// Set to true to hide the Forgot Password button
  final bool hideForgotPasswordButton;

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

  /// Called when the user submits confirmation code in recover password mode
  /// Optional
  final ConfirmRecoverCallback? onConfirmRecover;

  /// Called when the user hits the submit button when in confirm signup mode
  /// Optional
  final ConfirmSignupCallback? onConfirmSignup;

  // Additional option to decide in runtime if confirmation is required
  // Optional
  final ConfirmSignupRequiredCallback? confirmSignupRequired;

  /// Sets [TextInputType] of sign up confirmation form.
  ///
  /// Defaults to [TextInputType.text].
  final TextInputType? confirmSignupKeyboardType;

  /// Called when the user hits the resend code button in confirm signup mode
  /// Only when onConfirmSignup is set
  final SignupCallback? onResendCode;

  /// Prefilled (ie. saved from previous session) value at startup for username
  /// (Auth class calls username email, therefore we use savedEmail here aswell)
  final String savedEmail;

  /// Prefilled (ie. saved from previous session) value at startup for password (applies both
  /// to Auth class password and confirmation password)
  final String savedPassword;

  /// List of terms of service to be listed during registration. On onSignup callback LoginData contains a list of TermOfServiceResult
  final List<TermOfService> termsOfService;

  /// The initial auth mode for the widget to show. This defaults to [AuthMode.login]
  /// if not specified. This field can allow you to show the sign up state by default.
  final AuthMode initialAuthMode;

  /// Supply custom widgets to the auth stack such as a custom logo widget
  final List<Widget>? children;

  /// If set to true, make the login window scrollable when overflowing instead
  /// of resizing the window.
  /// Default: false
  final bool scrollable;

  /// A widget that can be placed on top of the loginCard.
  final Widget? headerWidget;

  static String? defaultEmailValidator(String? value) {
    if (value == null || value.isEmpty || !Regex.email.hasMatch(value)) {
      return 'Invalid email!';
    }
    return null;
  }

  static String? defaultPasswordValidator(String? value) {
    if (value == null || value.isEmpty || value.length <= 2) {
      return 'Password is too short!';
    }
    return null;
  }

  @override
  State<FlutterLogin> createState() => _FlutterLoginState();
}

class _FlutterLoginState extends State<FlutterLogin>
    with TickerProviderStateMixin {
  final GlobalKey<AuthCardState> authCardKey = GlobalKey();

  static const loadingDuration = Duration(milliseconds: 400);
  double _selectTimeDilation = 1.0;

  late AnimationController _loadingController;
  late AnimationController _logoController;
  late AnimationController _titleController;

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
      if (mounted) {
        _loadingController.forward();
      }
    });
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _logoController.dispose();
    _titleController.dispose();
    super.dispose();
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
      logo: widget.logo,
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
            child: const Text('OPTIONS', style: textStyle),
          ),
          MaterialButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            color: Colors.blue,
            onPressed: () => authCardKey.currentState!.runLoadingAnimation(),
            child: const Text('LOADING', style: textStyle),
          ),
          MaterialButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            color: Colors.orange,
            onPressed: () => authCardKey.currentState!.runChangePageAnimation(),
            child: const Text('PAGE', style: textStyle),
          ),
          MaterialButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            color: Colors.red,
            onPressed: () =>
                authCardKey.currentState!.runChangeRouteAnimation(),
            child: const Text('NAV', style: textStyle),
          ),
        ],
      ),
    );
  }

  ThemeData _mergeTheme({
    required ThemeData theme,
    required LoginTheme loginTheme,
  }) {
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
    final accentColor = loginTheme.accentColor ?? theme.colorScheme.secondary;
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
    final footerStyle = theme.textTheme.bodyText1!
        .copyWith(
          color: loginTheme.accentColor ??
              (isDefaultBlackText
                  ? Colors.white
                  : theme.textTheme.headline3!.color),
        )
        .merge(loginTheme.footerTextStyle);
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

    TextStyle labelStyle;

    if (loginTheme.primaryColorAsInputLabel) {
      labelStyle = TextStyle(color: primaryColor);
    } else {
      labelStyle = TextStyle(color: blackOrWhite);
    }

    return theme.copyWith(
      primaryColor: primaryColor,
      primaryColorDark: primaryColorDark,
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
              borderSide: const BorderSide(color: Colors.transparent),
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
        disabledBorder: inputTheme.disabledBorder ??
            inputTheme.border ??
            OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.transparent),
              borderRadius: roundBorderRadius,
            ),
      ),
      floatingActionButtonTheme: theme.floatingActionButtonTheme.copyWith(
        backgroundColor: buttonTheme.backgroundColor ?? primaryColor,
        splashColor: buttonTheme.splashColor ?? theme.colorScheme.secondary,
        elevation: buttonTheme.elevation ?? 4.0,
        highlightElevation: buttonTheme.highlightElevation ?? 2.0,
        shape: buttonTheme.shape ?? const StadiumBorder(),
      ),
      // put it here because floatingActionButtonTheme doesnt have highlightColor property
      highlightColor:
          loginTheme.buttonTheme.highlightColor ?? theme.highlightColor,
      textTheme: theme.textTheme.copyWith(
        headline3: titleStyle,
        bodyText2: textStyle,
        subtitle1: textFieldStyle,
        subtitle2: footerStyle,
        button: buttonStyle,
      ),
      colorScheme:
          Theme.of(context).colorScheme.copyWith(secondary: accentColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginTheme = widget.theme ?? LoginTheme();
    final theme = _mergeTheme(theme: Theme.of(context), loginTheme: loginTheme);
    final deviceSize = MediaQuery.of(context).size;
    final headerMargin = loginTheme.headerMargin ?? 15;
    final cardInitialHeight = loginTheme.cardInitialHeight ?? 300;
    final cardTopPosition = loginTheme.cardTopPosition ??
        max(deviceSize.height / 2 - cardInitialHeight / 2, 85);
    final headerHeight = cardTopPosition - headerMargin;
    final userValidator =
        widget.userValidator ?? FlutterLogin.defaultEmailValidator;
    final validateUserImmediately = widget.validateUserImmediately ?? false;
    final passwordValidator =
        widget.passwordValidator ?? FlutterLogin.defaultPasswordValidator;

    Widget footerWidget = const SizedBox();
    if (widget.footer != null) {
      footerWidget = Padding(
        padding: EdgeInsets.only(bottom: loginTheme.footerBottomPadding),
        child: Text(
          widget.footer!,
          style: theme.textTheme.subtitle2,
          textAlign: TextAlign.center,
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: widget.messages ?? LoginMessages(),
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
            email: widget.savedEmail,
            password: widget.savedPassword,
            confirmPassword: widget.savedPassword,
            onConfirmRecover: widget.onConfirmRecover,
            onConfirmSignup: widget.onConfirmSignup,
            confirmSignupRequired: widget.confirmSignupRequired,
            beforeAdditionalFieldsCallback: widget.onSwitchToAdditionalFields,
            onResendCode: widget.onResendCode,
            termsOfService: widget.termsOfService,
            initialAuthMode: widget.initialAuthMode,
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
                        validateUserImmediately: validateUserImmediately,
                        passwordValidator: passwordValidator,
                        onSubmit: _reverseHeaderAnimation,
                        onSubmitCompleted: widget.onSubmitAnimationCompleted,
                        hideSignUpButton: widget.onSignup == null,
                        hideForgotPasswordButton:
                            widget.hideForgotPasswordButton,
                        loginAfterSignUp: widget.loginAfterSignUp,
                        hideProvidersTitle: widget.hideProvidersTitle,
                        additionalSignUpFields: widget.additionalSignupFields,
                        disableCustomPageTransformer:
                            widget.disableCustomPageTransformer,
                        loginTheme: widget.theme,
                        navigateBackAfterRecovery:
                            widget.navigateBackAfterRecovery,
                        scrollable: widget.scrollable,
                        confirmSignupKeyboardType:
                            widget.confirmSignupKeyboardType,
                        introWidget: widget.headerWidget,
                      ),
                    ),
                    Positioned(
                      top: cardTopPosition - headerHeight - headerMargin,
                      child: _buildHeader(headerHeight, loginTheme),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: footerWidget,
                      ),
                    ),
                    ...?widget.children,
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
