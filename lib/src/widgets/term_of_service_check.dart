import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../flutter_login.dart';

class TermCheck extends StatefulWidget {
  final TermOfService termOfService;

  const TermCheck(
      {Key? key, required this.termOfService})
      : super(key: key);

  @override
  _TermCheckState createState() => _TermCheckState();
}

class _TermCheckState extends State<TermCheck> {
  @override
  Widget build(BuildContext context) {
    return CheckboxFormField(
      onChanged: (value) => widget.termOfService.setStatus(value!),
      initialValue: widget.termOfService.initialValue,
      title: widget.termOfService.linkUrl != null
          ? InkWell(
              onTap: () {
                launch(widget.termOfService.linkUrl!);
              },
              child: Text(
                widget.termOfService.text,
                style: Theme.of(context).textTheme.bodyText2,
                textAlign: TextAlign.left,
              ),
            )
          : Text(
              widget.termOfService.text,
              style: Theme.of(context).textTheme.bodyText2,
              textAlign: TextAlign.left,
            ),
      validator: (bool? value) {
        if (widget.termOfService.required == true && widget.termOfService.getStatus() != true) {
          return widget.termOfService.validationErrorMessage;
        }
      },
    );
  }
}

class CheckboxFormField extends FormField<bool> {
  CheckboxFormField(
      {required Widget title,
      required FormFieldValidator<bool> validator,
      String validationErrorMessage = '',
      bool initialValue = false,
      bool autovalidate = false,
      required ValueChanged<bool?> onChanged})
      : super(
            validator: validator,
            initialValue: initialValue,
            builder: (FormFieldState<bool> state) {
              return CheckboxListTile(
                dense: state.hasError,
                title: title,
                value: state.value,
                onChanged: (value) {
                  onChanged(value);
                  state.didChange(value);
                },
                subtitle: state.hasError
                    ? Builder(
                        builder: (BuildContext context) => Text(
                          state.errorText!,
                          style: TextStyle(color: Theme.of(context).errorColor),
                        ),
                      )
                    : null,
                controlAffinity: ListTileControlAffinity.leading,
              );
            });
}
