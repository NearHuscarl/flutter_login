part of 'auth_card_builder.dart';

class _RecoverCard extends StatefulWidget {
  const _RecoverCard({
    required this.userValidator,
    required this.onBack,
    required this.userType,
    this.loginTheme,
    required this.navigateBack,
    required this.onSubmitCompleted,
    required this.loadingController,
    required this.initialIsoCode,
    this.onChangedRecoverUser,
    this.onForgotPasswordSwitch,
    this.isBlocPattern,
    this.autoValidateModeForm,
    this.stateController,
  });

  final FormFieldValidator<String>? userValidator;
  final FormFieldValidator<String>? onChangedRecoverUser;
  final VoidCallback onBack;
  final LoginUserType userType;
  final LoginTheme? loginTheme;
  final bool navigateBack;
  final AnimationController loadingController;

  final VoidCallback onSubmitCompleted;
  final String? initialIsoCode;
  final VoidCallback? onForgotPasswordSwitch;
  final bool? isBlocPattern;
  final AutovalidateMode? autoValidateModeForm;
  final StateController? stateController;

  @override
  _RecoverCardState createState() => _RecoverCardState();
}

class _RecoverCardState extends State<_RecoverCard>
    with SingleTickerProviderStateMixin {
  static const failureState = 1;
  static const successfulState = 2;
  final GlobalKey<FormState> _formRecoverKey = GlobalKey();

  bool _isSubmitting = false;

  late TextEditingController _nameController;

  late AnimationController _submitController;

  @override
  void initState() {
    super.initState();

    final auth = Provider.of<Auth>(context, listen: false);
    _nameController = TextEditingController(text: auth.email);

    _submitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.isBlocPattern!) {
      widget.stateController!.addListener(() => handleRecoverCard());
    }
  }

  @override
  void dispose() {
    _submitController.dispose();
    if (widget.isBlocPattern!) {
      widget.stateController!.removeListener(() => handleRecoverCard());
    }
    super.dispose();
  }

  void handleRecoverCard() {
    if (widget.stateController!.state == failureState ||
        widget.stateController!.state == successfulState && _isSubmitting) {
      _endSubmit();
    }
  }

  Future<void> _endSubmit() async {
    await _submitController.reverse();
    setState(() => _isSubmitting = false);
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
    if (widget.isBlocPattern!) {
      await auth.onRecoverPassword!(auth.email);
      return true;
    } else {
      final error = await auth.onRecoverPassword!(auth.email);

      if (error != null) {
        showErrorToast(context, messages.flushbarTitleError, error);
        setState(() => _isSubmitting = false);
        await _submitController.reverse();
        return false;
      } else {
        showSuccessToast(
          context,
          messages.flushbarTitleSuccess,
          messages.recoverPasswordSuccess,
        );
        setState(() => _isSubmitting = false);
        widget.onSubmitCompleted();
        return true;
      }
    }
  }

  Widget _buildRecoverNameField(
    double width,
    LoginMessages messages,
    Auth auth,
  ) {
    return AnimatedTextFormField(
      controller: _nameController,
      loadingController: widget.loadingController,
      userType: widget.userType,
      width: width,
      labelText: messages.userHint,
      prefixIcon: TextFieldUtils.getPrefixIcon(widget.userType),
      keyboardType: TextFieldUtils.getKeyboardType(widget.userType),
      autofillHints: [TextFieldUtils.getAutofillHints(widget.userType)],
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (value) => _submit(),
      validator: widget.userValidator,
      onSaved: (value) => auth.email = value!,
      onChanged: (value) => widget.onChangedRecoverUser?.call(value),
      initialIsoCode: widget.initialIsoCode,
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
    ThemeData theme,
    LoginMessages messages,
    LoginTheme? loginTheme,
  ) {
    final calculatedTextColor =
        (theme.cardTheme.color!.computeLuminance() < 0.5)
            ? Colors.white
            : theme.primaryColor;
    return MaterialButton(
      onPressed: !_isSubmitting
          ? () {
              _formRecoverKey.currentState!.save();
              widget.onBack();
              if (widget.isBlocPattern!) {
                widget.onForgotPasswordSwitch?.call();
              }
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
            autovalidateMode: widget.autoValidateModeForm,
            key: _formRecoverKey,
            child: Column(
              children: [
                Text(
                  messages.recoverPasswordIntro,
                  key: kRecoverPasswordIntroKey,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                _buildRecoverNameField(textFieldWidth, messages, auth),
                const SizedBox(height: 20),
                Text(
                  auth.onConfirmRecover != null
                      ? messages.recoverCodePasswordDescription
                      : messages.recoverPasswordDescription,
                  key: kRecoverPasswordDescriptionKey,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
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
