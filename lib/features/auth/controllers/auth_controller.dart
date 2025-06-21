import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ksit_mobile/features/auth/models/login_request/login_request_model.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/logger_utils.dart';
import '../../../shared/models/user/user_model.dart';
import '../models/login_resposne/login_response_model.dart';

class AuthController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  // Observables
  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Form key
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void _checkLoginStatus() {
    final token = _storageService.getString(AppConstants.tokenKey);
    final userJson = _storageService.getString(AppConstants.userKey);

    if (token != null && userJson != null) {
      try {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        currentUser.value = UserModel.fromJson(userMap);
        isLoggedIn.value = true;
        LoggerUtils.info('User is already logged in');
      } catch (e) {
        LoggerUtils.error('Error parsing stored user data', e);
        _clearUserData();
      }
    }
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final request = LoginRequestModel(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final response = await _apiService.post<Map<String, dynamic>>(
        AppConstants.loginEndpoint,
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final loginResponse = LoginResponseModel.fromJson(response.data!);

        if (loginResponse.success) {
          // Save token and user data
          await _storageService.setString(
            AppConstants.tokenKey,
            loginResponse.data!.token,
          );
          await _storageService.setString(
            AppConstants.userKey,
            jsonEncode(loginResponse.data!.user.toJson()),
          );

          // Update observables
          currentUser.value = loginResponse.data!.user;
          isLoggedIn.value = true;

          // Clear form
          _clearForm();

          // Navigate to home
          Get.offAllNamed(AppConstants.homeRoute);

          Fluttertoast.showToast(
            msg: 'Login successful!',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );

          LoggerUtils.info(
              'Login successful for user: ${loginResponse.data!.user.email}');
        } else {
          _showError(loginResponse.message);
        }
      } else {
        _showError('Login failed. Please try again.');
      }
    } catch (e) {
      LoggerUtils.error('Login error', e);
      _showError('An error occurred. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;

      // Call logout API
      await _apiService.post(AppConstants.logoutEndpoint);

      // Clear local data
      await _clearUserData();

      // Navigate to login
      Get.offAllNamed(AppConstants.loginRoute);

      Fluttertoast.showToast(
        msg: 'Logged out successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      LoggerUtils.info('User logged out successfully');
    } catch (e) {
      LoggerUtils.error('Logout error', e);
      // Still clear local data even if API call fails
      await _clearUserData();
      Get.offAllNamed(AppConstants.loginRoute);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _clearUserData() async {
    await _storageService.remove(AppConstants.tokenKey);
    await _storageService.remove(AppConstants.userKey);
    currentUser.value = null;
    isLoggedIn.value = false;
  }

  void _clearForm() {
    emailController.clear();
    passwordController.clear();
  }

  void _showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  // Validators
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    return null;
  }
}
