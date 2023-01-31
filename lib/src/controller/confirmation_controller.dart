import 'package:flutter_login/src/controller/confirmation_listeners.dart';

class ConfirmationController {
  void onNewCode(String code) {
    ConfirmationListeners.instance.forEach((l) => l.call(code));
  }
}
