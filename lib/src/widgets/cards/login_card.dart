part of auth_card_builder;

class _LoginCard extends StatefulWidget {
  const _LoginCard({
    super.key,
    required this.loadingController,
    required this.userValidator,
    required this.validateUserImmediately,
    required this.passwordValidator,
    required this.onSwitchRecoveryPassword,
    required this.onSwitchSignUpAdditionalData,
    required this.userType,
    required this.requireAdditionalSignUpFields,
    required this.onSwitchConfirmSignup,
    required this.requireSignUpConfirmation,
    this.onSubmitCompleted,
    this.hideForgotPasswordButton = false,
    this.hideSignUpButton = false,
    this.loginAfterSignUp = true,
    this.hideProvidersTitle = false,
    this.introWidget,
  });

  final AnimationController loadingController;
  final FormFieldValidator<String>? userValidator;
  final bool? validateUserImmediately;
  final FormFieldValidator<String>? passwordValidator;
  final VoidCallback onSwitchRecoveryPassword;
  final VoidCallback onSwitchSignUpAdditionalData;
  final VoidCallback onSwitchConfirmSignup;
  final VoidCallback? onSubmitCompleted;
  final bool hideForgotPasswordButton;
  final bool hideSignUpButton;
  final bool loginAfterSignUp;
  final bool hideProvidersTitle;
  final LoginUserType userType;
  final bool requireAdditionalSignUpFields;
  final Future<bool> Function() requireSignUpConfirmation;
  final Widget? introWidget;

  @override
  _LoginCardState createState() => _LoginCardState();
}

class _LoginCardState extends State<_LoginCard> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final _userFieldKey = GlobalKey<FormFieldState>();
  final _userFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  late TextEditingController _nameController;
  late TextEditingController _passController;
  late TextEditingController _confirmPassController;

  var _isLoading = false;
  var _isSubmitting = false;
  var _showShadow = true;

  /// switch between login and signup
  late AnimationController _switchAuthController;
  late AnimationController _postSwitchAuthController;
  late AnimationController _submitController;

  ///list of AnimationController each one responsible for a authentication provider icon
  List<AnimationController> _providerControllerList = <AnimationController>[];

  Interval? _nameTextFieldLoadingAnimationInterval;
  Interval? _passTextFieldLoadingAnimationInterval;
  Interval? _textButtonLoadingAnimationInterval;
  late Animation<double> _buttonScaleAnimation;

  bool get buttonEnabled => !_isLoading && !_isSubmitting;

  @override
  void initState() {
    super.initState();

    final auth = Provider.of<Auth>(context, listen: false);
    _nameController = TextEditingController(text: auth.email);
    _passController = TextEditingController(text: auth.password);
    _confirmPassController = TextEditingController(text: auth.confirmPassword);

    widget.loadingController.addStatusListener(handleLoadingAnimationStatus);

    _switchAuthController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _postSwitchAuthController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _submitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _providerControllerList = auth.loginProviders
        .map(
          (e) => AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 1000),
          ),
        )
        .toList();

    _nameTextFieldLoadingAnimationInterval = const Interval(0, .85);
    _passTextFieldLoadingAnimationInterval = const Interval(.15, 1.0);
    _textButtonLoadingAnimationInterval =
        const Interval(.6, 1.0, curve: Curves.easeOut);
    _buttonScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.loadingController,
        curve: const Interval(.4, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _userFocusNode.addListener(() {
      if (!_userFocusNode.hasFocus &&
          (widget.validateUserImmediately ?? false)) {
        _userFieldKey.currentState?.validate();
      }
    });
  }

  void handleLoadingAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.forward) {
      setState(() => _isLoading = true);
    }
    if (status == AnimationStatus.completed) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    widget.loadingController.removeStatusListener(handleLoadingAnimationStatus);
    _userFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    _switchAuthController.dispose();
    _postSwitchAuthController.dispose();
    _submitController.dispose();

    for (final controller in _providerControllerList) {
      controller.dispose();
    }
    super.dispose();
  }

  void _switchAuthMode() {
    final auth = Provider.of<Auth>(context, listen: false);
    final newAuthMode = auth.switchAuth();

    if (newAuthMode == AuthMode.signup) {
      _switchAuthController.forward();
    } else {
      _switchAuthController.reverse();
    }
  }

  Future<bool> _submit() async {
    FocusScope.of(context).unfocus();

    final messages = Provider.of<LoginMessages>(context, listen: false);

    if (!_formKey.currentState!.validate()) {
      return false;
    }

    _formKey.currentState!.save();
    await _submitController.forward();
    setState(() => _isSubmitting = true);
    final auth = Provider.of<Auth>(context, listen: false);
    String? error;

    auth.authType = AuthType.userPassword;

    if (auth.isLogin) {
      error = await auth.onLogin?.call(
        LoginData(
          name: auth.email,
          password: auth.password,
        ),
      );
    } else {
      if (!widget.requireAdditionalSignUpFields) {
        error = await auth.onSignup!(
          SignupData.fromSignupForm(
            name: auth.email,
            password: auth.password,
            termsOfService: auth.getTermsOfServiceResults(),
          ),
        );
      } else {
        if (auth.beforeAdditionalFieldsCallback != null) {
          error = await auth.beforeAdditionalFieldsCallback!(
            SignupData.fromSignupForm(
              name: auth.email,
              password: auth.password,
              termsOfService: auth.getTermsOfServiceResults(),
            ),
          );
        }
      }
    }

    // workaround to run after _cardSizeAnimation in parent finished
    // need a cleaner way but currently it works so..
    Future.delayed(const Duration(milliseconds: 270), () {
      if (mounted) {
        setState(() => _showShadow = false);
      }
    });

    await _submitController.reverse();

    if (!DartHelper.isNullOrEmpty(error)) {
      showErrorToast(context, messages.flushbarTitleError, error!);
      Future.delayed(const Duration(milliseconds: 271), () {
        if (mounted) {
          setState(() => _showShadow = true);
        }
      });
      setState(() => _isSubmitting = false);
      return false;
    }

    if (auth.isSignup) {
      final requireSignUpConfirmation =
          await widget.requireSignUpConfirmation();
      if (widget.requireAdditionalSignUpFields) {
        widget.onSwitchSignUpAdditionalData();
        // The login page wil be shown in login mode (used if loginAfterSignUp disabled)
        _switchAuthMode();
        return false;
      } else if (requireSignUpConfirmation) {
        widget.onSwitchConfirmSignup();
        _switchAuthMode();
        return false;
      } else if (!widget.loginAfterSignUp) {
        showSuccessToast(
          context,
          messages.flushbarTitleSuccess,
          messages.signUpSuccess,
        );
        _switchAuthMode();
        setState(() => _isSubmitting = false);
        return false;
      }
    }
    TextInput.finishAutofillContext();
    widget.onSubmitCompleted?.call();

    return true;
  }

  Future<bool> _loginProviderSubmit({
    required LoginProvider loginProvider,
    AnimationController? control,
  }) async {
    if (!loginProvider.animated) {
      final String? error = await loginProvider.callback();

      final messages = Provider.of<LoginMessages>(context, listen: false);

      if (!DartHelper.isNullOrEmpty(error)) {
        showErrorToast(context, messages.flushbarTitleError, error!);
        return false;
      }

      return true;
    }

    await control?.forward();

    final auth = Provider.of<Auth>(context, listen: false);

    auth.authType = AuthType.provider;

    String? error;

    error = await loginProvider.callback();

    // workaround to run after _cardSizeAnimation in parent finished
    // need a cleaner way but currently it works so..
    Future.delayed(const Duration(milliseconds: 270), () {
      if (mounted) {
        setState(() => _showShadow = false);
      }
    });

    final messages = Provider.of<LoginMessages>(context, listen: false);

    if (!DartHelper.isNullOrEmpty(error)) {
      await control?.reverse();
      showErrorToast(context, messages.flushbarTitleError, error!);
      Future.delayed(const Duration(milliseconds: 271), () {
        if (mounted) {
          setState(() => _showShadow = true);
        }
      });
      return false;
    }

    final showSignupAdditionalFields =
        await loginProvider.providerNeedsSignUpCallback?.call() ?? false;

    if (showSignupAdditionalFields) {
      if (auth.beforeAdditionalFieldsCallback != null) {
        error = await auth.beforeAdditionalFieldsCallback!(
          SignupData.fromSignupForm(
            name: auth.email,
            password: auth.password,
            termsOfService: auth.getTermsOfServiceResults(),
            additionalSignupData: auth.additionalSignupData,
          ),
        );
        await control?.reverse();
        if (!DartHelper.isNullOrEmpty(error)) {
          showErrorToast(context, messages.flushbarTitleError, error!);
          Future.delayed(const Duration(milliseconds: 271), () {
            if (mounted) {
              setState(() => _showShadow = true);
            }
          });
          return false;
        }
      }
      await control?.reverse();
      widget.onSwitchSignUpAdditionalData();
    } else {
      widget.onSubmitCompleted!();
    }
    await control?.reverse();
    widget.onSubmitCompleted!();
    return true;
  }

  Widget _buildUserField(
    double width,
    LoginMessages messages,
    Auth auth,
  ) {
    return AnimatedTextFormField(
      textFormFieldKey: _userFieldKey,
      userType: widget.userType,
      controller: _nameController,
      width: width,
      loadingController: widget.loadingController,
      interval: _nameTextFieldLoadingAnimationInterval,
      labelText:
          messages.userHint ?? TextFieldUtils.getLabelText(widget.userType),
      autofillHints: _isSubmitting
          ? null
          : [TextFieldUtils.getAutofillHints(widget.userType)],
      prefixIcon: TextFieldUtils.getPrefixIcon(widget.userType),
      keyboardType: TextFieldUtils.getKeyboardType(widget.userType),
      textInputAction: TextInputAction.next,
      focusNode: _userFocusNode,
      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(_passwordFocusNode);
      },
      validator: widget.userValidator,
      onSaved: (value) => auth.email = value!,
      enabled: !_isSubmitting,
    );
  }

  Widget _buildPasswordField(double width, LoginMessages messages, Auth auth) {
    return AnimatedPasswordTextFormField(
      animatedWidth: width,
      loadingController: widget.loadingController,
      interval: _passTextFieldLoadingAnimationInterval,
      labelText: messages.passwordHint,
      autofillHints: _isSubmitting
          ? null
          : (auth.isLogin
              ? [AutofillHints.password]
              : [AutofillHints.newPassword]),
      controller: _passController,
      textInputAction:
          auth.isLogin ? TextInputAction.done : TextInputAction.next,
      focusNode: _passwordFocusNode,
      onFieldSubmitted: (value) {
        if (auth.isLogin) {
          _submit();
        } else {
          // SignUp
          FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
        }
      },
      validator: widget.passwordValidator,
      onSaved: (value) => auth.password = value!,
      enabled: !_isSubmitting,
    );
  }

  Widget _buildConfirmPasswordField(
    double width,
    LoginMessages messages,
    Auth auth,
  ) {
    return AnimatedPasswordTextFormField(
      animatedWidth: width,
      enabled: auth.isSignup,
      loadingController: widget.loadingController,
      inertiaController: _postSwitchAuthController,
      inertiaDirection: TextFieldInertiaDirection.right,
      labelText: messages.confirmPasswordHint,
      controller: _confirmPassController,
      textInputAction: TextInputAction.done,
      focusNode: _confirmPasswordFocusNode,
      onFieldSubmitted: (value) => _submit(),
      validator: auth.isSignup
          ? (value) {
              if (value != _passController.text) {
                return messages.confirmPasswordError;
              }
              return null;
            }
          : (value) => null,
      onSaved: (value) => auth.confirmPassword = value!,
    );
  }

  Widget _buildForgotPassword(ThemeData theme, LoginMessages messages) {
    return FadeIn(
      controller: widget.loadingController,
      fadeDirection: FadeDirection.bottomToTop,
      offset: .5,
      curve: _textButtonLoadingAnimationInterval,
      child: TextButton(
        onPressed: buttonEnabled
            ? () {
                // save state to populate email field on recovery card
                _formKey.currentState!.save();
                widget.onSwitchRecoveryPassword();
              }
            : null,
        child: Text(
          messages.forgotPasswordButton,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  Widget _buildSubmitButton(
    ThemeData theme,
    LoginMessages messages,
    Auth auth,
  ) {
    return ScaleTransition(
      scale: _buttonScaleAnimation,
      child: AnimatedButton(
        controller: _submitController,
        text: auth.isLogin ? messages.loginButton : messages.signupButton,
        onPressed: () => _submit(),
      ),
    );
  }

  Widget _buildSwitchAuthButton(
    ThemeData theme,
    LoginMessages messages,
    Auth auth,
    LoginTheme loginTheme,
  ) {
    final calculatedTextColor =
        (theme.cardTheme.color!.computeLuminance() < 0.5)
            ? Colors.white
            : theme.primaryColor;
    return FadeIn(
      controller: widget.loadingController,
      offset: .5,
      curve: _textButtonLoadingAnimationInterval,
      fadeDirection: FadeDirection.topToBottom,
      child: MaterialButton(
        disabledTextColor: theme.primaryColor,
        onPressed: buttonEnabled ? _switchAuthMode : null,
        padding: loginTheme.authButtonPadding ??
            const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textColor: loginTheme.switchAuthTextColor ?? calculatedTextColor,
        child: AnimatedText(
          text: auth.isSignup ? messages.loginButton : messages.signupButton,
          textRotation: AnimatedTextRotation.down,
        ),
      ),
    );
  }

  // Widget _buildProvidersLogInButton(ThemeData theme, LoginMessages messages,
  //     Auth auth, LoginTheme loginTheme) {
  //   return Row(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: auth.loginProviders.map((loginProvider) {
  //         var index = auth.loginProviders.indexOf(loginProvider);
  //         return Padding(
  //           padding: loginTheme.providerButtonPadding ??
  //               const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
  //           child: ScaleTransition(
  //             scale: _buttonScaleAnimation,
  //             child: Column(
  //               children: [
  //                 AnimatedIconButton(
  //                   icon: loginProvider.icon,
  //                   controller: _providerControllerList[index],
  //                   tooltip: '',
  //                   onPressed: () => _loginProviderSubmit(
  //                     animationController: _providerControllerList[index],
  //                     loginProvider: loginProvider,
  //                   ),
  //                 ),
  //                 Text(loginProvider.label),
  //               ],
  //             ),
  //           ),
  //         );
  //       }).toList());
  // }

  Widget _buildProvidersLogInButton(
    ThemeData theme,
    LoginMessages messages,
    Auth auth,
    LoginTheme loginTheme,
  ) {
    final buttonProvidersList = <LoginProvider>[];
    final iconProvidersList = <LoginProvider>[];
    for (final loginProvider in auth.loginProviders) {
      if (loginProvider.button != null) {
        buttonProvidersList.add(
          LoginProvider(
            icon: loginProvider.icon,
            label: loginProvider.label,
            button: loginProvider.button,
            callback: loginProvider.callback,
            animated: loginProvider.animated,
            providerNeedsSignUpCallback:
                loginProvider.providerNeedsSignUpCallback,
          ),
        );
      } else if (loginProvider.icon != null) {
        iconProvidersList.add(
          LoginProvider(
            icon: loginProvider.icon,
            label: loginProvider.label,
            button: loginProvider.button,
            callback: loginProvider.callback,
            animated: loginProvider.animated,
            providerNeedsSignUpCallback:
                loginProvider.providerNeedsSignUpCallback,
          ),
        );
      }
    }
    if (buttonProvidersList.isNotEmpty) {
      return Column(
        children: [
          _buildButtonColumn(theme, messages, buttonProvidersList, loginTheme),
          if (iconProvidersList.isNotEmpty)
            _buildProvidersTitleSecond(messages)
          else
            Container(),
          _buildIconRow(theme, messages, iconProvidersList, loginTheme),
        ],
      );
    } else if (iconProvidersList.isNotEmpty) {
      return _buildIconRow(theme, messages, iconProvidersList, loginTheme);
    }
    return Container();
  }

  Widget _buildButtonColumn(
    ThemeData theme,
    LoginMessages messages,
    List<LoginProvider> buttonProvidersList,
    LoginTheme loginTheme,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: buttonProvidersList.map((loginProvider) {
        return Padding(
          padding: loginTheme.providerButtonPadding ??
              const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
          child: ScaleTransition(
            scale: _buttonScaleAnimation,
            child: SignInButton(
              loginProvider.button!,
              onPressed: () => _loginProviderSubmit(
                loginProvider: loginProvider,
              ),
              text: loginProvider.label,
            ),
            // child: loginProvider.button,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIconRow(
    ThemeData theme,
    LoginMessages messages,
    List<LoginProvider> iconProvidersList,
    LoginTheme loginTheme,
  ) {
    return Wrap(
      children: iconProvidersList.map((loginProvider) {
        final index = iconProvidersList.indexOf(loginProvider);
        return Padding(
          padding: loginTheme.providerButtonPadding ??
              const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
          child: ScaleTransition(
            scale: _buttonScaleAnimation,
            child: Column(
              children: [
                AnimatedIconButton(
                  color: Colors.transparent,
                  icon: loginProvider.icon!,
                  controller: _providerControllerList[index],
                  tooltip: loginProvider.label,
                  onPressed: () => _loginProviderSubmit(
                    control: _providerControllerList[index],
                    loginProvider: loginProvider,
                  ),
                ),
                Text(loginProvider.label)
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProvidersTitleFirst(LoginMessages messages) {
    return ScaleTransition(
      scale: _buttonScaleAnimation,
      child: Row(
        children: <Widget>[
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(messages.providersTitleFirst),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  Widget _buildProvidersTitleSecond(LoginMessages messages) {
    return ScaleTransition(
      scale: _buttonScaleAnimation,
      child: Row(
        children: <Widget>[
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(messages.providersTitleSecond),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    final isLogin = auth.isLogin;
    final messages = Provider.of<LoginMessages>(context, listen: false);
    final loginTheme = Provider.of<LoginTheme>(context, listen: false);
    final theme = Theme.of(context);
    final cardWidth = min(MediaQuery.of(context).size.width * 0.75, 360.0);
    const cardPadding = 16.0;
    final textFieldWidth = cardWidth - cardPadding * 2;
    final authForm = Form(
      key: _formKey,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(
              left: cardPadding,
              right: cardPadding,
              top: cardPadding + 10,
            ),
            width: cardWidth,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (widget.introWidget != null) widget.introWidget!,
                  _buildUserField(textFieldWidth, messages, auth),
                  const SizedBox(height: 20),
                  _buildPasswordField(textFieldWidth, messages, auth),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          ExpandableContainer(
            backgroundColor: _switchAuthController.isCompleted
                ? null
                : theme.colorScheme.secondary,
            controller: _switchAuthController,
            initialState: isLogin
                ? ExpandableContainerState.shrunk
                : ExpandableContainerState.expanded,
            alignment: Alignment.topLeft,
            color: theme.cardTheme.color,
            width: cardWidth,
            padding: const EdgeInsets.symmetric(horizontal: cardPadding),
            onExpandCompleted: () => _postSwitchAuthController.forward(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: _buildConfirmPasswordField(
                    textFieldWidth,
                    messages,
                    auth,
                  ),
                ),
                for (var e in auth.termsOfService)
                  TermCheckbox(
                    termOfService: e,
                    validation: auth.isSignup,
                  ),
              ],
            ),
          ),
          Container(
            padding: Paddings.fromRBL(cardPadding),
            width: cardWidth,
            child: Column(
              children: <Widget>[
                if (!widget.hideForgotPasswordButton)
                  _buildForgotPassword(theme, messages)
                else
                  SizedBox.fromSize(
                    size: const Size.fromHeight(16),
                  ),
                _buildSubmitButton(theme, messages, auth),
                if (!widget.hideSignUpButton)
                  _buildSwitchAuthButton(theme, messages, auth, loginTheme)
                else
                  SizedBox.fromSize(
                    size: const Size.fromHeight(10),
                  ),
                if (auth.loginProviders.isNotEmpty &&
                    !widget.hideProvidersTitle)
                  _buildProvidersTitleFirst(messages)
                else
                  Container(),
                _buildProvidersLogInButton(theme, messages, auth, loginTheme),
              ],
            ),
          ),
        ],
      ),
    );

    return FittedBox(
      child: Card(
        elevation: _showShadow ? theme.cardTheme.elevation : 0,
        child: authForm,
      ),
    );
  }
}
