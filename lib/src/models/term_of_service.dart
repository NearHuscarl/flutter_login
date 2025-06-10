class TermOfService {
  TermOfService({
    required this.id,
    required this.mandatory,
    required this.text,
    this.linkUrl,
    this.initialValue = false,
    this.validationErrorMessage = 'Required',
  }) {
    checked = initialValue;
  }
  String id;
  bool mandatory;
  String text;
  String? linkUrl;
  String validationErrorMessage;
  bool initialValue;
  bool checked = false;

  @Deprecated('Please use [checked] instead of this setter.')
  // ignore: use_setters_to_change_properties
  void setStatus(
    // ignore: avoid_positional_boolean_parameters
    bool checked,
  ) {
    this.checked = checked;
  }

  @Deprecated('Please use [checked] instead of this getter.')
  bool getStatus() {
    return checked;
  }
}

class TermOfServiceResult {
  TermOfServiceResult({required this.term, required this.accepted});
  TermOfService term;
  bool accepted;
}
