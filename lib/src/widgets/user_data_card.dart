part of auth_card;

class _UserDataCard extends StatefulWidget {
  _UserDataCard({
    Key? key,
    required this.formFields,
    this.loginAfterSignUp = true,
  }) : super(key: key);

  /// The fields to be included in the card. They must be at least 1 and at maximum 10.
  final List<UserFormField> formFields;

  final bool loginAfterSignUp;

  @override
  _UserDataCardState createState() => _UserDataCardState();
}

class _UserDataCardState extends State<_UserDataCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formCompleteSignupKey = GlobalKey();

  late HashMap<String, TextEditingController> _nameControllers;
  late AnimationController _submitController;

  var _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    final auth = Provider.of<Auth>(context, listen: false);

    _nameControllers =
        HashMap<String, TextEditingController>.fromIterable(widget.formFields,
            key: (formFields) => formFields.name,
            value: (_) => TextEditingController(
                  text: '',
                ));

    if (_nameControllers.length != widget.formFields.length) {
      throw ArgumentError(
          'Some of the formFields have duplicated names, and this is not allowed.');
    }

    _submitController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _submitController.dispose();
    super.dispose();
  }

  Future<bool> _submit() async {
    // a hack to force unfocus the soft keyboard. If not, after change-route
    // animation completes, it will trigger rebuilding this widget and show all
    // textfields and buttons again before going to new route
    FocusScope.of(context).requestFocus(FocusNode());

    final messages = Provider.of<LoginMessages>(context, listen: false);

    if (!_formCompleteSignupKey.currentState!.validate()) {
      return false;
    }

    _formCompleteSignupKey.currentState!.save();
    await _submitController.forward();
    setState(() => _isSubmitting = true);
    final auth = Provider.of<Auth>(context, listen: false);
    String? error;

    // We have to convert the Map<String, TextEditingController> to a Map<String, String>
    // and pass it to the function given by the user
    error = await auth.onAdditionalFieldsSignup
        ?.call(_nameControllers.map((key, value) => MapEntry(key, value.text)));

    await _submitController.reverse();

    if (!DartHelper.isNullOrEmpty(error)) {
      showErrorToast(context, messages.flushbarTitleError, error!);
      setState(() => _isSubmitting = false);
      return false;
    }

    if (auth.isSignup && !widget.loginAfterSignUp) {
      showSuccessToast(
          context, messages.flushbarTitleSuccess, messages.signUpSuccess);
      setState(() => _isSubmitting = false);
      return false;
    }

    return true;
  }

  Widget _buildFields(double width) {
    return Column(
        children: widget.formFields.map((UserFormField formField) {
      return Column(
        children: [
          SizedBox(
            height: 5,
          ),
          AnimatedTextFormField(
            controller: _nameControllers[formField.name],
            width: width,
            labelText: formField.name,
            prefixIcon:
                formField.icon ?? Icon(FontAwesomeIcons.solidUserCircle),
            keyboardType: TextFieldUtils.getKeyboardType(formField.userType),
            autofillHints: [
              TextFieldUtils.getAutofillHints(formField.userType)
            ],
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            validator: formField.fieldValidator,
          ),
          SizedBox(
            height: 5,
          )
        ],
      );
    }).toList());
  }

  Widget _buildSubmitButton(ThemeData theme, LoginMessages messages) {
    return AnimatedButton(
      controller: _submitController,
      text: messages.completeSignupButton,
      onPressed: !_isSubmitting ? _submit : null,
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

    if (widget.formFields.isEmpty) {
      throw RangeError('The formFields array must not be empty');
    } else if (widget.formFields.length > 6) {
      throw RangeError(
          'More than 6 formFields are not displayable, but you provided $widget.formFields.length');
    }

    return FittedBox(
      // width: cardWidth,
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
            key: _formCompleteSignupKey,
            child: Column(
              children: [
                Text(
                  messages.completeSignupInfo,
                  key: kRecoverPasswordIntroKey,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyText2,
                ),
                _buildFields(textFieldWidth),
                SizedBox(height: 5),
                _buildSubmitButton(theme, messages),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
