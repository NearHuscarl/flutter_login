part of auth_card;

class _AdditionalSignUpCard extends StatefulWidget {
  _AdditionalSignUpCard({
    Key? key,
    required this.formFields,
    required this.onSubmitCompleted,
    this.loadingController,
  }) : super(key: key) {
    if (formFields.isEmpty) {
      throw RangeError('The formFields array must not be empty');
    } else if (formFields.length > 6) {
      throw RangeError(
          'More than 6 formFields are not displayable, you provided ${formFields.length}');
    }
  }

  final List<UserFormField> formFields;
  final Function onSubmitCompleted;
  final AnimationController? loadingController;

  @override
  _AdditionalSignUpCardState createState() => _AdditionalSignUpCardState();
}

class _AdditionalSignUpCardState extends State<_AdditionalSignUpCard>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formCompleteSignupKey = GlobalKey();

  late HashMap<String, TextEditingController> _nameControllers;

  late List<AnimationController> _fieldAnimationControllers;

  late AnimationController _submitController;
  late AnimationController _loadingController;

  late Interval _textFieldAnimationInterval;

  late Animation<double> _buttonScaleAnimation;

  var _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    _nameControllers =
        HashMap<String, TextEditingController>.fromIterable(widget.formFields,
            key: (formFields) => formFields.keyName,
            value: (formFields) => TextEditingController(
                  text: formFields.defaultValue,
                ));

    if (_nameControllers.length != widget.formFields.length) {
      throw ArgumentError(
          'Some of the formFields have duplicated names, and this is not allowed.');
    }

    _fieldAnimationControllers = widget.formFields
        .map((e) => AnimationController(
            vsync: this, duration: const Duration(milliseconds: 1000)))
        .toList();

    _loadingController = widget.loadingController ??
        (AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1150),
          reverseDuration: const Duration(milliseconds: 300),
        )..value = 1.0);

    _textFieldAnimationInterval = const Interval(0, .85);

    _submitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _buttonScaleAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _loadingController,
      curve: const Interval(.4, 1.0, curve: Curves.easeOutBack),
    ));
  }

  @override
  void dispose() {
    // Don't dispose the controller when we get it from outside, otherwise we get an Error
    // since also the parent widget disposes it
    if (widget.loadingController == null) _loadingController.dispose();
    for (var element in _fieldAnimationControllers) {
      element.dispose();
    }
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
    auth.additionalSignupData =
        _nameControllers.map((key, value) => MapEntry(key, value.text));

    switch (auth.authType) {
      case AuthType.provider:
        error = await auth.onSignup!(SignupData.fromProvider(
          additionalSignupData: auth.additionalSignupData,
        ));
        break;
      case AuthType.userPassword:
        error = await auth.onSignup!(SignupData.fromSignupForm(
            name: auth.email,
            password: auth.password,
            additionalSignupData: auth.additionalSignupData,
            termsOfService: auth.getTermsOfServiceResults()));
        break;
    }

    await _submitController.reverse();
    if (!DartHelper.isNullOrEmpty(error)) {
      showErrorToast(context, messages.flushbarTitleError, error!);
      setState(() => _isSubmitting = false);
      return false;
    } else {
      /*showSuccessToast(context, messages.flushbarTitleSuccess,
          messages.signUpSuccess, const Duration(seconds: 4));
      setState(() => _isSubmitting = false);*/
      // await _loadingController.reverse();
      widget.onSubmitCompleted.call();
      return true;
    }
  }

  Widget _buildFields(double width) {
    return Column(
        children: widget.formFields.map((UserFormField formField) {
      return Column(
        children: [
          const SizedBox(
            height: 5,
          ),
          AnimatedTextFormField(
            controller: _nameControllers[formField.keyName],
            interval: _textFieldAnimationInterval,
            loadingController: _loadingController,
            width: width,
            labelText: formField.displayName,
            prefixIcon:
                formField.icon ?? const Icon(FontAwesomeIcons.solidUserCircle),
            keyboardType: TextFieldUtils.getKeyboardType(formField.userType),
            autofillHints: [
              TextFieldUtils.getAutofillHints(formField.userType)
            ],
            textInputAction: formField.keyName == widget.formFields.last.keyName
                ? TextInputAction.done
                : TextInputAction.next,
            validator: formField.fieldValidator,
          ),
          const SizedBox(
            height: 5,
          )
        ],
      );
    }).toList());
  }

  Widget _buildSubmitButton(ThemeData theme, LoginMessages messages) {
    return ScaleTransition(
      scale: _buttonScaleAnimation,
      child: AnimatedButton(
        controller: _submitController,
        text: messages.additionalSignUpSubmitButton,
        onPressed: !_isSubmitting ? _submit : null,
      ),
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
            key: _formCompleteSignupKey,
            child: Column(
              children: [
                ScaleTransition(
                  scale: _buttonScaleAnimation,
                  child: Text(
                    messages.additionalSignUpFormDescription,
                    key: kRecoverPasswordIntroKey,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyText2,
                  ),
                ),
                _buildFields(textFieldWidth),
                const SizedBox(height: 5),
                _buildSubmitButton(theme, messages),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
