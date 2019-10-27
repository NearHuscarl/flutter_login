import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

MaterialColor getMaterialColor(Color color) {
  return Colors.primaries.firstWhere(
    (c) => c.value == color.value,
    orElse: () => MaterialColor(
      color.value,
      <int, Color>{
        50: color,
        100: color,
        200: color,
        300: color,
        400: color,
        500: color,
        600: color,
        700: color,
        800: color,
        900: color,
      },
    ),
  );
}

Size getWidgetSize(GlobalKey key) {
  final RenderBox renderBox = key.currentContext?.findRenderObject();
  return renderBox?.size;
}

Flushbar showSuccessToast(BuildContext context, String message) {
  return Flushbar(
    title: 'Success',
    message: message,
    icon: Icon(
      Icons.check,
      size: 28.0,
      color: Colors.white,
    ),
    duration: const Duration(seconds: 4),
    backgroundGradient: LinearGradient(
      colors: [Colors.green[600], Colors.green[400]],
    ),
    onTap: (flushbar) => flushbar.dismiss(),
  )..show(context);
}

Flushbar showErrorToast(BuildContext context, String message) {
  return Flushbar(
    title: 'Error',
    message: message,
    icon: Icon(
      Icons.error,
      size: 28.0,
      color: Colors.white,
    ),
    duration: const Duration(seconds: 4),
    backgroundGradient: LinearGradient(
      colors: [Colors.red[600], Colors.red[400]],
    ),
    onTap: (flushbar) => flushbar.dismiss(),
  )..show(context);
}
