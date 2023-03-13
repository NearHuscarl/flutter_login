library auth_card_builder;

import 'dart:math';

import 'package:another_transformer_page_view/another_transformer_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_login/src/constants.dart';
import 'package:flutter_login/src/dart_helper.dart';
import 'package:flutter_login/src/matrix.dart';
import 'package:flutter_login/src/paddings.dart';
import 'package:flutter_login/src/utils/text_field_utils.dart';
import 'package:flutter_login/src/widget_helper.dart';
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

class AuthCard extends StatefulWidget {
  const AuthCard({
    super.key,
    required this.userType,
    this.padding = EdgeInsets.zero,
    required this.loadingController,
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
    required this.scrollable,
    required this.confirmSignupKeyboardType,
    this.introWidget,
  });

  final EdgeInsets padding;
  final AnimationController loadingController;
  final FormFieldValidator<String>? userValidator;
  final bool? validateUserImmediately;
  final FormFieldValidator<String>? passwordValidator;
  final VoidCallback? onSubmit;
  final VoidCallback? onSubmitCompleted;
  final bool hideForgotPasswordButton;
  final bool hideSignUpButton;
  final bool loginAfterSignUp;
  final LoginUserType userType;
  final bool hideProvidersTitle;

  final List<UserFormField>? additionalSignUpFields;

  final bool disableCustomPageTransformer;
  final LoginTheme? loginTheme;
  final bool navigateBackAfterRecovery;

  final bool scrollable;
  final TextInputType? confirmSignupKeyboardType;
  final Widget? introWidget;

  @override
  AuthCardState createState() => AuthCardState();
}

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
  static const cardSizeScaleEnd = .2;

  final TransformerPageController _pageController = TransformerPageController();
  late AnimationController _formLoadingController;
  late AnimationController _routeTransitionController;

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

    _cardSizeAnimation =
        Tween<double>(begin: 1.0, end: cardSizeScaleEnd).animate(
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
        Tween<double>(begin: double.minPositive, end: 1.0).animate(
      CurvedAnimation(
        parent: _routeTransitionController,
        curve: const Interval(.27272727, .5),
      ),
    );

    _cardOverlaySizeAndOpacityAnimation =
        Tween<double>(begin: 1.0, end: 0).animate(
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
    super.dispose();
  }

  void _changeCard(int newCardIndex) {
    final auth = Provider.of<Auth>(context, listen: false);

    auth.currentCardIndex = newCardIndex;

    setState(() {
      _pageController.animateToPage(
        newCardIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
      _pageIndex = newCardIndex;
    });
  }

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
    final cardSize = getWidgetSize(cardKey)!;
    final widthRatio = deviceSize.width / cardSize.height + 2;
    final heightRatio = deviceSize.height / cardSize.width + .25;

    _cardSize2AnimationX =
        Tween<double>(begin: 1.0, end: heightRatio / cardSizeScaleEnd).animate(
      CurvedAnimation(
        parent: _routeTransitionController,
        curve: const Interval(.72727272, 1, curve: Curves.easeInOutCubic),
      ),
    );
    _cardSize2AnimationY =
        Tween<double>(begin: 1.0, end: widthRatio / cardSizeScaleEnd).animate(
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

  void runChangeRouteAnimation() {
    if (_routeTransitionController.isCompleted) {
      _reverseChangeRouteAnimation();
    } else if (_routeTransitionController.isDismissed) {
      _forwardChangeRouteAnimation(_loginCardKey);
    }
  }

  void runChangePageAnimation() {
    final auth = Provider.of<Auth>(context, listen: false);
    if (auth.currentCardIndex >= 2) {
      _changeCard(0);
    } else {
      _changeCard(auth.currentCardIndex + 1);
    }
  }

  Widget _buildLoadingAnimator({Widget? child, required ThemeData theme}) {
    Widget card;
    Widget overlay;

    // loading at startup
    card = AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) => Transform(
        transform: Matrix.perspective()..rotateX(_flipAnimation.value),
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
                widget.onSubmitCompleted!();
              });
            },
            requireSignUpConfirmation: auth.onConfirmSignup != null,
            onSwitchConfirmSignup: () => _changeCard(_confirmSignup),
            hideSignUpButton: widget.hideSignUpButton,
            hideForgotPasswordButton: widget.hideForgotPasswordButton,
            loginAfterSignUp: widget.loginAfterSignUp,
            hideProvidersTitle: widget.hideProvidersTitle,
            introWidget: widget.introWidget,
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
            onSubmitCompleted: () {
              if (auth.onConfirmSignup != null) {
                _changeCard(_confirmSignup);
              } else if (widget.loginAfterSignUp) {
                _forwardChangeRouteAnimation(_additionalSignUpCardKey)
                    .then((_) {
                  widget.onSubmitCompleted!();
                });
              } else {
                _changeCard(_loginPageIndex);
              }
            },
          ),
        );

      case _confirmRecover:
        return _ConfirmRecoverCard(
          key: _confirmRecoverCardKey,
          passwordValidator: widget.passwordValidator!,
          onBack: () => _changeCard(_loginPageIndex),
          onSubmitCompleted: () => _changeCard(_loginPageIndex),
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
                  widget.onSubmitCompleted!();
                });
              } else {
                _changeCard(_loginPageIndex);
              }
            },
            loginAfterSignUp: widget.loginAfterSignUp,
            keyboardType: widget.confirmSignupKeyboardType,
          ),
        );
    }
    throw IndexError(index, 5);
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
                child: SingleChildScrollView(
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
