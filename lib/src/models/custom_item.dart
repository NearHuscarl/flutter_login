import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_login/src/widgets/animated_text_form_field.dart';

abstract class ItemBuilder {
  Widget build(BuildContext context, double textFieldWidth, List<dynamic> datas,
      int index);
  String get content;
}

class PureTextItem extends ItemBuilder {
  late TextEditingController controller;
  late AnimationController animationController;
  final String? labelText;
  final Icon? prefixIcon;
  final TextInputType? textInputType;
  final TextInputAction? textInputAction;
  late FocusNode focusNode;
  final FormFieldValidator<String>? validator;
  PureTextItem(
      {this.labelText,
      this.prefixIcon,
      this.textInputType,
      this.textInputAction,
      this.validator}) {
    focusNode = FocusNode();
    controller = TextEditingController();
  }
  @override
  Widget build(BuildContext context, double textFieldWidth, List<dynamic> datas,
      int index) {
    return AnimatedTextFormField(
      controller: controller,
      width: textFieldWidth,
      labelText: labelText,
      prefixIcon: prefixIcon,
      keyboardType: textInputType,
      textInputAction: textInputAction,
      onFieldSubmitted: (value) {
        FocusScope.of(context).requestFocus(focusNode);
      },
      onSaved: (value) {
        datas[index] = value!;
      },
      focusNode: focusNode,
      validator: validator,
    );
  }

  @override
  String get content => controller.text;
}
