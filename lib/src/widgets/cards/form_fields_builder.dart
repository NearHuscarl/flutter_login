part of auth_card_builder;

List<Widget> formFieldsBuilder(
    BuildContext context,
    List<UserFormField> formFields,
    _nameControllers,
    width,
    loadingController,
    _isSubmitting) {
  return formFields.map((UserFormField formField) {
    final messages = Provider.of<LoginMessages>(context, listen: false);
    final auth = Provider.of<Auth>(context, listen: true);
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        if (formField.userType == LoginUserType.password)
          AnimatedPasswordTextFormField(
            animatedWidth: width,
            loadingController: loadingController,
            labelText: messages.passwordHint,
            autofillHints: _isSubmitting
                ? null
                : (auth.isLogin
                    ? [AutofillHints.password]
                    : [AutofillHints.newPassword]),
            controller: _nameControllers[formField.keyName],
            textInputAction:
                auth.isLogin ? TextInputAction.done : TextInputAction.next,
            validator: formField.fieldValidator,
            onSaved: (value) => auth.password = value!,
            enabled: !_isSubmitting,
          ),
        if (formField.userType != LoginUserType.password)
          AnimatedTextFormField(
            controller: _nameControllers[formField.keyName],
            // interval: _fieldAnimationIntervals[widget.formFields.indexOf(formField)],
            loadingController: loadingController,
            width: width,
            labelText: formField.displayName,
            prefixIcon:
                formField.icon ?? const Icon(FontAwesomeIcons.solidUserCircle),
            keyboardType: TextFieldUtils.getKeyboardType(formField.userType),
            autofillHints: [
              TextFieldUtils.getAutofillHints(formField.userType)
            ],
            textInputAction: formField.keyName == formFields.last.keyName
                ? TextInputAction.done
                : TextInputAction.next,
            validator: formField.fieldValidator,
            enabled: !_isSubmitting,
          ),
        const SizedBox(
          height: 5,
        )
      ],
    );
  }).toList();
}
