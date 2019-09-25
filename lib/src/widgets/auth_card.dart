import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'animated_button.dart';
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
    this.onLogin,
    this.onSignup,
    this.onRecoverPassword,
    this.emailValidator,
    this.passwordValidator,
  }) : super(key: key);

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

  /// switch between login and recover password
  AnimationController _switchAuth2Controller;
  AnimationController _submitController;

  Interval _nameTextFieldLoadingAnimationInterval;
  Interval _passTextFieldLoadingAnimationInterval;
  Interval _forgotPasswordLoadingAnimationInterval;
  Interval _switchAuthLoadingAnimationInterval;
  Animation<double> _buttonScaleAnimation;
  Animation<double> _flipAnimation;
  final loadingBoxDuration = const Duration(milliseconds: 200);

  @override
  void initState() {
    super.initState();

    Future.delayed(loadingBoxDuration, () {
      _loadingController.forward();
    });
    _loadingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1150),
      reverseDuration: Duration(milliseconds: 300),
    )..addStatusListener((status) {
        if (status == AnimationStatus.forward) {
          _isLoading = true;
        }
        if (status == AnimationStatus.completed) {
          _isLoading = false;
        }
      });
    _switchAuthController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
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

    _flipAnimation = Tween<double>(begin: 0.0, end: pi).animate(
      CurvedAnimation(
        parent: _switchAuth2Controller,
        curve: Curves.ease,
      ),
    );

    // _loadingController.forward();
  }

  @override
  void dispose() {
    super.dispose();

    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

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
    } else {
      await widget.onRecoverPassword(_authData['email']);
    }

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

  String _getLabel(AuthMode authMode) {
    switch (authMode) {
      case AuthMode.Signup:
        return 'SIGNUP';
      case AuthMode.Login:
        return 'LOGIN';
    }
  }

  void runLoadingAnimation() {
    if (_loadingController.isDismissed) {
      _loadingController.forward();
    } else if (_loadingController.isCompleted) {
      _loadingController.reverse();
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
        onPressed: () {
          setState(() {
            isRecoverPassword = true;
            _switchAuth2Controller.forward();
          });
        },
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
        child: Text(_getLabel(switchAuth(authMode))),
        onPressed:
            (_isSubmitting || _isLoading) ? null : () => _switchAuthMode(),
        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textColor: theme.primaryColor,
      ),
    );
  }

  Widget _buildBackButton(ThemeData theme) {
    return ShadowButton(
      text: 'BACK',
      width: 120.0,
      height: 40.0,
      borderRadius: BorderRadius.circular(100.0),
      color: theme.accentColor,
      splashColor: theme.primaryColor,
      boxShadow: BoxShadow(
        blurRadius: 4,
        color: theme.accentColor.withOpacity(.4),
        offset: Offset(0, 5),
      ),
      onPressed: (_isSubmitting || _isLoading) ? null : () => _switchAuthMode(),
    );
  }

  Matrix4 _getCardTransform() {
    if (isRecoverPassword) {
      return Matrix4.identity()
        ..setEntry(3, 2, .001)
        ..rotateY(_flipAnimation.value);
    }
    return Matrix4.identity();
  }

  Widget _buildAuthCard() {
    final theme = Theme.of(context);
    final deviceSize = MediaQuery.of(context).size;
    final cardWidth = deviceSize.width * 0.75;
    const cardPadding = 16.0;
    final textFieldWidth = cardWidth - cardPadding * 2;
    const debugColor = false;

    return Container(
      width: cardWidth,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        color: debugColor ? Colors.transparent : theme.cardColor,
        elevation: 8.0,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
        ),
      ),
    );
  }

  Widget _buildRecoverPasswordCard() {
    final theme = Theme.of(context);
    final deviceSize = MediaQuery.of(context).size;
    final cardWidth = deviceSize.width * 0.75;
    const cardPadding = 16.0;
    final textFieldWidth = cardWidth - cardPadding * 2;

    return Positioned.fill(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 8.0,
        child: Container(
          padding: EdgeInsets.all(cardPadding),
          width: cardWidth,
          alignment: Alignment.center,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(top: 10),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildNameField(textFieldWidth),
                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    _buildSubmitButton(theme),
                    _buildBackButton(theme),
                  ],
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) => Transform(
        transform: _getCardTransform(),
        alignment: Alignment.center,
        child: child,
      ),
      child: Stack(
        children: <Widget>[
          _buildRecoverPasswordCard(),
          _buildAuthCard(),
        ],
      ),
    );
  }
}
