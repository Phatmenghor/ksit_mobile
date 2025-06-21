import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ksit_mobile/features/auth/models/login_resposne/login_response_model.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/logger_utils.dart';
import '../../../shared/models/user/user_model.dart';

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

      // Simulate login response since API is not available
      await Future.delayed(const Duration(seconds: 2));

      final mockResponse = LoginResponseModel(
        success: true,
        message: 'Login successful',
        data: LoginDataModel(
          token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
          user: UserModel(
            id: 1,
            name: 'John Doe',
            email: emailController.text.trim(),
            phone: '+1234567890',
            role: 'user',
          ),
        ),
      );

      if (mockResponse.success) {
        // Save token and user data
        await _storageService.setString(
          AppConstants.tokenKey,
          mockResponse.data!.token,
        );
        await _storageService.setString(
          AppConstants.userKey,
          jsonEncode(mockResponse.data!.user.toJson()),
        );

        // Update observables
        currentUser.value = mockResponse.data!.user;
        isLoggedIn.value = true;

        // Clear form
        _clearForm();

        // Navigate to home using GoRouter
        if (Get.context != null) {
          Get.context!.go(AppConstants.homeRoute);
        }

        Fluttertoast.showToast(
          msg: 'Login successful!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );

        LoggerUtils.info(
            'Login successful for user: ${mockResponse.data!.user.email}');
      } else {
        _showError(mockResponse.message);
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

      // Simulate logout API call
      await Future.delayed(const Duration(seconds: 1));

      // Clear local data
      await _clearUserData();

      // Navigate to login using GoRouter
      if (Get.context != null) {
        Get.context!.go(AppConstants.loginRoute);
      }

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
      if (Get.context != null) {
        Get.context!.go(AppConstants.loginRoute);
      }
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
