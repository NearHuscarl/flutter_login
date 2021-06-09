library auth_card;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:another_transformer_page_view/another_transformer_page_view.dart';

import 'package:flutter_login/src/models/login_data.dart';
import 'package:flutter_login/src/models/login_user_type.dart';
import 'package:flutter_login/src/providers/auth.dart';
import 'package:flutter_login/src/providers/login_messages.dart';
import 'package:flutter_login/src/providers/login_theme.dart';
import 'package:flutter_login/src/utils/text_field_utils.dart';
import 'package:flutter_login/src/constants.dart';
import 'package:flutter_login/src/dart_helper.dart';
import 'package:flutter_login/src/matrix.dart';
import 'package:flutter_login/src/paddings.dart';
import 'package:flutter_login/src/widget_helper.dart';

import 'animated_button.dart';
import 'animated_icon.dart';
import 'animated_text.dart';
import 'animated_text_form_field.dart';
import 'custom_page_transformer.dart';
import 'expandable_container.dart';
import 'fade_in.dart';

part 'login_card.dart';
part 'recover_card.dart';

class AuthCard extends StatefulWidget {
  AuthCard({
    Key? key,
    required this.userType,
    this.padding = const EdgeInsets.all(0),
    this.loadingController,
    this.userValidator,
    this.passwordValidator,
    this.onSubmit,
    this.onSubmitCompleted,
    this.hideForgotPasswordButton = false,
    this.hideSignUpButton = false,
    this.loginAfterSignUp = true,
    this.hideProvidersTitle = false,
  }) : super(key: key);

  final EdgeInsets padding;
  final AnimationController? loadingController;
  final FormFieldValidator<String>? userValidator;
  final FormFieldValidator<String>? passwordValidator;
  final Function? onSubmit;
  final Function? onSubmitCompleted;
  final bool hideForgotPasswordButton;
  final bool hideSignUpButton;
  final bool loginAfterSignUp;
  final LoginUserType userType;
  final bool hideProvidersTitle;

  @override
  AuthCardState createState() => AuthCardState();
}

class AuthCardState extends State<AuthCard> with TickerProviderStateMixin {
  final GlobalKey _cardKey = GlobalKey();

  var _isLoadingFirstTime = true;
  var _pageIndex = 0;
  static const cardSizeScaleEnd = .2;

  TransformerPageController? _pageController;
  late AnimationController _formLoadingController;
  late AnimationController _routeTransitionController;
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

    _pageController = TransformerPageController();

    widget.loadingController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isLoadingFirstTime = false;
        _formLoadingController.forward();
      }
    });

    _flipAnimation = Tween<double>(begin: pi / 2, end: 0).animate(
      CurvedAnimation(
        parent: widget.loadingController!,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      ),
    );

    _formLoadingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1150),
      reverseDuration: Duration(milliseconds: 300),
    );

    _routeTransitionController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1100),
    );

    _cardSizeAnimation = Tween<double>(begin: 1.0, end: cardSizeScaleEnd)
        .animate(CurvedAnimation(
      parent: _routeTransitionController,
      curve: Interval(0, .27272727 /* ~300ms */, curve: Curves.easeInOutCirc),
    ));
    // replace 0 with minPositive to pass the test
    // https://github.com/flutter/flutter/issues/42527#issuecomment-575131275
    _cardOverlayHeightFactorAnimation =
        Tween<double>(begin: double.minPositive, end: 1.0)
            .animate(CurvedAnimation(
      parent: _routeTransitionController,
      curve: Interval(.27272727, .5 /* ~250ms */, curve: Curves.linear),
    ));
    _cardOverlaySizeAndOpacityAnimation =
        Tween<double>(begin: 1.0, end: 0).animate(CurvedAnimation(
      parent: _routeTransitionController,
      curve: Interval(.5, .72727272 /* ~250ms */, curve: Curves.linear),
    ));
    _cardSize2AnimationX =
        Tween<double>(begin: 1, end: 1).animate(_routeTransitionController);
    _cardSize2AnimationY =
        Tween<double>(begin: 1, end: 1).animate(_routeTransitionController);
    _cardRotationAnimation =
        Tween<double>(begin: 0, end: pi / 2).animate(CurvedAnimation(
      parent: _routeTransitionController,
      curve: Interval(.72727272, 1 /* ~300ms */, curve: Curves.easeInOutCubic),
    ));
  }

  @override
  void dispose() {
    _formLoadingController.dispose();
    _pageController!.dispose();
    _routeTransitionController.dispose();
    super.dispose();
  }

  void _switchRecovery(bool recovery) {
    final auth = Provider.of<Auth>(context, listen: false);

    auth.isRecover = recovery;
    if (recovery) {
      _pageController!.nextPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
      _pageIndex = 1;
    } else {
      _pageController!.previousPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
      _pageIndex = 0;
    }
  }

  Future<void>? runLoadingAnimation() {
    if (widget.loadingController!.isDismissed) {
      return widget.loadingController!.forward().then((_) {
        if (!_isLoadingFirstTime) {
          _formLoadingController.forward();
        }
      });
    } else if (widget.loadingController!.isCompleted) {
      return _formLoadingController
          .reverse()
          .then((_) => widget.loadingController!.reverse());
    }
    return null;
  }

  Future<void> _forwardChangeRouteAnimation() {
    final isLogin = Provider.of<Auth>(context, listen: false).isLogin;
    final deviceSize = MediaQuery.of(context).size;
    final cardSize = getWidgetSize(_cardKey)!;
    // add .25 to make sure the scaling will cover the whole screen
    final widthRatio =
        deviceSize.width / cardSize.height + (isLogin ? .25 : .65);
    final heightRatio = deviceSize.height / cardSize.width + .25;

    _cardSize2AnimationX =
        Tween<double>(begin: 1.0, end: heightRatio / cardSizeScaleEnd)
            .animate(CurvedAnimation(
      parent: _routeTransitionController,
      curve: Interval(.72727272, 1, curve: Curves.easeInOutCubic),
    ));
    _cardSize2AnimationY =
        Tween<double>(begin: 1.0, end: widthRatio / cardSizeScaleEnd)
            .animate(CurvedAnimation(
      parent: _routeTransitionController,
      curve: Interval(.72727272, 1, curve: Curves.easeInOutCubic),
    ));

    widget.onSubmit!();

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
      _forwardChangeRouteAnimation();
    }
  }

  void runChangePageAnimation() {
    final auth = Provider.of<Auth>(context, listen: false);
    _switchRecovery(!auth.isRecover);
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
          decoration: BoxDecoration(color: theme.accentColor),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceSize = MediaQuery.of(context).size;
    Widget current = Container(
      height: deviceSize.height,
      width: deviceSize.width,
      padding: widget.padding,
      child: TransformerPageView(
        physics: NeverScrollableScrollPhysics(),
        pageController: _pageController,
        itemCount: 2,

        /// Need to keep track of page index because soft keyboard will
        /// make page view rebuilt
        index: _pageIndex,
        transformer: CustomPageTransformer(),
        itemBuilder: (BuildContext context, int index) {
          final child = (index == 0)
              ? _buildLoadingAnimator(
                  theme: theme,
                  child: _LoginCard(
                    key: _cardKey,
                    userType: widget.userType,
                    loadingController: _isLoadingFirstTime
                        ? _formLoadingController
                        : (_formLoadingController..value = 1.0),
                    userValidator: widget.userValidator,
                    passwordValidator: widget.passwordValidator,
                    onSwitchRecoveryPassword: () => _switchRecovery(true),
                    onSubmitCompleted: () {
                      _forwardChangeRouteAnimation().then((_) {
                        widget.onSubmitCompleted!();
                      });
                    },
                    hideSignUpButton: widget.hideSignUpButton,
                    hideForgotPasswordButton: widget.hideForgotPasswordButton,
                    loginAfterSignUp: widget.loginAfterSignUp,
                    hideProvidersTitle: widget.hideProvidersTitle,
                  ),
                )
              : _RecoverCard(
                  userValidator: widget.userValidator,
                  userType: widget.userType,
                  onSwitchLogin: () => _switchRecovery(false),
                );

          return Align(
            alignment: Alignment.topCenter,
            child: child,
          );
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
