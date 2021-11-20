part of auth_card_builder;

List<Widget> formFieldsBuilder(List<UserFormField> formFields, _nameControllers,
    width, loadingController) {
  return formFields.map((UserFormField formField) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        AnimatedTextFormField(
          controller: _nameControllers[formField.keyName],
          // interval: _fieldAnimationIntervals[widget.formFields.indexOf(formField)],
          loadingController: loadingController,
          width: width,
          labelText: formField.displayName,
          prefixIcon:
          formField.icon ?? const Icon(FontAwesomeIcons.solidUserCircle),
          keyboardType: TextFieldUtils.getKeyboardType(formField.userType),
          autofillHints: [TextFieldUtils.getAutofillHints(formField.userType)],
          textInputAction: formField.keyName == formFields.last.keyName
              ? TextInputAction.done
              : TextInputAction.next,
          validator: formField.fieldValidator,
        ),
        const SizedBox(
          height: 5,
        )
      ],
    );
  }).toList();
}
