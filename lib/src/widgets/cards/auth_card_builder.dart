library;

import 'dart:math';

import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_login/src/utils/constants.dart';
import 'package:flutter_login/src/utils/dart_helper.dart';

import 'package:flutter_login/src/utils/matrix.dart';
import 'package:flutter_login/src/utils/text_field_utils.dart';
import 'package:flutter_login/src/utils/widget_helper.dart';
import 'package:flutter_login/src/widgets/animated_button.dart';
import 'package:flutter_login/src/widgets/animated_icon.dart';
import 'package:flutter_login/src/widgets/animated_text.dart';
import 'package:flutter_login/src/widgets/animated_text_form_field.dart';
import 'package:flutter_login/src/widgets/custom_page_transformer.dart';
import 'package:flutter_login/src/widgets/expandable_container.dart';
import 'package:flutter_login/src/widgets/fade_in.dart';
import 'package:flutter_login/src/widgets/term_of_service_checkbox.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_button/sign_in_button.dart';

part 'additional_signup_card.dart';
part 'login_card.dart';
part 'recover_card.dart';
part 'recover_confirm_card.dart';
part 'signup_confirm_card.dart';

/// The main card widget that wraps and controls all auth-related flows,
/// including login, signup, password recovery, and confirmation steps.
///
/// This widget orchestrates transitions between auth steps using animations,
/// and provides hooks and configuration for validation, theming, layout,
/// and behavior customization.
class AuthCard extends StatefulWidget {
  /// Creates an [AuthCard] that handles authentication forms and animations.
  ///
  /// Requires a [loadingController], [userType], [onSwitchAuthMode], and other
  /// configuration flags that determine which fields and flows are shown.
  const AuthCard({
    required this.userType,
    required this.loadingController,
    required this.scrollable,
    required this.confirmSignupKeyboardType,
    required this.initialIsoCode,
    required this.hideSignupPasswordFields,
    required this.onSwitchAuthMode,
    required this.autofocus,
    super.key,
    this.padding = EdgeInsets.zero,
    this.userValidator,
    this.validateUserImmediately,
    this.passwordValidator,
    this.onSubmit,
    this.onSubmitCompleted,
    this.hideForgotPasswordButton = false,
    this.hideSignUpButton = false,
    this.loginAfterSignUp = true,
    this.hideProvidersTitle = false,
    this.additionalSignUpFields,
    this.disableCustomPageTransformer = false,
    this.loginTheme,
    this.navigateBackAfterRecovery = false,
    this.introWidget,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
  });

  /// Padding around the auth card.
  final EdgeInsets padding;

  /// Animation controller used to trigger loading animations.
  final AnimationController loadingController;

  /// Validator for the user input field (email/username/etc).
  final FormFieldValidator<String>? userValidator;

  /// Whether to validate the user field immediately on blur.
  final bool? validateUserImmediately;

  /// Validator for the password input field.
  final FormFieldValidator<String>? passwordValidator;

  /// Called when the form is submitted (e.g., login/signup).
  final VoidCallback? onSubmit;

  /// Called after the submit animation completes.
  final VoidCallback? onSubmitCompleted;

  /// Whether to hide the "Forgot Password?" button.
  final bool hideForgotPasswordButton;

  /// Whether to hide the "Sign Up" button.
  final bool hideSignUpButton;

  /// Whether to login immediately after signing up.
  final bool loginAfterSignUp;

  /// Type of user input (email, phone, name, etc).
  final LoginUserType userType;

  /// Whether to hide the "or login with" title above provider buttons.
  final bool hideProvidersTitle;

  /// Additional fields to show during the signup flow.
  final List<UserFormField>? additionalSignUpFields;

  /// Whether to disable the custom page transition animation.
  final bool disableCustomPageTransformer;

  /// Optional theme override for this specific auth card.
  final LoginTheme? loginTheme;

  /// Whether to return to login screen after password recovery completes.
  final bool navigateBackAfterRecovery;

  /// Whether the auth card should be scrollable if content overflows.
  final bool scrollable;

  /// How the keyboard is dismissed (e.g., on drag or tap).
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// The keyboard type used for the confirmation code field.
  final TextInputType? confirmSignupKeyboardType;

  /// Optional widget to show above the auth card (e.g., a logo or intro).
  final Widget? introWidget;

  /// The default ISO country code used in phone fields.
  final String? initialIsoCode;

  /// Whether to hide password fields during signup (e.g., for OTP-only flows).
  final bool hideSignupPasswordFields;

  /// Called when the user switches between login and signup modes.
  final void Function(AuthMode mode) onSwitchAuthMode;

  /// Whether the user input field should autofocus.
  final bool autofocus;

  @override
  AuthCardState createState() => AuthCardState();
}

/// The internal state for [AuthCard].
///
/// Manages animation controllers and page transitions for different card states.
class AuthCardState extends State<AuthCard> with TickerProviderStateMixin {
  final GlobalKey _loginCardKey = GlobalKey();
  final GlobalKey _additionalSignUpCardKey = GlobalKey();
  final GlobalKey _confirmRecoverCardKey = GlobalKey();
  final GlobalKey _confirmSignUpCardKey = GlobalKey();

  static const int _loginPageIndex = 0;
  static const int _recoveryIndex = 1;
  static const int _additionalSignUpIndex = 2;
  static const int _confirmSignup = 3;
  static const int _confirmRecover = 4;

  int _pageIndex = _loginPageIndex;

  var _isLoadingFirstTime = true;

  /// The final scale factor for shrinking the card during animations.
  ///
  /// A value of `0.2` means the card will shrink to 20% of its original size.
  /// Used in transitions such as loading, page switching, or submission.
  static const cardSizeScaleEnd = .2;

  final TransformerPageController _pageController = TransformerPageController();
  late AnimationController _formLoadingController;
  late AnimationController _routeTransitionController;
  final _scrollController = ScrollController();

  // Card specific animations
  late Animation<double> _flipAnimation;
  late Animation<double> _cardSizeAnimation;
  late Animation<double> _cardSize2AnimationX;
  late Animation<double> _cardSize2AnimationY;
  late Animation<double> _cardRotationAnimation;
  late Animation<double> _cardOverlayHeightFactorAnimation;
  late Animation<double> _cardOverlaySizeAndOpacityAnimation;

  @override
  void initState() {
    super.initState();

    widget.loadingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isLoadingFirstTime = false;
        _formLoadingController.forward();
      }
    });

    // Set all animations
    _flipAnimation = Tween<double>(begin: pi / 2, end: 0).animate(
      CurvedAnimation(
        parent: widget.loadingController,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      ),
    );

    _formLoadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
      reverseDuration: const Duration(milliseconds: 300),
    );

    _routeTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _cardSizeAnimation = Tween<double>(begin: 1, end: cardSizeScaleEnd).animate(
      CurvedAnimation(
        parent: _routeTransitionController,
        curve: const Interval(
          0,
          .27272727 /* ~300ms */,
          curve: Curves.easeInOutCirc,
        ),
      ),
    );

    // replace 0 with minPositive to pass the test
    // https://github.com/flutter/flutter/issues/42527#issuecomment-575131275
    _cardOverlayHeightFactorAnimation =
        Tween<double>(begin: double.minPositive, end: 1).animate(
      CurvedAnimation(
        parent: _routeTransitionController,
        curve: const Interval(.27272727, .5),
      ),
    );

    _cardOverlaySizeAndOpacityAnimation =
        Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _routeTransitionController,
        curve: const Interval(.5, .72727272),
      ),
    );

    _cardSize2AnimationX =
        Tween<double>(begin: 1, end: 1).animate(_routeTransitionController);

    _cardSize2AnimationY =
        Tween<double>(begin: 1, end: 1).animate(_routeTransitionController);

    _cardRotationAnimation = Tween<double>(begin: 0, end: pi / 2).animate(
      CurvedAnimation(
        parent: _routeTransitionController,
        curve: const Interval(
          .72727272,
          1 /* ~300ms */,
          curve: Curves.easeInOutCubic,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _formLoadingController.dispose();
    _pageController.dispose();
    _routeTransitionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _changeCard(int newCardIndex) {
    Provider.of<Auth>(context, listen: false).currentCardIndex = newCardIndex;

    setState(() {
      _pageController.animateToPage(
        newCardIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
      _pageIndex = newCardIndex;
    });
  }

  /// Triggers the loading animation sequence for the auth card.
  ///
  /// If the loadingController is dismissed (i.e., not yet started), it plays
  /// forward. After that, it may trigger an additional form animation on first load.
  ///
  /// If the loadingController is already completed, it reverses both the
  /// form animation and the main loading animation.
  ///
  /// Returns a [Future] that completes when all triggered animations finish,
  /// or `null` if no animation was run.
  Future<void>? runLoadingAnimation() {
    if (widget.loadingController.isDismissed) {
      return widget.loadingController.forward().then((_) {
        if (!_isLoadingFirstTime) {
          _formLoadingController.forward();
        }
      });
    } else if (widget.loadingController.isCompleted) {
      return _formLoadingController
          .reverse()
          .then((_) => widget.loadingController.reverse());
    }
    return null;
  }

  Future<void> _forwardChangeRouteAnimation(GlobalKey cardKey) {
    final deviceSize = MediaQuery.of(context).size;

    // Get card size, or use default size so that the animation wont crash.
    final cardSize = getWidgetSize(cardKey) ?? const Size(370, 580);

    // Add a null check for cardSize
    final widthRatio = deviceSize.width / cardSize.height + 2;
    final heightRatio = deviceSize.height / cardSize.width + .25;

    _cardSize2AnimationX =
        Tween<double>(begin: 1, end: heightRatio / cardSizeScaleEnd).animate(
      CurvedAnimation(
        parent: _routeTransitionController,
        curve: const Interval(.72727272, 1, curve: Curves.easeInOutCubic),
      ),
    );
    _cardSize2AnimationY =
        Tween<double>(begin: 1, end: widthRatio / cardSizeScaleEnd).animate(
      CurvedAnimation(
        parent: _routeTransitionController,
        curve: const Interval(.72727272, 1, curve: Curves.easeInOutCubic),
      ),
    );

    widget.onSubmit?.call();

    return _formLoadingController
        .reverse()
        .then((_) => _routeTransitionController.forward());
  }

  void _reverseChangeRouteAnimation() {
    _routeTransitionController
        .reverse()
        .then((_) => _formLoadingController.forward());
  }

  /// Runs the route transition animation to visually switch between screens.
  ///
  /// If the route transition animation has already completed, it will reverse
  /// the animation. Otherwise, it starts the forward animation using the login card.
  void runChangeRouteAnimation() {
    if (_routeTransitionController.isCompleted) {
      _reverseChangeRouteAnimation();
    } else if (_routeTransitionController.isDismissed) {
      _forwardChangeRouteAnimation(_loginCardKey);
    }
  }

  /// Advances the visible auth card (e.g., from login to signup to recovery).
  ///
  /// Cycles through the available cards by incrementing [Auth.currentCardIndex].
  /// Resets to the first card if the end of the sequence is reached.
  void runChangePageAnimation() {
    final auth = Provider.of<Auth>(context, listen: false);
    if (auth.currentCardIndex >= 2) {
      _changeCard(0);
    } else {
      _changeCard(auth.currentCardIndex + 1);
    }
  }

  Widget _buildLoadingAnimator({required ThemeData theme, Widget? child}) {
    Widget card;
    Widget overlay;

    // loading at startup
    card = AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) => Transform(
        transform: perspective()..rotateX(_flipAnimation.value),
        alignment: Alignment.center,
        child: child,
      ),
      child: child,
    );

    // change-route transition
    overlay = Padding(
      padding: theme.cardTheme.margin!,
      child: AnimatedBuilder(
        animation: _cardOverlayHeightFactorAnimation,
        builder: (context, child) => ClipPath.shape(
          shape: theme.cardTheme.shape!,
          child: FractionallySizedBox(
            heightFactor: _cardOverlayHeightFactorAnimation.value,
            alignment: Alignment.topCenter,
            child: child,
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(color: theme.colorScheme.secondary),
        ),
      ),
    );

    overlay = ScaleTransition(
      scale: _cardOverlaySizeAndOpacityAnimation,
      child: FadeTransition(
        opacity: _cardOverlaySizeAndOpacityAnimation,
        child: overlay,
      ),
    );

    return Stack(
      children: <Widget>[
        card,
        Positioned.fill(child: overlay),
      ],
    );
  }

  Widget _changeToCard(BuildContext context, int index) {
    final auth = Provider.of<Auth>(context, listen: false);
    final formController = _formLoadingController;
    // if (!_isLoadingFirstTime) formController = _formLoadingController..value = 1.0;
    Future<bool> requireSignUpConfirmation() async {
      final confirmSignupRequired = await auth.confirmSignupRequired?.call(
            LoginData(
              name: auth.email,
              password: auth.password,
            ),
          ) ??
          true;
      return auth.onConfirmSignup != null && confirmSignupRequired;
    }

    switch (index) {
      case _loginPageIndex:
        return _buildLoadingAnimator(
          theme: Theme.of(context),
          child: _LoginCard(
            key: _loginCardKey,
            userType: widget.userType,
            loadingController: formController,
            userValidator: widget.userValidator,
            validateUserImmediately: widget.validateUserImmediately,
            passwordValidator: widget.passwordValidator,
            requireAdditionalSignUpFields:
                widget.additionalSignUpFields != null,
            onSwitchRecoveryPassword: () => _changeCard(_recoveryIndex),
            onSwitchSignUpAdditionalData: () =>
                _changeCard(_additionalSignUpIndex),
            onSubmitCompleted: () {
              _forwardChangeRouteAnimation(_loginCardKey).then((_) {
                widget.onSubmitCompleted?.call();
              });
            },
            requireSignUpConfirmation: requireSignUpConfirmation,
            onSwitchConfirmSignup: () => _changeCard(_confirmSignup),
            hideSignUpButton: widget.hideSignUpButton,
            hideForgotPasswordButton: widget.hideForgotPasswordButton,
            loginAfterSignUp: widget.loginAfterSignUp,
            hideProvidersTitle: widget.hideProvidersTitle,
            introWidget: widget.introWidget,
            initialIsoCode: widget.initialIsoCode,
            hideSignupPasswordFields: widget.hideSignupPasswordFields,
            onSwitchAuthMode: widget.onSwitchAuthMode,
            autofocus: widget.autofocus,
          ),
        );
      case _recoveryIndex:
        return _RecoverCard(
          userValidator: widget.userValidator,
          userType: widget.userType,
          loginTheme: widget.loginTheme,
          loadingController: formController,
          navigateBack: widget.navigateBackAfterRecovery,
          onBack: () => _changeCard(_loginPageIndex),
          onSubmitCompleted: () {
            if (auth.onConfirmRecover != null) {
              _changeCard(_confirmRecover);
            } else {
              _changeCard(_loginPageIndex);
            }
          },
          initialIsoCode: widget.initialIsoCode,
          autofocusName: widget.autofocus,
        );

      case _additionalSignUpIndex:
        if (widget.additionalSignUpFields == null) {
          return const SizedBox.shrink();
          // throw StateError('The additional fields List is null');
        }
        return _buildLoadingAnimator(
          theme: Theme.of(context),
          child: _AdditionalSignUpCard(
            key: _additionalSignUpCardKey,
            formFields: widget.additionalSignUpFields!,
            loadingController: formController,
            onBack: () => _changeCard(_loginPageIndex),
            loginTheme: widget.loginTheme,
            onSubmitCompleted: () async {
              final requireSignupConfirmation =
                  await requireSignUpConfirmation();
              if (requireSignupConfirmation) {
                _changeCard(_confirmSignup);
              } else if (widget.loginAfterSignUp) {
                await _forwardChangeRouteAnimation(_additionalSignUpCardKey)
                    .then((_) {
                  widget.onSubmitCompleted?.call();
                });
              } else {
                _changeCard(_loginPageIndex);
              }
            },
            initialIsoCode: widget.initialIsoCode,
          ),
        );

      case _confirmRecover:
        return _ConfirmRecoverCard(
          key: _confirmRecoverCardKey,
          passwordValidator: widget.passwordValidator!,
          onBack: () => _changeCard(_loginPageIndex),
          onSubmitCompleted: () => _changeCard(_loginPageIndex),
          initialIsoCode: widget.initialIsoCode,
        );

      case _confirmSignup:
        return _buildLoadingAnimator(
          theme: Theme.of(context),
          child: _ConfirmSignupCard(
            key: _confirmSignUpCardKey,
            onBack: () => auth.additionalSignupData == null
                ? _changeCard(_loginPageIndex)
                : _changeCard(_additionalSignUpIndex),
            loadingController: formController,
            onSubmitCompleted: () {
              if (widget.loginAfterSignUp) {
                _forwardChangeRouteAnimation(_confirmSignUpCardKey).then((_) {
                  widget.onSubmitCompleted?.call();
                });
              } else {
                _changeCard(_loginPageIndex);
              }
            },
            loginAfterSignUp: widget.loginAfterSignUp,
            keyboardType: widget.confirmSignupKeyboardType,
            initialIsoCode: widget.initialIsoCode,
          ),
        );
    }
    throw IndexError.withLength(index, 5);
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    final Widget current = Container(
      height: deviceSize.height,
      width: deviceSize.width,
      padding: widget.padding,
      child: TransformerPageView(
        physics: const NeverScrollableScrollPhysics(),
        pageController: _pageController,
        itemCount: 5,

        /// Need to keep track of page index because soft keyboard will
        /// make page view rebuilt
        index: _pageIndex,
        transformer: widget.disableCustomPageTransformer
            ? null
            : CustomPageTransformer(),
        itemBuilder: (BuildContext context, int index) {
          if (widget.scrollable) {
            return Align(
              alignment: Alignment.topCenter,
              child: Scrollbar(
                controller: _scrollController,
                child: SingleChildScrollView(
                  keyboardDismissBehavior: widget.keyboardDismissBehavior,
                  controller: _scrollController,
                  child: _changeToCard(context, index),
                ),
              ),
            );
          } else {
            return Align(
              alignment: Alignment.topCenter,
              child: _changeToCard(context, index),
            );
          }
        },
      ),
    );

    return AnimatedBuilder(
      animation: _cardSize2AnimationX,
      builder: (context, snapshot) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateZ(_cardRotationAnimation.value)
            ..scale(_cardSizeAnimation.value, _cardSizeAnimation.value)
            ..scale(_cardSize2AnimationX.value, _cardSize2AnimationY.value),
          child: current,
        );
      },
    );
  }
}
