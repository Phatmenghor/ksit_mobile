import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:ksit_mobile/core/constants/app_constants.dart';
import 'package:ksit_mobile/core/constants/app_image.dart';
import 'package:ksit_mobile/core/constants/app_routes.dart';
import 'package:ksit_mobile/core/constants/app_storages.dart';
import 'package:ksit_mobile/core/services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _navigateToNextScreen();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(AppConstants.splashDuration);

    if (mounted) {
      final storageService = Get.find<StorageService>();
      final token = storageService.getString(AppStorages.tokenKey);

      if (token != null && token.isNotEmpty) {
        // User is logged in, navigate to home
        context.go(AppRoutes.homeRoute);
      } else {
        // User is not logged in, navigate to login
        context.go(AppRoutes.loginRoute);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.logoBg),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),

              // Loading indicator at bottom
              Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
