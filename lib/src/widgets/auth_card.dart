import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'animated_button.dart';
import 'expandable_container.dart';
import 'fade_in.dart';
import 'animated_text_form_field.dart';
import '../login_data.dart';
import '../paddings.dart';

enum AuthMode { Signup, Login, RecoverPassword }

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

  var _authMode = AuthMode.Login;
  var _authData = {'email': '', 'password': ''};
  var _isLoading = false;

  AnimationController _loadingController;
  AnimationController _loadingDelayController;
  AnimationController _authChangedController;
  AnimationController _submitController;
  Animation<double> _opacityAnimation;
  Animation<double> _buttonScaleAnimation;
  final loadingBoxDuration = const Duration(milliseconds: 200);

  @override
  void initState() {
    super.initState();

    Future.delayed(loadingBoxDuration, () {
      _loadingController.forward();
    });
    _loadingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
      reverseDuration: Duration(milliseconds: 300),
    )..addStatusListener((status) {
        if (status == AnimationStatus.forward) {
          final durationMs = _loadingController.duration.inMilliseconds;
          final delay = Duration(milliseconds: (durationMs / 6).round());

          Future.delayed(delay, () {
            _loadingDelayController.forward();
          });
        }
        if (status == AnimationStatus.reverse) {
          _loadingDelayController.reverse();
        }
      });
    _loadingDelayController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
      reverseDuration: Duration(milliseconds: 300),
    );
    _authChangedController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _submitController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    _buttonScaleAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Interval(.45, 1.0, curve: Curves.easeOutBack),
    ));

    // _loadingController.forward();
  }

  @override
  void dispose() {
    super.dispose();

    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    _loadingController.dispose();
    _loadingDelayController.dispose();
    _authChangedController.dispose();
    _submitController.dispose();
  }

  Future<bool> _submit() async {
    if (!_formKey.currentState.validate()) {
      return false;
    }
    _formKey.currentState.save();
    _submitController.forward();
    setState(() => _isLoading = true);

    if (_authMode == AuthMode.Login) {
      await widget.onLogin(LoginData(
        name: _authData['email'],
        password: _authData['password'],
      ));
    } else {
      await widget.onSignup(LoginData(
        name: _authData['email'],
        password: _authData['password'],
      ));
    }

    setState(() => _isLoading = false);
    _submitController.reverse();
    return true;
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() => _authMode = AuthMode.Signup);
      _authChangedController.forward();
    } else {
      setState(() => _authMode = AuthMode.Login);
      _authChangedController.reverse();
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
      animationController: _loadingController,
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

  Widget _buildPasswordField(double width, bool isLogin) {
    return AnimatedTextFormField(
      animatedWidth: width,
      animationController: _loadingDelayController,
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

  Widget _buildConfirmPasswordField(double width, bool isSignUp) {
    return AnimatedTextFormField(
      animatedWidth: width,
      enabled: isSignUp,
      animationController: _loadingController,
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
      fadeDirection: FadeDirection.topToBottom,
      offset: .5,
      curve: Interval(.5, 1.0, curve: Curves.easeOut),
      child: FlatButton(
        child: Text(
          'Forgot Password?',
          style: theme.textTheme.body1,
          textAlign: TextAlign.left,
        ),
        onPressed: () {
          // TODO: implement forgot password
        },
      ),
    );
  }

  Widget _buildSubmitButton(bool isLogin, ThemeData theme) {
    return ScaleTransition(
      scale: _buttonScaleAnimation,
      child: AnimatedButton(
        controller: _submitController,
        color: theme.primaryColor,
        loadingColor: theme.accentColor,
        text: isLogin ? 'LOGIN' : 'SIGN UP',
        onPressed: _submit,
      ),
    );
  }

  Widget _buildSwitchAuthButton(bool isLogin, ThemeData theme) {
    return FadeIn(
      controller: _loadingDelayController,
      offset: .5,
      curve: Interval(.5, 1.0, curve: Curves.easeOut),
      fadeDirection: FadeDirection.bottomToTop,
      child: FlatButton(
        child: Text('${isLogin ? 'SIGNUP' : 'LOGIN'}'),
        onPressed: _isLoading ? null : _switchAuthMode,
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
    final isLogin = _authMode == AuthMode.Login;
    final isSignUp = _authMode == AuthMode.Signup;
    final isRecoverPassword = _authMode == AuthMode.RecoverPassword;
    const debugColor = false;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: debugColor ? Colors.transparent : theme.cardColor,
      elevation: 8.0,
      child: AnimatedContainer(
        duration: loadingBoxDuration,
        curve: Curves.easeOut,
        // height: isSignUp ? 320 : 260,
        // constraints: BoxConstraints(minHeight: isSignUp ? 400 : 400 /*320*/),
        width: cardWidth,
        color: debugColor ? Colors.red : Colors.transparent,
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
                      _buildPasswordField(textFieldWidth, isLogin),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
                ExpandableContainer(
                  background: theme.accentColor,
                  controller: _authChangedController,
                  child: Container(
                    alignment: Alignment.topLeft,
                    color: debugColor ? Colors.white70 : theme.cardColor,
                    padding: EdgeInsets.symmetric(
                      horizontal: cardPadding,
                      vertical: 10,
                    ),
                    width: cardWidth,
                    child: _buildConfirmPasswordField(textFieldWidth, isSignUp),
                  ),
                ),
                AnimatedContainer(
                  duration: loadingBoxDuration,
                  alignment: Alignment.topCenter,
                  // transform: Matrix4.identity()
                  //   ..translate(0.0, _translateUpAni.value),
                  color: debugColor ? Colors.white60 : Colors.transparent,
                  padding: Paddings.fromRBL(cardPadding),
                  width: cardWidth,
                  child: Column(
                    children: <Widget>[
                      _buildForgotPassword(theme),
                      _buildSubmitButton(isLogin, theme),
                      _buildSwitchAuthButton(isLogin, theme),
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
}
