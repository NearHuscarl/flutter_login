import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

/// Returns the size of the widget associated with the given [key].
///
/// This function relies on the widget being mounted and rendered in the tree.
/// If the widget is not currently rendered, this will return `null`.
///
/// Example usage:
/// ```dart
/// final size = getWidgetSize(myGlobalKey);
/// ```
Size? getWidgetSize(GlobalKey key) {
  final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
  return renderBox?.size;
}

/// Shows a success-style [Flushbar] toast with a green gradient background.
///
/// - [context]: The [BuildContext] used to show the Flushbar.
/// - [title]: The title displayed at the top of the toast.
/// - [message]: The detailed message below the title.
/// - [duration]: Optional duration for how long the toast should stay visible. Defaults to 4 seconds.
///
/// Returns the displayed [Flushbar] instance.
Flushbar<void> showSuccessToast(
  BuildContext context,
  String title,
  String message, [
  Duration? duration,
]) {
  return Flushbar(
    title: title,
    message: message,
    icon: const Icon(
      Icons.check,
      size: 28,
      color: Colors.white,
    ),
    duration: duration ?? const Duration(seconds: 4),
    backgroundGradient: LinearGradient(
      colors: [Colors.green[600]!, Colors.green[400]!],
    ),
    onTap: (flushbar) => flushbar.dismiss(),
  )..show(context);
}

/// Shows an error-style [Flushbar] toast with a red gradient background.
///
/// - [context]: The [BuildContext] used to show the Flushbar.
/// - [title]: The title displayed at the top of the toast.
/// - [message]: The detailed message below the title.
///
/// Returns the displayed [Flushbar] instance.
Flushbar<void> showErrorToast(
  BuildContext context,
  String title,
  String message,
) {
  return Flushbar(
    title: title,
    message: message,
    icon: const Icon(
      Icons.error,
      size: 28,
      color: Colors.white,
    ),
    duration: const Duration(seconds: 4),
    backgroundGradient: LinearGradient(
      colors: [Colors.red[600]!, Colors.red[400]!],
    ),
    onTap: (flushbar) => flushbar.dismiss(),
  )..show(context);
}
