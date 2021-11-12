part of auth_card_builder;

class _ConfirmRecoverCard extends StatefulWidget {
  const _ConfirmRecoverCard({
    Key? key,
    required this.passwordValidator,
    required this.onBack,
    required this.onSubmitCompleted,
  }) : super(key: key);

  final FormFieldValidator<String> passwordValidator;
  final VoidCallback onBack;
  final VoidCallback onSubmitCompleted;

  @override
  _ConfirmRecoverCardState createState() => _ConfirmRecoverCardState();
}

class _ConfirmRecoverCardState extends State<_ConfirmRecoverCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formRecoverKey = GlobalKey();

  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _passwordController = TextEditingController();

  var _isSubmitting = false;
  var _code = '';

  late AnimationController _submitController;

  @override
  void initState() {
    super.initState();

    _submitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _submitController.dispose();
  }

  Future<bool> _submit() async {
    FocusScope.of(context).requestFocus(FocusNode()); // close keyboard

    if (!_formRecoverKey.currentState!.validate()) {
      return false;
    }
    final auth = Provider.of<Auth>(context, listen: false);
    final messages = Provider.of<LoginMessages>(context, listen: false);

    _formRecoverKey.currentState!.save();
    await _submitController.forward();
    setState(() => _isSubmitting = true);
    final error = await auth.onConfirmRecover!(
      _code,
      LoginData(
        name: auth.email,
        password: auth.password,
      ),
    );

    if (error != null) {
      showErrorToast(context, messages.flushbarTitleError, error);
      setState(() => _isSubmitting = false);
      await _submitController.reverse();
      return false;
    } else {
      showSuccessToast(context, messages.flushbarTitleSuccess,
          messages.confirmRecoverSuccess);
      setState(() => _isSubmitting = false);
      widget.onSubmitCompleted();
      return true;
    }
  }

  Widget _buildVerificationCodeField(double width, LoginMessages messages) {
    return AnimatedTextFormField(
      width: width,
      labelText: messages.recoveryCodeHint,
      prefixIcon: const Icon(FontAwesomeIcons.solidCheckCircle),
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(_passwordFocusNode);
      },
      validator: (value) {
        if (value!.isEmpty) {
          return messages.recoveryCodeValidationError;
        }
        return null;
      },
      onSaved: (value) => _code = value!,
    );
  }

  Widget _buildPasswordField(double width, LoginMessages messages) {
    return AnimatedPasswordTextFormField(
      animatedWidth: width,
      labelText: messages.passwordHint,
      controller: _passwordController,
      textInputAction: TextInputAction.next,
      focusNode: _passwordFocusNode,
      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
      },
      validator: widget.passwordValidator,
      onSaved: (value) {
        final auth = Provider.of<Auth>(context, listen: false);
        auth.password = value!;
      },
    );
  }

  Widget _buildConfirmPasswordField(double width, LoginMessages messages) {
    return AnimatedPasswordTextFormField(
      animatedWidth: width,
      labelText: messages.confirmPasswordHint,
      textInputAction: TextInputAction.done,
      focusNode: _confirmPasswordFocusNode,
      onFieldSubmitted: (value) => _submit(),
      validator: (value) {
        if (value != _passwordController.text) {
          return messages.confirmPasswordError;
        }
        return null;
      },
    );
  }

  Widget _buildSetPasswordButton(ThemeData theme, LoginMessages messages) {
    return AnimatedButton(
      controller: _submitController,
      text: messages.setPasswordButton,
      onPressed: !_isSubmitting ? _submit : null,
    );
  }

  Widget _buildBackButton(ThemeData theme, LoginMessages messages) {
    return MaterialButton(
      onPressed: !_isSubmitting ? widget.onBack : null,
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textColor: theme.primaryColor,
      child: Text(messages.goBackButton),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messages = Provider.of<LoginMessages>(context, listen: false);
    final deviceSize = MediaQuery.of(context).size;
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
                  messages.confirmRecoverIntro,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyText2,
                ),
                const SizedBox(height: 20),
                _buildVerificationCodeField(textFieldWidth, messages),
                const SizedBox(height: 20),
                _buildPasswordField(textFieldWidth, messages),
                const SizedBox(height: 20),
                _buildConfirmPasswordField(textFieldWidth, messages),
                const SizedBox(height: 26),
                _buildSetPasswordButton(theme, messages),
                _buildBackButton(theme, messages),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
