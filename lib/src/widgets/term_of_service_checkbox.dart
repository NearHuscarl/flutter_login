import 'package:flutter/material.dart';
import 'package:flutter_login/src/models/term_of_service.dart';
import 'package:url_launcher/url_launcher.dart';

class TermCheckbox extends StatefulWidget {
  final TermOfService termOfService;

  const TermCheckbox({Key? key, required this.termOfService}) : super(key: key);

  @override
  _TermCheckboxState createState() => _TermCheckboxState();
}

class _TermCheckboxState extends State<TermCheckbox> {
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.termOfService.text,
                    style: Theme.of(context).textTheme.bodyText2,
                    textAlign: TextAlign.left,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.open_in_new,
                      color: Theme.of(context).textTheme.bodyText2!.color,
                      size: Theme.of(context).textTheme.bodyText2!.fontSize,
                    ),
                  )
                ],
              ),
            )
          : Text(
              widget.termOfService.text,
              style: Theme.of(context).textTheme.bodyText2,
              textAlign: TextAlign.left,
            ),
      validator: (bool? value) {
        if (widget.termOfService.mandatory == true &&
            widget.termOfService.getStatus() != true) {
          return widget.termOfService.validationErrorMessage;
        }
      },
    );
  }
}

class CheckboxFormField extends FormField<bool> {
  CheckboxFormField(
      {Key? key,
      required Widget title,
      required FormFieldValidator<bool> validator,
      String validationErrorMessage = '',
      bool initialValue = false,
      bool autoValidate = true,
      required ValueChanged<bool?> onChanged})
      : super(
            key: key,
            validator: validator,
            initialValue: initialValue,
            builder: (FormFieldState<bool> state) {
              return CheckboxListTile(
                dense: true,
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
