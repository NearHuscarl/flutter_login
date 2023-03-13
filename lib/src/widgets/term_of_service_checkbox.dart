import 'package:flutter/material.dart';
import 'package:flutter_login/src/models/term_of_service.dart';
import 'package:url_launcher/url_launcher.dart';

class TermCheckbox extends StatefulWidget {
  final TermOfService termOfService;
  final bool validation;

  const TermCheckbox({
    super.key,
    required this.termOfService,
    this.validation = true,
  });

  @override
  State<TermCheckbox> createState() => _TermCheckboxState();
}

class _TermCheckboxState extends State<TermCheckbox> {
  @override
  Widget build(BuildContext context) {
    return CheckboxFormField(
      onChanged: (value) {
        widget.termOfService.checked = value ?? false;
      },
      initialValue: widget.termOfService.initialValue,
      title: widget.termOfService.linkUrl != null
          ? InkWell(
              onTap: () {
                launchUrl(Uri.parse(widget.termOfService.linkUrl!));
              },
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      widget.termOfService.text,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.open_in_new,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                      size: Theme.of(context).textTheme.bodyMedium!.fontSize,
                    ),
                  )
                ],
              ),
            )
          : Text(
              widget.termOfService.text,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.left,
            ),
      validator: (bool? value) {
        if (widget.validation &&
            widget.termOfService.mandatory &&
            !widget.termOfService.checked) {
          return widget.termOfService.validationErrorMessage;
        }
        return null;
      },
    );
  }
}

class CheckboxFormField extends FormField<bool> {
  CheckboxFormField({
    super.key,
    required Widget title,
    required FormFieldValidator<bool> super.validator,
    bool super.initialValue = false,
    required ValueChanged<bool?> onChanged,
  }) : super(
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
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    )
                  : null,
              controlAffinity: ListTileControlAffinity.leading,
            );
          },
        );
}
