import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'animated_button.dart';
import 'animated_text_form_field.dart';
import '../providers/auth.dart';
import '../providers/login_messages.dart';
import '../widget_helper.dart';
import '../paddings.dart';

class ConfirmSignupCard extends StatefulWidget {
  ConfirmSignupCard({
    Key key,
    @required this.onBack,
    @required this.onSubmitCompleted,
  }) : super(key: key);

  final Function onBack;
  final Function onSubmitCompleted;

  @override
  ConfirmSignupCardState createState() => ConfirmSignupCardState();
}

class ConfirmSignupCardState extends State<ConfirmSignupCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formRecoverKey = GlobalKey();

  var _isSubmitting = false;
  var _code = '';

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

  Future<bool> _submit() async {
    FocusScope.of(context).requestFocus(FocusNode());

    if (!_formRecoverKey.currentState.validate()) {
      return false;
    }
    final auth = Provider.of<Auth>(context, listen: false);
    final messages = Provider.of<LoginMessages>(context, listen: false);

    _formRecoverKey.currentState.save();
    _submitController.forward();
    setState(() => _isSubmitting = true);
    // todo: integrate with shared auth loginData for 2nd param
    final error = await auth.onConfirmSignup(_code, null);

    if (error != null) {
      showErrorToast(context, error);
      setState(() => _isSubmitting = false);
      _submitController.reverse();
      return false;
    }

    showSuccessToast(context, messages.confirmSignupSuccess);
    setState(() => _isSubmitting = false);
    _submitController.reverse();
    widget?.onSubmitCompleted();
    return true;
  }

  Future<bool> _resendCode() async {
    FocusScope.of(context).requestFocus(FocusNode());

    final auth = Provider.of<Auth>(context, listen: false);
    final messages = Provider.of<LoginMessages>(context, listen: false);

    _submitController.forward();
    setState(() => _isSubmitting = true);
    // todo: integrate with shared auth loginData to pass name/email
    final error = await auth.onResendCode(null);

    if (error != null) {
      showErrorToast(context, error);
      setState(() => _isSubmitting = false);
      _submitController.reverse();
      return false;
    }

    showSuccessToast(context, messages.resendCodeSuccess);
    setState(() => _isSubmitting = false);
    _submitController.reverse();
    return true;
  }

  Widget _buildConfirmationCodeField(double width, LoginMessages messages) {
    return AnimatedTextFormField(
      width: width,
      labelText: messages.confirmationCodeHint,
      prefixIcon: Icon(FontAwesomeIcons.solidCheckCircle),
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (value) => _submit(),
      validator: (value) {
        if (value.isEmpty) {
          return messages.confirmationCodeValidationError;
        }
        return null;
      },
      onSaved: (value) => _code = value,
    );
  }

  Widget _buildResendCode(ThemeData theme, LoginMessages messages) {
    return FlatButton(
      child: Text(
        messages.resendCodeButton,
        style: theme.textTheme.body1,
        textAlign: TextAlign.left,
      ),
      onPressed: !_isSubmitting ? _resendCode : null,
    );
  }

  Widget _buildConfirmButton(ThemeData theme, LoginMessages messages) {
    return AnimatedButton(
      controller: _submitController,
      text: messages.confirmSignupButton,
      onPressed: !_isSubmitting ? _submit : null,
    );
  }

  Widget _buildBackButton(ThemeData theme, LoginMessages messages) {
    return FlatButton(
      child: Text(messages.goBackButton),
      onPressed: !_isSubmitting ? widget.onBack : null,
      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textColor: theme.primaryColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messages = Provider.of<LoginMessages>(context, listen: false);
    final deviceSize = MediaQuery
        .of(context)
        .size;
    final cardWidth = min(deviceSize.width * 0.75, 360.0);
    const cardPadding = 16.0;
    final textFieldWidth = cardWidth - cardPadding * 2;

    return FittedBox(
      child: Card(
        child: Container(
          padding: const EdgeInsets.only(
            left: cardPadding,
            top: cardPadding + 10.0,
            right: cardPadding,
            bottom: cardPadding,
          ),
          width: cardWidth,
          alignment: Alignment.center,
          child: Form(
            key: _formRecoverKey,
            child: Column(
              children: <Widget>[
                Text(
                  messages.confirmSignupIntro,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.body1,
                ),
                SizedBox(height: 20),
                _buildConfirmationCodeField(textFieldWidth, messages),
                SizedBox(height: 10),
                _buildResendCode(theme, messages),
                _buildConfirmButton(theme, messages),
                _buildBackButton(theme, messages),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
