/// Represents a single term of service item, typically used for user agreements.
class TermOfService {
  /// Creates a [TermOfService] instance.
  ///
  /// [id] is a unique identifier for the term.
  /// [mandatory] specifies if the term must be accepted.
  /// [text] is the display text for the term.
  /// [linkUrl] is an optional URL linking to more details.
  /// [initialValue] is the initial acceptance state (default is `false`).
  /// [validationErrorMessage] is the message to show if validation fails.
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

  /// Unique identifier for the term.
  String id;

  /// Indicates whether the term is required to be accepted.
  bool mandatory;

  /// Display text describing the term.
  String text;

  /// Optional URL pointing to the full term or related document.
  String? linkUrl;

  /// Message shown when a mandatory term is not accepted.
  String validationErrorMessage;

  /// Initial checked (accepted) state of the term.
  bool initialValue;

  /// Current checked (accepted) state of the term.
  bool checked = false;

  /// Deprecated: Use [checked] directly instead.
  ///
  /// Sets the checked state of the term.
  @Deprecated('Please use [checked] instead of this setter.')
  // ignore: use_setters_to_change_properties due to being deprecated
  void setStatus(
    // ignore: avoid_positional_boolean_parameters due to being deprecated
    bool checked,
  ) {
    this.checked = checked;
  }

  /// Deprecated: Use [checked] directly instead.
  ///
  /// Gets the checked state of the term.
  @Deprecated('Please use [checked] instead of this getter.')
  bool getStatus() {
    return checked;
  }
}

/// Represents the result of a user's response to a [TermOfService].
class TermOfServiceResult {
  /// Creates a [TermOfServiceResult].
  ///
  /// [term] is the associated term of service.
  /// [accepted] indicates whether the term was accepted by the user.
  TermOfServiceResult({
    required this.term,
    required this.accepted,
  });

  /// The term of service associated with this result.
  TermOfService term;

  /// Whether the term was accepted by the user.
  bool accepted;
}
