import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class CustomSnackbar {
  static void showError(
      BuildContext context,
      String message, {
        String? title,
        Duration duration = const Duration(seconds: 3),
      }) {
    _show(
      context,
      title: title ?? 'Error!',
      message: message,
      contentType: ContentType.failure,
      duration: duration,
    );
  }

  static void showSuccess(
      BuildContext context,
      String message, {
        String? title,
        Duration duration = const Duration(seconds: 3),
      }) {
    _show(
      context,
      title: title ?? 'Success!',
      message: message,
      contentType: ContentType.success,
      duration: duration,
    );
  }

  static void showWarning(
      BuildContext context,
      String message, {
        String? title,
        Duration duration = const Duration(seconds: 3),
      }) {
    _show(
      context,
      title: title ?? 'Warning!',
      message: message,
      contentType: ContentType.warning,
      duration: duration,
    );
  }

  static void showInfo(
      BuildContext context,
      String message, {
        String? title,
        Duration duration = const Duration(seconds: 3),
      }) {
    _show(
      context,
      title: title ?? 'Info',
      message: message,
      contentType: ContentType.help,
      duration: duration,
    );
  }

  static void _show(
      BuildContext context, {
        required String title,
        required String message,
        required ContentType contentType,
        required Duration duration,
      }) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      duration: duration,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}