

import 'package:flutter/material.dart';

class TermCheck extends StatelessWidget {
  final  ValueChanged<bool?> onChanged;
  final bool value;
  final String text;
  const TermCheck({Key? key, required this.onChanged, required this.text, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(value: value, onChanged: onChanged, title: Text(
      text,
      style: Theme.of(context).textTheme.bodyText2,
      textAlign: TextAlign.left,
    ),);
  }
}
