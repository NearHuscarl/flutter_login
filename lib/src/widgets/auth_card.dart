import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../matrix.dart';
import 'animated_button.dart';
import 'animated_text.dart';
import 'expandable_container.dart';
import 'shadow_button.dart';
import 'fade_in.dart';
import 'animated_text_form_field.dart';
import '../login_data.dart';
import '../paddings.dart';

enum AuthMode { Signup, Login }

switchAuth(AuthMode authMode) =>
    authMode == AuthMode.Login ? AuthMode.Signup : AuthMode.Login;

class AuthCard extends StatefulWidget {
  AuthCard({
    Key key,
    this.loadingController,
    this.onLogin,
    this.onSignup,
    this.onRecoverPassword,
    this.emailValidator,
    this.passwordValidator,
  }) : super(key: key);

  final AnimationController loadingController;
  final Future<void> Function(LoginData) onLogin;
  final Future<void> Function(LoginData) onSignup;
  final Future<void> Function(String) onRecoverPassword;
  final FormFieldValidator<String> emailValidator;
  final FormFieldValidator<String> passwordValidator;

  @override
  AuthCardState createState() => AuthCardState();
}

class AuthCardState extends State<AuthCard> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<FormState> _formRecoverKey = GlobalKey();
  final GlobalKey _cardKey = GlobalKey();

  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _passwordController = TextEditingController();

  var _obscurePasswordText = true;
  var _obscureConfirmPasswordText = true;

  var authMode = AuthMode.Login;
  var isRecoverPassword = false;

  var _authData = {'email': '', 'password': ''};
  var _isLoading = false;
  var _isSubmitting = false;

  AnimationController _loadingController;

  /// switch between login and signup
  AnimationController _switchAuthController;
  AnimationController _postSwitchAuthController;
  PageController _pageController = PageController();

  /// switch between login and recover password
  AnimationController _switchAuth2Controller;
  AnimationController _submitController;

  Interval _nameTextFieldLoadingAnimationInterval;
  Interval _passTextFieldLoadingAnimationInterval;
  Interval _forgotPasswordLoadingAnimationInterval;
  Interval _switchAuthLoadingAnimationInterval;
  Animation<double> _buttonScaleAnimation;
  Animation<double> _flipAnimation;

  bool get buttonEnabled => !_isLoading && !_isSubmitting;

  @override
  void initState() {
    super.initState();

    widget.loadingController.addStatusListener((status) {
      if (status == AnimationStatus.forward) {
        setState(() => _isLoading = true);
      }
      if (status == AnimationStatus.completed) {
        _loadingController.forward();
      }
    });
    _loadingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1150),
      reverseDuration: Duration(milliseconds: 300),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _isLoading = false);
        }
      });
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
    _switchAuth2Controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
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
      parent: _loadingController,
      curve: Interval(.4, 1.0, curve: Curves.easeOutBack),
    ));

    // _flipAuthAnimation = Tween<double>(begin: 0.0, end: pi).animate(
    //   CurvedAnimation(
    //     parent: _switchAuth2Controller,
    //     curve: Curves.ease,
    //   ),
    // );
    _flipAnimation = Tween<double>(begin: pi / 2, end: 0).animate(
      CurvedAnimation(
        parent: widget.loadingController,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      ),
    );

    // _loadingController.forward();
  }

  @override
  void dispose() {
    super.dispose();

    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _pageController.dispose();

    _loadingController.dispose();
    _switchAuthController.dispose();
    _postSwitchAuthController.dispose();
    _switchAuth2Controller.dispose();
    _submitController.dispose();
  }

  Future<bool> _submit() async {
    if (!_formKey.currentState.validate()) {
      return false;
    }
    _formKey.currentState.save();
    _submitController.forward();
    setState(() => _isSubmitting = true);

    if (authMode == AuthMode.Login) {
      await widget.onLogin(LoginData(
        name: _authData['email'],
        password: _authData['password'],
      ));
    } else if (authMode == AuthMode.Signup) {
      await widget.onSignup(LoginData(
        name: _authData['email'],
        password: _authData['password'],
      ));
    }

    setState(() => _isSubmitting = false);
    _submitController.reverse();
    return true;
  }

  Future<bool> _submitRecover() async {
    if (!_formRecoverKey.currentState.validate()) {
      return false;
    }
    _formRecoverKey.currentState.save();
    _submitController.forward();
    setState(() => _isSubmitting = true);
    await widget.onRecoverPassword(_authData['email']);
    setState(() => _isSubmitting = false);
    _submitController.reverse();
    return true;
  }

  void _switchAuthMode() {
    final newAuthMode = switchAuth(authMode);
    setState(() => authMode = newAuthMode);

    if (newAuthMode == AuthMode.Signup) {
      _switchAuthController.forward();
    } else {
      _switchAuthController.reverse();
    }
  }

  void _switchRecovery(bool recovery) {
    setState(() => isRecoverPassword = recovery);

    if (recovery) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
      _switchAuth2Controller.forward();
    } else {
      _pageController.previousPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
      _switchAuth2Controller.reverse();
    }
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

  void runLoadingAnimation() {
    if (_loadingController.isDismissed) {
      widget.loadingController.forward();
    } else if (_loadingController.isCompleted) {
      _loadingController.reverse().then((_) {
        widget.loadingController.reverse();
      });
    }
  }

  Widget _buildNameField(double width) {
    return AnimatedTextFormField(
      animatedWidth: width,
      loadingController: _loadingController,
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
    final isLogin = authMode == AuthMode.Login;

    return AnimatedTextFormField(
      animatedWidth: width,
      loadingController: _loadingController,
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
      textInputAction: isLogin ? TextInputAction.done : TextInputAction.next,
      focusNode: _passwordFocusNode,
      onFieldSubmitted: (value) {
        if (isLogin) {
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
    final isSignUp = authMode == AuthMode.Signup;

    return AnimatedTextFormField(
      animatedWidth: width,
      enabled: isSignUp,
      loadingController: _loadingController,
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
      validator: isSignUp
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
      controller: _loadingController,
      fadeDirection: FadeDirection.bottomToTop,
      offset: .5,
      curve: _forgotPasswordLoadingAnimationInterval,
      child: FlatButton(
        child: Text(
          'Forgot Password?',
          style: theme.textTheme.body1,
          textAlign: TextAlign.left,
        ),
        onPressed: buttonEnabled ? () => _switchRecovery(true) : null,
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return ScaleTransition(
      scale: _buttonScaleAnimation,
      child: AnimatedButton(
        controller: _submitController,
        color: theme.primaryColor,
        loadingColor: theme.accentColor,
        text: _getLabel(authMode),
        onPressed: _submit,
      ),
    );
  }

  Widget _buildSwitchAuthButton(ThemeData theme) {
    return FadeIn(
      controller: _loadingController,
      offset: .5,
      curve: _switchAuthLoadingAnimationInterval,
      fadeDirection: FadeDirection.topToBottom,
      child: FlatButton(
        child: AnimatedText(
          text: _getLabel(switchAuth(authMode)),
          textRotation: AnimatedTextRotation.down,
        ),
        onPressed: buttonEnabled ? _switchAuthMode : null,
        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textColor: theme.primaryColor,
      ),
    );
  }

  Widget _buildRecoverNameField(double width) {
    return AnimatedTextFormField(
      animatedWidth: width,
      loadingController: _loadingController,
      interval: _nameTextFieldLoadingAnimationInterval,
      labelText: 'Email',
      prefixIcon: Icon(FontAwesomeIcons.solidUserCircle),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (value) => _submitRecover(),
      validator: widget.emailValidator,
      onSaved: (value) => _authData['email'] = value,
    );
  }

  Widget _buildRecoverButton(ThemeData theme) {
    return ScaleTransition(
      scale: _buttonScaleAnimation,
      child: AnimatedButton(
        controller: _submitController,
        color: theme.primaryColor,
        loadingColor: theme.accentColor,
        text: 'RECOVER',
        onPressed: buttonEnabled ? _submitRecover : null,
      ),
    );
  }

  Widget _buildBackButton(ThemeData theme) {
    return FlatButton(
      child: Text('BACK'),
      onPressed: buttonEnabled ? () => _switchRecovery(false) : null,
      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textColor: theme.primaryColor,
    );
  }

  Widget _buildAuthCard() {
    final theme = Theme.of(context);
    final deviceSize = MediaQuery.of(context).size;
    final cardWidth = deviceSize.width * 0.75;
    const cardPadding = 16.0;
    final textFieldWidth = cardWidth - cardPadding * 2;
    const debugColor = false;

    final authForm = Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.only(top: 10),
        child: Column(
          children: [
            Container(
              color: debugColor ? Colors.white : Colors.transparent,
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
                color: debugColor ? Colors.white70 : theme.cardColor,
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
              color: debugColor ? Colors.white60 : Colors.transparent,
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

    return Column(
      children: <Widget>[
        Container(
          key: _cardKey,
          width: cardWidth,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            color: debugColor ? Colors.transparent : theme.cardColor,
            elevation: 8.0,
            child: authForm,
          ),
        ),
      ],
    );
  }

  Widget _buildRecoverPasswordCard() {
    final theme = Theme.of(context);
    final deviceSize = MediaQuery.of(context).size;
    final cardWidth = deviceSize.width * 0.75;
    const cardPadding = 16.0;
    final textFieldWidth = cardWidth - cardPadding * 2;

    return Column(
      children: <Widget>[
        Container(
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
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final pagePadding =
        EdgeInsets.symmetric(horizontal: (deviceSize.width * 0.25) / 2);

    return LimitedBox(
      maxHeight: 400,
      child: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: <Widget>[
          Padding(
            padding: pagePadding,
            child: AnimatedBuilder(
              animation: _flipAnimation,
              builder: (context, child) => Transform(
                transform: Matrix.perspective()..rotateX(_flipAnimation.value),
                alignment: Alignment.center,
                child: child,
              ),
              child: _buildAuthCard(),
            ),
          ),
          if (!_isLoading)
            Padding(
              padding: pagePadding,
              child: _buildRecoverPasswordCard(),
            ),
        ],
      ),
    );
  }
}
