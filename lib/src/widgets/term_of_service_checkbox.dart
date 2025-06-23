import 'package:flutter/material.dart';
import 'package:flutter_login/src/models/term_of_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// A checkbox widget used for displaying and accepting a single [TermOfService].
///
/// This widget is typically used during signup flows where users must agree
/// to terms such as privacy policies or license agreements.
class TermCheckbox extends StatefulWidget {
  /// Creates a [TermCheckbox] that displays a [CheckboxListTile] for the given [TermOfService].
  ///
  /// The [termOfService] must not be null.
  /// The [validation] flag indicates whether this checkbox is mandatory for validation.
  const TermCheckbox({
    required this.termOfService,
    super.key,
    this.validation = true,
  });

  /// The [TermOfService] instance representing the text, URL, and state
  /// of acceptance for this checkbox.
  final TermOfService termOfService;

  /// Whether this term must be accepted for validation to succeed.
  ///
  /// Defaults to `true`. If set to `false`, the checkbox is optional.
  final bool validation;

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
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.open_in_new,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                      size: Theme.of(context).textTheme.bodyMedium!.fontSize,
                    ),
                  ),
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

/// A [FormField] that contains a [CheckboxListTile] widget.
///
/// This widget integrates with form validation and saves its boolean value.
class CheckboxFormField extends FormField<bool> {
  /// Creates a checkbox form field.
  ///
  /// [title] is the widget shown next to the checkbox (typically a [Text]).
  /// [validator] is the validation function for form integration.
  /// [onChanged] is called whenever the checkbox value changes.
  ///
  /// [initialValue] defaults to `false`.
  CheckboxFormField({
    required Widget title,
    required FormFieldValidator<bool> super.validator,
    required ValueChanged<bool?> onChanged,
    super.key,
    bool super.initialValue = false,
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
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    )
                  : null,
              controlAffinity: ListTileControlAffinity.leading,
            );
          },
        );
}
