typedef ConfirmationCodeListener = void Function(String code);

class ConfirmationListeners {
  static final instance = ConfirmationListeners._();

  ConfirmationListeners._();

  final List<ConfirmationCodeListener> _confirmationCodeListeners = [];
  String? _lastCode;

  void register(ConfirmationCodeListener listener) {
    _confirmationCodeListeners.add(listener);
    if (_lastCode != null) {
      listener.call(_lastCode!);
    }
  }

  void forEach(void Function(ConfirmationCodeListener) fun) {
    _confirmationCodeListeners.forEach(fun);
  }

  void clear() {
    _confirmationCodeListeners.clear();
  }
}
