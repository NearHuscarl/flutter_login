import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'animated_button.dart';
import 'expandable_container.dart';
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
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _passwordController = TextEditingController();

  var _obscurePasswordText = true;
  var _obscureConfirmPasswordText = true;

  var _authMode = AuthMode.Login;
  var _authData = {'email': '', 'password': ''};
  var _isLoading = false;

  AnimationController _authChangedController;
  AnimationController _submitController;
  Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _authChangedController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _submitController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    super.dispose();

    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
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

  InputDecoration _getInputDecoration(String labelText, Widget prefixIcon,
      [Widget suffixIcon]) {
    return InputDecoration(
      contentPadding: EdgeInsets.symmetric(vertical: 4.0),
      labelText: labelText,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
        borderRadius: BorderRadius.all(
          Radius.circular(100),
        ),
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      decoration:
          _getInputDecoration('Email', Icon(FontAwesomeIcons.solidUserCircle)),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(_passwordFocusNode);
      },
      validator: widget.emailValidator,
      onSaved: (value) => _authData['email'] = value,
    );
  }

  Widget _buildPasswordField(bool isLogin) {
    return TextFormField(
      decoration: _getInputDecoration(
        'Password',
        Icon(FontAwesomeIcons.lock, size: 20),
        IconButton(
          icon: Icon(Icons.remove_red_eye),
          onPressed: () =>
              setState(() => _obscurePasswordText = !_obscurePasswordText),
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

  Widget _buildConfirmPasswordField(bool isSignUp) {
    return TextFormField(
      enabled: isSignUp,
      decoration: _getInputDecoration(
        'Confirm Password',
        Icon(FontAwesomeIcons.lock, size: 20),
        IconButton(
            icon: Icon(Icons.remove_red_eye),
            onPressed: () => setState(() =>
                _obscureConfirmPasswordText = !_obscureConfirmPasswordText)),
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
    return AnimatedButton(
      controller: _submitController,
      color: theme.primaryColor,
      loadingColor: theme.accentColor,
      text: isLogin ? 'LOGIN' : 'SIGN UP',
      onPressed: _submit,
    );
  }

  Widget _buildSwitchAuthButton(bool isLogin, ThemeData theme) {
    return FlatButton(
      child: Text('${isLogin ? 'SIGNUP' : 'LOGIN'}'),
      onPressed: _isLoading ? null : _switchAuthMode,
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
    final isLogin = _authMode == AuthMode.Login;
    final isSignUp = _authMode == AuthMode.Signup;
    final isRecoverPassword = _authMode == AuthMode.RecoverPassword;
    const aniDuration = Duration(milliseconds: 300);
    const debugColor = false;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: debugColor ? Colors.transparent : theme.cardColor,
      elevation: 8.0,
      child: AnimatedContainer(
        duration: aniDuration,
        curve: Curves.easeIn,
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
                    children: <Widget>[
                      _buildNameField(),
                      SizedBox(height: 20),
                      _buildPasswordField(isLogin),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
                ExpandableContainer(
                  background: theme.accentColor,
                  controller: _authChangedController,
                  child: Container(
                    alignment: Alignment.topCenter,
                    color: debugColor ? Colors.white70 : theme.cardColor,
                    padding: EdgeInsets.symmetric(horizontal: cardPadding),
                    width: cardWidth,
                    child: _buildConfirmPasswordField(isSignUp),
                  ),
                ),
                AnimatedContainer(
                  duration: aniDuration,
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
