import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:ksit_mobile/features/requet/screens/request_screen.dart';

import '../core/constants/app_constants.dart';
import '../core/services/storage_service.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/scan/screens/scan_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../shared/screens/splash_screen.dart';
import '../shared/screens/main_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppConstants.splashRoute,
    redirect: _redirect,
    routes: [
      // Splash Screen
      GoRoute(
        path: AppConstants.splashRoute,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: AppConstants.loginRoute,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Main App Routes with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(
            path: AppConstants.homeRoute,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppConstants.scanRoute,
            name: 'scan',
            builder: (context, state) => const ScanScreen(),
          ),
          GoRoute(
            path: AppConstants.requestRoute,
            name: 'request',
            builder: (context, state) => const RequestScreen(),
          ),
          GoRoute(
            path: AppConstants.profileRoute,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppConstants.homeRoute),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );

  static String? _redirect(BuildContext context, GoRouterState state) {
    final storageService = Get.find<StorageService>();
    final isLoggedIn = storageService.getString(AppConstants.tokenKey) != null;
    final currentLocation = state.fullPath;

    // If on splash screen, don't redirect
    if (currentLocation == AppConstants.splashRoute) {
      return null;
    }

    // If not logged in and trying to access protected routes
    if (!isLoggedIn && _isProtectedRoute(currentLocation)) {
      return AppConstants.loginRoute;
    }

    // If logged in and trying to access auth routes
    if (isLoggedIn && _isAuthRoute(currentLocation)) {
      return AppConstants.homeRoute;
    }

    return null;
  }

  static bool _isProtectedRoute(String? path) {
    if (path == null) return false;

    final protectedRoutes = [
      AppConstants.homeRoute,
      AppConstants.scanRoute,
      AppConstants.requestRoute,
      AppConstants.profileRoute,
    ];

    return protectedRoutes.contains(path);
  }

  static bool _isAuthRoute(String? path) {
    if (path == null) return false;

    final authRoutes = [
      AppConstants.loginRoute,
    ];

    return authRoutes.contains(path);
  }
}
