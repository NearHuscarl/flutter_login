import 'package:flutter/material.dart';

class FormFieldController extends ChangeNotifier {
  String? _value;

  String? get value {
    return _value;
  }

  set value(String? value) {
    _value = value;
    notifyListeners();
  }
}
