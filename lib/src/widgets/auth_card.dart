import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:transformer_page_view/transformer_page_view.dart';
import 'animated_button.dart';
import 'animated_text.dart';
import 'custom_page_transformer.dart';
import 'expandable_container.dart';
import 'fade_in.dart';
import 'animated_text_form_field.dart';
import '../providers/auth.dart';
import '../models/login_data.dart';
import '../matrix.dart';
import '../paddings.dart';
import '../widget_helper.dart';

class AuthCard extends StatefulWidget {
  AuthCard({
    Key key,
    this.padding = const EdgeInsets.all(0),
    this.loadingController,
    this.emailValidator,
    this.passwordValidator,
    this.onSubmit,
    this.onSubmitCompleted,
  }) : super(key: key);

  final EdgeInsets padding;
  final AnimationController loadingController;
  final FormFieldValidator<String> emailValidator;
  final FormFieldValidator<String> passwordValidator;
  final Function onSubmit;
  final Function onSubmitCompleted;

  @override
  AuthCardState createState() => AuthCardState();
}

class AuthCardState extends State<AuthCard> with TickerProviderStateMixin {
  GlobalKey _cardKey = GlobalKey();

  var _isLoadingFirstTime = true;
  static const cardSizeScaleEnd = .2;

  TransformerPageController _pageController;
  AnimationController _formLoadingController;
  AnimationController _routeTransitionController;
  Animation<double> _flipAnimation;
  Animation<double> _cardSizeAnimation;
  Animation<double> _cardSize2Animation;
  Animation<double> _cardOverlayHeightFactorAnimation;
  Animation<double> _cardOverlaySizeAndOpacityAnimation;

  @override
  void initState() {
    super.initState();

    _pageController = TransformerPageController();

    widget.loadingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isLoadingFirstTime = false;
        _formLoadingController.forward();
      }
    });

    _formLoadingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1150),
      reverseDuration: Duration(milliseconds: 300),
    );

    _routeTransitionController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    _flipAnimation = Tween<double>(begin: pi / 2, end: 0).animate(
      CurvedAnimation(
        parent: widget.loadingController,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      ),
    );
    _cardSizeAnimation = Tween<double>(begin: 1.0, end: cardSizeScaleEnd)
        .animate(CurvedAnimation(
      parent: _routeTransitionController,
      curve: Interval(0, .25, curve: Curves.easeOut),
    ));
    _cardOverlayHeightFactorAnimation =
        Tween<double>(begin: 0, end: 1.0).animate(CurvedAnimation(
      parent: _routeTransitionController,
      curve: Interval(.25, .5, curve: Curves.easeIn),
    ));
    _cardOverlaySizeAndOpacityAnimation =
        Tween<double>(begin: 1.0, end: 0).animate(CurvedAnimation(
      parent: _routeTransitionController,
      curve: Interval(.5, .75, curve: Curves.easeIn),
    ));
    _cardSize2Animation =
        Tween<double>(begin: 1.0, end: 50.0).animate(CurvedAnimation(
      parent: _routeTransitionController,
      curve: Interval(.75, 1, curve: Curves.easeIn),
    ));
  }

  @override
  void dispose() {
    super.dispose();

    _formLoadingController.dispose();
    _pageController.dispose();
    _routeTransitionController.dispose();
  }

  void _switchRecovery(bool recovery) {
    final auth = Provider.of<Auth>(context, listen: false);

    auth.isRecover = recovery;
    if (recovery) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    } else {
      _pageController.previousPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    }
  }

  Future<void> runLoadingAnimation() {
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
    return Future(null);
  }

  Future<void> _forwardChangeRouteAnimation(Size deviceSize) {
    final cardSize = getWidgetSize(_cardKey);
    final widthRatio = deviceSize.width / cardSize.width;
    final heightRatio = deviceSize.height / cardSize.height;
    // add .2 to make sure the scaling will cover the whole screen
    final scale = max(widthRatio, heightRatio) + 0.2;

    _cardSize2Animation =
        Tween<double>(begin: 1.0, end: scale / cardSizeScaleEnd)
            .animate(CurvedAnimation(
      parent: _routeTransitionController,
      curve: Interval(.75, 1, curve: Curves.easeIn),
    ));

    widget?.onSubmit();

    return _formLoadingController
        .reverse()
        .then((_) => _routeTransitionController.forward());
  }

  void _reverseChangeRouteAnimation() {
    _routeTransitionController
        .reverse()
        .then((_) => _formLoadingController.forward());
  }

  void runChangeRouteAnimation(Size deviceSize) {
    if (_routeTransitionController.isCompleted) {
      _reverseChangeRouteAnimation();
    } else if (_routeTransitionController.isDismissed) {
      _forwardChangeRouteAnimation(deviceSize);
    }
  }

  void runChangePageAnimation() {
    final auth = Provider.of<Auth>(context, listen: false);
    _switchRecovery(!auth.isRecover);
  }

  Widget _buildLoadingAnimator({Widget child, ThemeData theme}) {
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
    overlay = AnimatedBuilder(
      animation: _cardOverlayHeightFactorAnimation,
      builder: (context, child) => ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: FractionallySizedBox(
          heightFactor: _cardOverlayHeightFactorAnimation.value,
          alignment: Alignment.topCenter,
          child: child,
        ),
      ),
      child: Container(
        color: theme.accentColor,
      ),
    );

    overlay = AnimatedBuilder(
      animation: _cardOverlayHeightFactorAnimation,
      builder: (context, child) => Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..scale(
            _cardOverlaySizeAndOpacityAnimation.value,
            _cardOverlaySizeAndOpacityAnimation.value,
          ),
        child: child,
      ),
      child: FadeTransition(
        opacity: _cardOverlaySizeAndOpacityAnimation,
        child: overlay,
      ),
    );

    return Stack(
      children: <Widget>[
        card,
        Positioned(
          // the _LoginCard is a Card widget which is smaller than normal Container
          // because it has to reserve some spaces for card shadow
          left: 4, top: 4, bottom: 4, right: 4,
          child: overlay,
        ),
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
        transformer: CustomPageTransformer(),
        itemBuilder: (BuildContext context, int index) {
          final child = (index == 0)
              ? _buildLoadingAnimator(
                  theme: theme,
                  child: _LoginCard(
                    key: _cardKey,
                    loadingController: _isLoadingFirstTime
                        ? _formLoadingController
                        : (_formLoadingController..value = 1.0),
                    emailValidator: widget.emailValidator,
                    passwordValidator: widget.passwordValidator,
                    onSwitchRecoveryPassword: () => _switchRecovery(true),
                    onSubmitCompleted: () {
                      _forwardChangeRouteAnimation(deviceSize).then((_) {
                        widget.onSubmitCompleted();
                      });
                    },
                  ),
                )
              : _RecoverCard(
                  emailValidator: widget.emailValidator,
                  onSwitchLogin: () => _switchRecovery(false),
                );

          return Column(
            children: <Widget>[child],
          );
        },
      ),
    );

    current = AnimatedBuilder(
      animation: _cardSizeAnimation,
      builder: (context, child) => Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..scale(
            _cardSizeAnimation.value,
            _cardSizeAnimation.value,
          ),
        child: child,
      ),
      child: current,
    );

    return AnimatedBuilder(
      animation: _cardSize2Animation,
      builder: (context, child) => Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..scale(
            _cardSize2Animation.value,
            _cardSize2Animation.value,
          ),
        child: child,
      ),
      child: current,
    );
  }
}

class _LoginCard extends StatefulWidget {
  _LoginCard({
    Key key,
    this.loadingController,
    @required this.emailValidator,
    @required this.passwordValidator,
    @required this.onSwitchRecoveryPassword,
    this.onSwitchAuth,
    this.onSubmitCompleted,
  }) : super(key: key);

  final AnimationController loadingController;
  final FormFieldValidator<String> emailValidator;
  final FormFieldValidator<String> passwordValidator;
  final Function onSwitchRecoveryPassword;
  final Function onSwitchAuth;
  final Function onSubmitCompleted;

  @override
  _LoginCardState createState() => _LoginCardState();
}

class _LoginCardState extends State<_LoginCard> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _passwordController = TextEditingController();

  var _obscurePasswordText = true;
  var _obscureConfirmPasswordText = true;

  var _authData = {'email': '', 'password': ''};
  var _isLoading = false;
  var _isSubmitting = false;

  /// switch between login and signup
  AnimationController _switchAuthController;
  AnimationController _postSwitchAuthController;
  AnimationController _submitController;

  Interval _nameTextFieldLoadingAnimationInterval;
  Interval _passTextFieldLoadingAnimationInterval;
  Interval _forgotPasswordLoadingAnimationInterval;
  Interval _switchAuthLoadingAnimationInterval;
  Animation<double> _buttonScaleAnimation;

  bool get buttonEnabled => !_isLoading && !_isSubmitting;

  @override
  void initState() {
    super.initState();

    widget.loadingController
        ?.addStatusListener(onLoadingAnimationStatusChanged);

    _switchAuthController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _postSwitchAuthController.forward();
        }
      });
    _postSwitchAuthController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
    );
    _submitController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    _nameTextFieldLoadingAnimationInterval = const Interval(0, .85);
    _passTextFieldLoadingAnimationInterval = const Interval(.15, 1.0);
    _forgotPasswordLoadingAnimationInterval =
        const Interval(.6, 1.0, curve: Curves.easeOut);
    _switchAuthLoadingAnimationInterval =
        const Interval(.6, 1.0, curve: Curves.easeOut);
    _buttonScaleAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: widget.loadingController,
      curve: Interval(.4, 1.0, curve: Curves.easeOutBack),
    ));
  }

  void onLoadingAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.forward) {
      setState(() => _isLoading = true);
    }
    if (status == AnimationStatus.completed) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    super.dispose();

    widget.loadingController
        ?.removeStatusListener(onLoadingAnimationStatusChanged);
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    _switchAuthController.dispose();
    _postSwitchAuthController.dispose();
    _submitController.dispose();
  }

  String _getLabel(AuthMode authMode) {
    switch (authMode) {
      case AuthMode.Signup:
        return 'SIGNUP';
      case AuthMode.Login:
        return 'LOGIN';
      default:
        return '';
    }
  }

  void _switchAuthMode() {
    final auth = Provider.of<Auth>(context, listen: false);
    final newAuthMode = auth.switchAuth();

    if (newAuthMode == AuthMode.Signup) {
      _switchAuthController.forward();
    } else {
      _switchAuthController.reverse();
    }
  }

  Future<bool> _submit() async {
    if (!_formKey.currentState.validate()) {
      return false;
    }

    _formKey.currentState.save();
    _submitController.forward();
    setState(() => _isSubmitting = true);
    final auth = Provider.of<Auth>(context, listen: false);

    if (auth.isLogin) {
      await auth.onLogin(LoginData(
        name: _authData['email'],
        password: _authData['password'],
      ));
    } else {
      await auth.onSignup(LoginData(
        name: _authData['email'],
        password: _authData['password'],
      ));
    }

    setState(() => _isSubmitting = false);
    _submitController.reverse();
    widget?.onSubmitCompleted();

    return true;
  }

  Widget _buildNameField(double width) {
    return AnimatedTextFormField(
      animatedWidth: width,
      loadingController: widget.loadingController,
      interval: _nameTextFieldLoadingAnimationInterval,
      labelText: 'Email',
      prefixIcon: Icon(FontAwesomeIcons.solidUserCircle),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(_passwordFocusNode);
      },
      validator: widget.emailValidator,
      onSaved: (value) => _authData['email'] = value,
    );
  }

  Widget _buildPasswordField(double width) {
    final auth = Provider.of<Auth>(context);

    return AnimatedTextFormField(
      animatedWidth: width,
      loadingController: widget.loadingController,
      interval: _passTextFieldLoadingAnimationInterval,
      labelText: 'Password',
      prefixIcon: Icon(FontAwesomeIcons.lock, size: 20),
      suffixIcon: IconButton(
        icon: Icon(Icons.remove_red_eye),
        onPressed: () =>
            setState(() => _obscurePasswordText = !_obscurePasswordText),
      ),
      obscureText: _obscurePasswordText,
      controller: _passwordController,
      textInputAction:
          auth.isLogin ? TextInputAction.done : TextInputAction.next,
      focusNode: _passwordFocusNode,
      onFieldSubmitted: (value) {
        if (auth.isLogin) {
          _submit();
        } else {
          // SignUp
          FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
        }
      },
      validator: widget.passwordValidator,
      onSaved: (value) => _authData['password'] = value,
    );
  }

  Widget _buildConfirmPasswordField(double width) {
    final auth = Provider.of<Auth>(context);

    return AnimatedTextFormField(
      animatedWidth: width,
      enabled: auth.isSignup,
      loadingController: widget.loadingController,
      inertiaController: _postSwitchAuthController,
      dragDirection: DragDirection.right,
      labelText: 'Confirm Password',
      prefixIcon: Icon(FontAwesomeIcons.lock, size: 20),
      suffixIcon: IconButton(
        icon: Icon(Icons.remove_red_eye),
        onPressed: () => setState(
            () => _obscureConfirmPasswordText = !_obscureConfirmPasswordText),
      ),
      obscureText: _obscureConfirmPasswordText,
      textInputAction: TextInputAction.done,
      focusNode: _confirmPasswordFocusNode,
      onFieldSubmitted: (value) => _submit(),
      validator: auth.isSignup
          ? (value) {
              if (value != _passwordController.text) {
                return 'Passwords do not match!';
              }
              return null;
            }
          : (value) => null,
    );
  }

  Widget _buildForgotPassword(ThemeData theme) {
    return FadeIn(
      controller: widget.loadingController,
      fadeDirection: FadeDirection.bottomToTop,
      offset: .5,
      curve: _forgotPasswordLoadingAnimationInterval,
      child: FlatButton(
        child: Text(
          'Forgot Password?',
          style: theme.textTheme.body1,
          textAlign: TextAlign.left,
        ),
        onPressed: buttonEnabled ? widget.onSwitchRecoveryPassword : null,
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    final auth = Provider.of<Auth>(context);

    return ScaleTransition(
      scale: _buttonScaleAnimation,
      child: AnimatedButton(
        controller: _submitController,
        color: theme.primaryColor,
        loadingColor: theme.accentColor,
        text: _getLabel(auth.mode),
        onPressed: _submit,
      ),
    );
  }

  Widget _buildSwitchAuthButton(ThemeData theme) {
    final auth = Provider.of<Auth>(context, listen: false);

    return FadeIn(
      controller: widget.loadingController,
      offset: .5,
      curve: _switchAuthLoadingAnimationInterval,
      fadeDirection: FadeDirection.topToBottom,
      child: FlatButton(
        child: AnimatedText(
          text: _getLabel(auth.opposite()),
          textRotation: AnimatedTextRotation.down,
        ),
        disabledTextColor: theme.primaryColor,
        onPressed: buttonEnabled ? _switchAuthMode : null,
        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textColor: theme.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceSize = MediaQuery.of(context).size;
    final cardWidth = deviceSize.width * 0.75;
    const cardPadding = 16.0;
    final textFieldWidth = cardWidth - cardPadding * 2;
    final authForm = Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.only(top: 10),
        child: Column(
          children: [
            Container(
              color: Colors.transparent,
              padding: Paddings.fromLTR(cardPadding),
              width: cardWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildNameField(textFieldWidth),
                  SizedBox(height: 20),
                  _buildPasswordField(textFieldWidth),
                  SizedBox(height: 10),
                ],
              ),
            ),
            ExpandableContainer(
              background: theme.accentColor,
              controller: _switchAuthController,
              child: Container(
                alignment: Alignment.topLeft,
                color: theme.cardColor,
                padding: EdgeInsets.symmetric(
                  horizontal: cardPadding,
                  vertical: 10,
                ),
                width: cardWidth,
                child: _buildConfirmPasswordField(textFieldWidth),
              ),
              onExpandCompleted: () {},
            ),
            Container(
              color: Colors.transparent,
              padding: Paddings.fromRBL(cardPadding),
              width: cardWidth,
              child: Column(
                children: <Widget>[
                  _buildForgotPassword(theme),
                  _buildSubmitButton(theme),
                  _buildSwitchAuthButton(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return Container(
      width: cardWidth,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        color: theme.cardColor,
        elevation: 8.0,
        child: authForm,
      ),
    );
  }
}

class _RecoverCard extends StatefulWidget {
  _RecoverCard({
    Key key,
    @required this.emailValidator,
    @required this.onSwitchLogin,
  }) : super(key: key);

  final FormFieldValidator<String> emailValidator;
  final Function onSwitchLogin;

  @override
  _RecoverCardState createState() => _RecoverCardState();
}

class _RecoverCardState extends State<_RecoverCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formRecoverKey = GlobalKey();

  var _isSubmitting = false;
  var _name = '';

  AnimationController _submitController;

  @override
  void initState() {
    super.initState();

    _submitController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _submitController.dispose();
  }

  Future<bool> _submitRecover() async {
    if (!_formRecoverKey.currentState.validate()) {
      return false;
    }
    final auth = Provider.of<Auth>(context, listen: false);

    _formRecoverKey.currentState.save();
    _submitController.forward();
    setState(() => _isSubmitting = true);
    await auth.onRecoverPassword(_name);
    setState(() => _isSubmitting = false);
    _submitController.reverse();
    return true;
  }

  Widget _buildRecoverNameField(double width) {
    return AnimatedTextFormField(
      animatedWidth: width,
      labelText: 'Email',
      prefixIcon: Icon(FontAwesomeIcons.solidUserCircle),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (value) => _submitRecover(),
      validator: widget.emailValidator,
      onSaved: (value) => _name = value,
    );
  }

  Widget _buildRecoverButton(ThemeData theme) {
    return AnimatedButton(
      controller: _submitController,
      color: theme.primaryColor,
      loadingColor: theme.accentColor,
      text: 'RECOVER',
      onPressed: !_isSubmitting ? _submitRecover : null,
    );
  }

  Widget _buildBackButton(ThemeData theme) {
    return FlatButton(
      child: Text('BACK'),
      onPressed: !_isSubmitting ? widget.onSwitchLogin : null,
      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textColor: theme.primaryColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceSize = MediaQuery.of(context).size;
    final cardWidth = deviceSize.width * 0.75;
    const cardPadding = 16.0;
    final textFieldWidth = cardWidth - cardPadding * 2;

    return Container(
      width: cardWidth,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 8.0,
        child: Form(
          key: _formRecoverKey,
          child: Container(
            padding: EdgeInsets.all(cardPadding),
            width: cardWidth,
            alignment: Alignment.center,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _buildRecoverNameField(textFieldWidth),
                  ),
                  SizedBox(height: 15),
                  Text(
                    // TODO: make it a props
                    'We will send your password to this email account',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  _buildRecoverButton(theme),
                  _buildBackButton(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
