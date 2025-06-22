import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:ksit_mobile/core/constants/app_routes.dart';
import 'package:ksit_mobile/core/constants/app_storages.dart';
import 'package:ksit_mobile/core/utils/api_error_utils.dart';
import 'package:ksit_mobile/core/utils/toast_utils.dart';
import 'package:ksit_mobile/features/auth/models/login_request/login_request_model.dart';
import 'package:ksit_mobile/features/auth/models/login_resposne/login_response_model.dart';
import 'package:ksit_mobile/features/auth/services/auth_service.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final StorageService _storageService = Get.find<StorageService>();

  // Observables
  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;
  final Rx<LoginResponseModel?> currentUser = Rx<LoginResponseModel?>(null);

  // Form controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // Form key
  final formKey = GlobalKey<FormState>();

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      // Create login request
      final loginRequest = LoginRequestModel(
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Call login API
      final loginResponse = await _authService.login(loginRequest);

      // Save user data to storage
      await _saveUserData(loginResponse);

      // Update observables
      currentUser.value = loginResponse;
      isLoggedIn.value = true;

      // Clear form
      _clearForm();

      // Show success message
      ToastUtils.showSuccess(
          'Login successful! Welcome ${loginResponse.username}');

      // Navigate to home
      if (Get.context != null) {
        Get.context!.go(AppRoutes.homeRoute);
      }
    } catch (e) {
      // Service already throws clean error message
      final errorMessage = ApiErrorUtils.extractApiErrorMessage(e);
      ToastUtils.showError(errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;

      // Call logout API
      final response = await _authService.logout();

      // Clear local data
      await _clearUserData();

      // Show success message from API response
      final message = response['message'] ?? 'Logged out successfully';
      ToastUtils.showSuccess(message);

      // Navigate to login
      if (Get.context != null) {
        Get.context!.go(AppRoutes.loginRoute);
      }
    } catch (e) {
      // Still clear local data even if API call fails
      await _clearUserData();

      // Service already throws clean error message
      final errorMessage = ApiErrorUtils.extractApiErrorMessage(e);
      ToastUtils.showError(errorMessage);

      if (Get.context != null) {
        Get.context!.go(AppRoutes.loginRoute);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getProfile() async {
    try {
      isLoading.value = true;

      final profileData = await _authService.getProfile();

      // Show success message
      final message = profileData['message'] ?? 'Profile updated successfully';
      ToastUtils.showSuccess(message);
    } catch (e) {
      // Service already throws clean error message
      final errorMessage = ApiErrorUtils.extractApiErrorMessage(e);
      ToastUtils.showError(errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _saveUserData(LoginResponseModel loginResponse) async {
    try {
      // Save access token
      await _storageService.setString(
        AppStorages.tokenKey,
        loginResponse.accessToken,
      );

      // Save user ID
      await _storageService.setString(
        AppStorages.userIdKey,
        loginResponse.userId.toString(),
      );

      // Save roles as JSON string
      await _storageService.setString(
        AppStorages.rolesKey,
        jsonEncode(loginResponse.roles),
      );

      // Save complete user data
      await _storageService.setString(
        AppStorages.userKey,
        jsonEncode(loginResponse.toJson()),
      );
    } catch (e) {
      throw Exception('Failed to save user data: ${e.toString()}');
    }
  }

  Future<void> _clearUserData() async {
    try {
      await _storageService.remove(AppStorages.tokenKey);
      await _storageService.remove(AppStorages.userKey);
      await _storageService.remove(AppStorages.userIdKey);
      await _storageService.remove(AppStorages.rolesKey);

      currentUser.value = null;
      isLoggedIn.value = false;
    } catch (e) {
      // Ignore storage errors during logout
    }
  }

  void _clearForm() {
    usernameController.clear();
    passwordController.clear();
  }

  // Validators
  String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
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
