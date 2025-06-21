import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import 'logger_utils.dart';
import 'network_utils.dart';

class ErrorHandler {
  // Handle API errors
  static Future<void> handleApiError(DioException error) async {
    String message = 'An unexpected error occurred';

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;

      case DioExceptionType.badResponse:
        message =
            _handleHttpError(error.response?.statusCode, error.response?.data);
        break;

      case DioExceptionType.cancel:
        message = 'Request was cancelled';
        break;

      case DioExceptionType.unknown:
        if (!await NetworkUtils.hasInternetConnection()) {
          message =
              'No internet connection. Please check your network settings.';
        } else {
          message = 'Network error occurred. Please try again.';
        }
        break;

      default:
        message = 'Something went wrong. Please try again.';
    }

    LoggerUtils.error('API Error: $message', error);
    _showErrorToast(message);
  }

  // Handle HTTP status errors
  static String _handleHttpError(int? statusCode, dynamic responseData) {
    switch (statusCode) {
      case 400:
        return _extractErrorMessage(responseData) ??
            'Invalid request. Please check your input.';
      case 401:
        return 'Authentication failed. Please login again.';
      case 403:
        return 'Access denied. You don\'t have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 422:
        return _extractValidationErrors(responseData) ??
            'Validation failed. Please check your input.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Server error occurred. Please try again later.';
      case 502:
      case 503:
      case 504:
        return 'Service temporarily unavailable. Please try again later.';
      default:
        return 'Request failed with status code $statusCode';
    }
  }

  // Extract error message from response
  static String? _extractErrorMessage(dynamic responseData) {
    if (responseData == null) return null;

    if (responseData is Map<String, dynamic>) {
      // Try different common error message fields
      return responseData['message'] ??
          responseData['error'] ??
          responseData['detail'] ??
          responseData['error_description'];
    }

    if (responseData is String) {
      return responseData;
    }

    return null;
  }

  // Extract validation errors
  static String? _extractValidationErrors(dynamic responseData) {
    if (responseData == null) return null;

    if (responseData is Map<String, dynamic>) {
      final errors =
          responseData['errors'] ?? responseData['validation_errors'];

      if (errors is Map<String, dynamic>) {
        final errorMessages = <String>[];
        errors.forEach((field, messages) {
          if (messages is List) {
            errorMessages.addAll(messages.map((e) => e.toString()));
          } else {
            errorMessages.add(messages.toString());
          }
        });
        return errorMessages.join('\n');
      }

      if (errors is List) {
        return errors.join('\n');
      }
    }

    return null;
  }

  // Show error toast
  static void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // Show error dialog
  static void showErrorDialog(String title, String message) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Handle generic exceptions
  static void handleGenericError(dynamic error, {String? context}) {
    String message = 'An unexpected error occurred';

    if (error is FormatException) {
      message = 'Data format error. Please try again.';
    } else if (error is TypeError) {
      message = 'Data processing error. Please try again.';
    } else if (error is Exception) {
      message = error.toString().replaceFirst('Exception: ', '');
    }

    final contextMessage = context != null ? '$context: $message' : message;
    LoggerUtils.error(contextMessage, error);
    _showErrorToast(message);
  }

  // Handle validation errors with field-specific messages
  static void handleValidationErrors(Map<String, List<String>> errors) {
    final errorMessages = <String>[];
    errors.forEach((field, messages) {
      errorMessages.addAll(messages);
    });

    _showErrorToast(errorMessages.join('\n'));
  }

  // Check if error is network related
  static bool isNetworkError(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        (error.type == DioExceptionType.unknown &&
            error.error is SocketException);
  }

  // Check if error is authentication related
  static bool isAuthError(DioException error) {
    return error.response?.statusCode == 401;
  }

  // Check if error is server related
  static bool isServerError(DioException error) {
    final statusCode = error.response?.statusCode;
    return statusCode != null && statusCode >= 500;
  }

  // Get user-friendly error message
  static String getUserFriendlyMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timeout';
        case DioExceptionType.badResponse:
          return _handleHttpError(
              error.response?.statusCode, error.response?.data);
        case DioExceptionType.cancel:
          return 'Request cancelled';
        case DioExceptionType.unknown:
          return 'Network error';
        default:
          return 'Something went wrong';
      }
    }

    return 'An unexpected error occurred';
  }
}

// Custom exception classes
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message';
}

class ValidationException implements Exception {
  final Map<String, List<String>> errors;

  ValidationException(this.errors);

  @override
  String toString() => 'ValidationException: ${errors.toString()}';
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}
