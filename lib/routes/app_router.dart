// lib/routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:ksit_mobile/core/constants/app_routes.dart';
import 'package:ksit_mobile/features/attandance/screens/attendance_history_screen.dart';
import 'package:ksit_mobile/features/home/screens/schedule_detail_screen.dart';
import 'package:ksit_mobile/features/profile/screens/change_password_screen.dart';
import 'package:ksit_mobile/features/profile/screens/configuration_screen.dart';
import 'package:ksit_mobile/features/profile/screens/edit_profile_screen.dart';
import 'package:ksit_mobile/features/profile/screens/profile_view_screen.dart';
import 'package:ksit_mobile/features/requet/screens/request_screen.dart';
import '../core/config/app_config.dart';
import '../core/services/storage_service.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/scan/screens/scan_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../shared/screens/splash_screen.dart';
import '../shared/screens/main_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: Get.key, // Use GetX navigator key
    initialLocation: AppRoutes.splashRoute,
    redirect: _redirect,
    routes: [
      // Splash Screen - No transition
      GoRoute(
        path: AppRoutes.splashRoute,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Login Screen - Standard slide transition
      GoRoute(
        path: AppRoutes.loginRoute,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Profile View Screen - Standard slide transition
      GoRoute(
        path: AppRoutes.profileViewRoute,
        name: 'profile-view',
        builder: (context, state) => const StduentViewScreen(),
      ),

      // Profile View Screen - Standard slide transition
      GoRoute(
        path: AppRoutes.editProfileRoute,
        name: 'edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),

      GoRoute(
        path: AppRoutes.configurationRoute,
        name: 'configuration',
        builder: (context, state) => const ConfigurationScreen(),
      ),

      GoRoute(
        path: AppRoutes.changePasswordRoute,
        name: 'change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),

      GoRoute(
        path: AppRoutes.attendanceHistoryRoute,
        name: 'attendance-history',
        builder: (context, state) => const AttendanceHistoryScreen(),
      ),

      // Main App Routes with Bottom Navigation
      ShellRoute(
        navigatorKey: GlobalKey<NavigatorState>(),
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.homeRoute,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.scanRoute,
            name: 'scan',
            builder: (context, state) => const ScanScreen(),
          ),
          GoRoute(
            path: AppRoutes.requestRoute,
            name: 'request',
            builder: (context, state) => const RequestScreen(),
          ),
          GoRoute(
            path: AppRoutes.profileRoute,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: AppRoutes.scheduleDetailRoute,
            name: 'schedule-detail',
            builder: (context, state) {
              // Get the schedule ID from query parameters
              final scheduleId = state.uri.queryParameters['id'];
              if (scheduleId == null) {
                // Redirect to home if no ID provided
                return const Scaffold(
                  body: Center(
                    child: Text('Schedule not found'),
                  ),
                );
              }

              return ScheduleDetailScreen(scheduleId: int.parse(scheduleId));
            },
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
              onPressed: () => context.go(AppRoutes.homeRoute),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );

  static String? _redirect(BuildContext context, GoRouterState state) {
    final storageService = Get.find<StorageService>();
    final token = storageService.getString(AppConfig.tokenKey);
    final isLoggedIn = token != null && token.isNotEmpty;
    final currentLocation = state.fullPath;

    // If on splash screen, don't redirect
    if (currentLocation == AppRoutes.splashRoute) {
      return null;
    }

    // If not logged in and trying to access protected routes
    if (!isLoggedIn && _isProtectedRoute(currentLocation)) {
      return AppRoutes.loginRoute;
    }

    // If logged in and trying to access auth routes
    if (isLoggedIn && _isAuthRoute(currentLocation)) {
      return AppRoutes.homeRoute;
    }

    return null;
  }

  static bool _isProtectedRoute(String? path) {
    if (path == null) return false;

    final protectedRoutes = [
      AppRoutes.homeRoute,
      AppRoutes.scanRoute,
      AppRoutes.requestRoute,
      AppRoutes.profileRoute,
    ];

    return protectedRoutes.contains(path);
  }

  static bool _isAuthRoute(String? path) {
    if (path == null) return false;

    final authRoutes = [
      AppRoutes.loginRoute,
    ];

    return authRoutes.contains(path);
  }
}
