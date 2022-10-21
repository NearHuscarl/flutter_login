part of auth_card_builder;

class _RecoverCard extends StatefulWidget {
  const _RecoverCard(
      {Key? key,
      required this.userValidator,
      required this.onBack,
      required this.userType,
      this.loginTheme,
      required this.navigateBack,
      required this.onSubmitCompleted,
      required this.loadingController})
      : super(key: key);

  final FormFieldValidator<String>? userValidator;
  final Function onBack;
  final LoginUserType userType;
  final LoginTheme? loginTheme;
  final bool navigateBack;
  final AnimationController loadingController;

  final Function onSubmitCompleted;

  @override
  _RecoverCardState createState() => _RecoverCardState();
}

class _RecoverCardState extends State<_RecoverCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formRecoverKey = GlobalKey();

  bool _isSubmitting = false;

  late TextEditingController _nameController;
  late TextEditingController _extraEmailController;
  late TextEditingController _phoneController;
  late TextEditingController _newPasswordController;

  late AnimationController _submitController;

  @override
  void initState() {
    super.initState();

    final auth = Provider.of<Auth>(context, listen: false);
    _nameController = TextEditingController(text: auth.email);
    _extraEmailController = TextEditingController(text: auth.extraEmail);
    _phoneController = TextEditingController(text: auth.email);
    _newPasswordController = TextEditingController(text: auth.password);

    _submitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _submitController.dispose();
    super.dispose();
  }

  Future<bool> _submit() async {
    if (!_formRecoverKey.currentState!.validate()) {
      return false;
    }
    final auth = Provider.of<Auth>(context, listen: false);
    final messages = Provider.of<LoginMessages>(context, listen: false);

    _formRecoverKey.currentState!.save();
    await _submitController.forward();
    setState(() => _isSubmitting = true);
    final error = await auth.onRecoverPassword!(RecoverData(phone: auth.email, email: auth.extraEmail, newPassword: auth.password));

    if (error != null) {
      showErrorToast(context, messages.flushbarTitleError, error);
      setState(() => _isSubmitting = false);
      await _submitController.reverse();
      return false;
    } else {
      showSuccessToast(context, messages.flushbarTitleSuccess,
          messages.recoverPasswordSuccess);
      setState(() => _isSubmitting = false);
      widget.onSubmitCompleted();
      return true;
    }
  }

  Widget _buildRecoverNameField(
      double width, LoginMessages messages, Auth auth) {
    return AnimatedTextFormField(
      controller: _nameController,
      loadingController: widget.loadingController,
      width: width,
      labelText: messages.userHint,
      prefixIcon: const Icon(FontAwesomeIcons.solidCircleUser),
      keyboardType: TextFieldUtils.getKeyboardType(widget.userType),
      autofillHints: [TextFieldUtils.getAutofillHints(widget.userType)],
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (value) => _submit(),
      validator: widget.userValidator,
      onSaved: (value) => auth.email = value!,
    );
  }

  Widget _buildRecoverEmailField(
      double width,
      LoginMessages messages,
      Auth auth,
      ) {
    return AnimatedTextFormField(
      controller: _extraEmailController,
      width: width,
      loadingController: widget.loadingController,
      labelText: '邮箱',
      autofillHints: [TextFieldUtils.getAutofillHints(LoginUserType.email)],
      prefixIcon: TextFieldUtils.getPrefixIcon(LoginUserType.email),
      keyboardType: TextFieldUtils.getKeyboardType(LoginUserType.email),
      textInputAction: TextInputAction.next,
      validator: FlutterLogin.defaultEmailValidator,
      onSaved: (value) => auth.extraEmail = value!,
    );
  }


  Widget _buildNewPasswordField(double width, LoginMessages messages, Auth auth) {
    return AnimatedPasswordTextFormField(
      animatedWidth: width,
      loadingController: widget.loadingController,
      labelText: '新密码',
      controller: _newPasswordController,
      textInputAction: TextInputAction.done,
      focusNode: FocusNode(),
      validator: (value) {
        if (value!.isEmpty) {
          return '密码不能为空';
        }
        return null;
      },
      onSaved: (value) => auth.password = value!,
      enabled: !_isSubmitting,
    );
  }

  Widget _buildRecoverPhoneField(
      double width,
      LoginMessages messages,
      Auth auth,
      ) {
    return AnimatedTextFormField(
      controller: _phoneController,
      width: width,
      loadingController: widget.loadingController,
      labelText: '手机号',
      autofillHints: [TextFieldUtils.getAutofillHints(LoginUserType.phone)],
      prefixIcon: TextFieldUtils.getPrefixIcon(LoginUserType.phone),
      keyboardType: TextFieldUtils.getKeyboardType(LoginUserType.phone),
      textInputAction: TextInputAction.next,
      validator: (value) {
        var phoneRegExp = RegExp(
            '^(\\+\\d{1,2}\\s)?\\(?\\d{3}\\)?[\\s.-]?\\d{3}[\\s.-]?\\d{4}\$');
        if (value != null &&
            value.length < 7 &&
            !phoneRegExp.hasMatch(value)) {
          return "This isn't a valid phone number";
        }
        return null;
      },
      onSaved: (value) => auth.email = value!,
    );
  }

  Widget _buildRecoverButton(ThemeData theme, LoginMessages messages) {
    return AnimatedButton(
      controller: _submitController,
      text: messages.recoverPasswordButton,
      onPressed: !_isSubmitting ? _submit : null,
    );
  }

  Widget _buildBackButton(
      ThemeData theme, LoginMessages messages, LoginTheme? loginTheme) {
    final calculatedTextColor =
        (theme.cardTheme.color!.computeLuminance() < 0.5)
            ? Colors.white
            : theme.primaryColor;
    return MaterialButton(
      onPressed: !_isSubmitting
          ? () {
              _formRecoverKey.currentState!.save();
              widget.onBack();
            }
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textColor: loginTheme?.switchAuthTextColor ?? calculatedTextColor,
      child: Text(messages.goBackButton),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<Auth>(context, listen: false);
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
              children: [
                Text(
                  messages.recoverPasswordIntro,
                  key: kRecoverPasswordIntroKey,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyText2,
                ),
                const SizedBox(height: 20),
                // _buildRecoverNameField(textFieldWidth, messages, auth),
                _buildRecoverPhoneField(textFieldWidth, messages, auth),
                const SizedBox(height: 20),
                _buildRecoverEmailField(textFieldWidth, messages, auth),
                const SizedBox(height: 20),
                _buildNewPasswordField(textFieldWidth, messages, auth),
                const SizedBox(height: 20),
                Text(
                  auth.onConfirmRecover != null
                      ? messages.recoverCodePasswordDescription
                      : messages.recoverPasswordDescription,
                  key: kRecoverPasswordDescriptionKey,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyText2,
                ),
                const SizedBox(height: 26),
                _buildRecoverButton(theme, messages),
                _buildBackButton(theme, messages, widget.loginTheme),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
