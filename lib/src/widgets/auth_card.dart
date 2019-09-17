import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../login_data.dart';

enum AuthMode { Signup, Login, RecoverPassword }

class AuthCard extends StatefulWidget {
  final Future<void> Function(LoginData) onLogin;
  final Future<void> Function(LoginData) onSignup;
  final Future<void> Function(String) onRecoverPassword;
  final FormFieldValidator<String> emailValidator;
  final FormFieldValidator<String> passwordValidator;

  AuthCard({
    this.onLogin,
    this.onSignup,
    this.onRecoverPassword,
    this.emailValidator,
    this.passwordValidator,
  });

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  var _obscurePasswordText = true;
  var _obscureConfirmPasswordText = true;
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  AnimationController _aniController;
  Animation<Offset> _slideAnimation;
  Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _aniController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 300,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1.5),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _aniController,
      curve: Curves.fastOutSlowIn,
    ));
    _opacityAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _aniController,
      curve: Curves.easeIn,
    ));
  }

  @override
  void dispose() {
    super.dispose();

    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _aniController.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
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
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() => _authMode = AuthMode.Signup);
      _aniController.forward();
    } else {
      setState(() => _authMode = AuthMode.Login);
      _aniController.reverse();
    }
  }

  TextFormField _buildNameField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        prefixIcon: Icon(
          FontAwesomeIcons.solidUserCircle,
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(_passwordFocusNode);
      },
      validator: widget.emailValidator,
      onSaved: (value) => _authData['email'] = value,
    );
  }

  TextFormField _buildPasswordField(bool isLogin) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        prefixIcon: Icon(
          FontAwesomeIcons.lock,
          size: 20,
        ),
        suffixIcon: IconButton(
          icon: Icon(Icons.remove_red_eye),
          onPressed: () => setState(
            () => _obscurePasswordText = !_obscurePasswordText,
          ),
        ),
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

  TextFormField _buildConfirmPasswordField(bool isSignUp) {
    return TextFormField(
      enabled: isSignUp,
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        prefixIcon: Icon(
          FontAwesomeIcons.lock,
          size: 20,
        ),
        suffixIcon: IconButton(
          icon: Icon(Icons.remove_red_eye),
          onPressed: () => setState(
              () => _obscureConfirmPasswordText = !_obscureConfirmPasswordText),
        ),
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
          : null,
    );
  }

  Widget _buildForgotPassword(ThemeData theme) {
    return FlatButton(
      child: Text(
        'Forgot Password?',
        style: theme.textTheme.body1,
        textAlign: TextAlign.left,
      ),
      onPressed: () {},
    );
  }

  Widget _buildSubmitButton(bool isLogin, ThemeData theme) {
    return RaisedButton(
      child: Text(isLogin ? 'LOGIN' : 'SIGN UP'),
      onPressed: _submit,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
      color: theme.primaryColor,
      textColor: theme.primaryTextTheme.button.color,
    );
  }

  Widget _buildSwitchAuthButton(bool isLogin, ThemeData theme) {
    return FlatButton(
      child: Text('${isLogin ? 'SIGNUP' : 'LOGIN'}'),
      onPressed: _switchAuthMode,
      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textColor: theme.primaryColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceSize = MediaQuery.of(context).size;
    final isLogin = _authMode == AuthMode.Login;
    final isSignUp = _authMode == AuthMode.Signup;
    final isRecoverPassword = _authMode == AuthMode.RecoverPassword;

    return Container(
      // transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateX(pi * 1 / 6),
      // transform: Matrix4.diagonal3Values(2, 2, 1.0),
      alignment: Alignment.bottomCenter,
      // transform: Matrix4.skewY(.5),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 8.0,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn,
          height: isSignUp ? 320 : 260,
          // height: _heightAnimation.value.height,
          constraints: BoxConstraints(minHeight: isSignUp ? 400 : 320),
          width: deviceSize.width * 0.75,
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  _buildNameField(),
                  SizedBox(height: 20),
                  _buildPasswordField(isLogin),
                  SizedBox(height: isSignUp ? 20 : 0),
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    constraints: BoxConstraints(
                      minHeight: isSignUp ? 60 : 0,
                      maxHeight: isSignUp ? 120 : 0,
                    ),
                    curve: Curves.easeIn,
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildConfirmPasswordField(isSignUp),
                      ),
                    ),
                  ),
                  _buildForgotPassword(theme),
                  if (_isLoading)
                    CircularProgressIndicator()
                  else
                    _buildSubmitButton(isLogin, theme),
                  _buildSwitchAuthButton(isLogin, theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
