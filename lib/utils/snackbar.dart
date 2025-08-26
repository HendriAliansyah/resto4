import 'package:flutter/material.dart';

/// Shows a customized SnackBar with a message and a color based on the action type.
///
/// [context] The BuildContext of the screen where the SnackBar will be shown.
/// [message] The text to display in the SnackBar.
/// [isError] A boolean to determine the color of the SnackBar.
///           `true` for red (error), `false` for green (success).
void showSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.redAccent : Colors.green,
    ),
  );
}
