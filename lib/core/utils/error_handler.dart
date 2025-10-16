import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:dio/dio.dart';
import 'dart:developer';

import 'package:flutter/material.dart';

class ErrorHandler {
  static String handleError(dynamic error) {
    log('ErrorHandler: Processing error - ${error.toString()}');

    if (error is DioException) {
      log('DioException Type: ${error.type}');
      log('DioException Message: ${error.message}');
      log('Response Status Code: ${error.response?.statusCode}');
      log('Response Data: ${error.response?.data}');

      return _handleDioError(error);
    } else {
      log('General Exception: ${error.toString()}');
      return 'An unexpected error occurred';
    }
  }

  static String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        log('Connection timeout error');
        return 'Connection timeout. Please check your internet connection';

      case DioExceptionType.receiveTimeout:
        log('Receive timeout error');
        return 'Server response timeout. Please try again';

      case DioExceptionType.sendTimeout:
        log('Send timeout error');
        return 'Request timeout. Please try again';

      case DioExceptionType.badResponse:
        log('Bad response error: ${error.response?.statusCode}');
        return _handleStatusCode(
          error.response?.statusCode,
          error.response?.data,
        );

      case DioExceptionType.cancel:
        log('Request cancelled');
        return 'Request was cancelled';

      case DioExceptionType.connectionError:
        log('Connection error');
        return 'No internet connection. Please check your connection';

      case DioExceptionType.badCertificate:
        log('Bad certificate error');
        return 'Security certificate error';

      case DioExceptionType.unknown:
        log('Unknown DioException');
        return 'Network error occurred. Please try again';
    }
  }

  static String _handleStatusCode(int? statusCode, dynamic responseData) {
    log('Handling status code: $statusCode');
    log('Response data: $responseData');

    switch (statusCode) {
      case 400:
        return _extractErrorMessage(responseData) ??
            'Bad request. Please check your input';

      case 401:
        return _extractErrorMessage(responseData) ??
            'Invalid credentials. Please check your email and password';

      case 403:
        return _extractErrorMessage(responseData) ??
            'Access forbidden. You don\'t have permission';

      case 404:
        return _extractErrorMessage(responseData) ?? 'Service not found';

      case 422:
        return _extractErrorMessage(responseData) ??
            'Validation error. Please check your input';

      case 429:
        return 'Too many requests. Please try again later';

      case 500:
        return 'Server error. Please try again later';

      case 502:
        return 'Bad gateway. Server is temporarily unavailable';

      case 503:
        return 'Service unavailable. Please try again later';

      default:
        return _extractErrorMessage(responseData) ??
            'An error occurred. Please try again';
    }
  }

  static String? _extractErrorMessage(dynamic responseData) {
    log('Extracting error message from: $responseData');

    if (responseData is Map<String, dynamic>) {
      // Try different possible error message keys
      if (responseData.containsKey('message')) {
        log('Found message: ${responseData['message']}');
        return responseData['message']?.toString();
      }

      if (responseData.containsKey('error')) {
        log('Found error: ${responseData['error']}');
        return responseData['error']?.toString();
      }

      if (responseData.containsKey('errors')) {
        log('Found errors: ${responseData['errors']}');
        final errors = responseData['errors'];
        if (errors is Map<String, dynamic>) {
          // Get first error from validation errors
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          }
        }
        return errors.toString();
      }
    }

    log('No specific error message found');
    return null;
  }
}

void showErrorSnackbar(BuildContext context, String message) {
  final snackBar = SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    content: AwesomeSnackbarContent(
      title: 'Error!',
      message: message,
      contentType: ContentType.failure,
    ),
  );

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}

void showSuccessSnackbar(BuildContext context, String message) {
  final snackBar = SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    content: AwesomeSnackbarContent(
      title: 'Success!',
      message: message,
      contentType: ContentType.success,
    ),
  );

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}
