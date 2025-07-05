// lib/routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:ksit_mobile/core/constants/app_routes.dart';
import 'package:ksit_mobile/features/home/screens/schedule_detail_screen.dart';
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
      // Splash Screen
      GoRoute(
        path: AppRoutes.splashRoute,
        name: 'splash',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const SplashScreen(),
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, _, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // Auth Routes with AuthBinding
      GoRoute(
        path: AppRoutes.loginRoute,
        name: 'login',
        pageBuilder: (context, state) {
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: const LoginScreen(),
            transitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder: (context, animation, _, child) {
              return SlideTransition(
                position: animation.drive(
                  Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
                ),
                child: child,
              );
            },
          );
        },
      ),

      // Main App Routes with Bottom Navigation (No Transition)
      ShellRoute(
        navigatorKey: GlobalKey<NavigatorState>(),
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.homeRoute,
            name: 'home',
            pageBuilder: (context, state) => FadeTransitionPage<void>(
              key: state.pageKey,
              child: const HomeScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.scanRoute,
            name: 'scan',
            pageBuilder: (context, state) => FadeTransitionPage<void>(
              key: state.pageKey,
              child: const ScanScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.requestRoute,
            name: 'request',
            pageBuilder: (context, state) => FadeTransitionPage<void>(
              key: state.pageKey,
              child: const RequestScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.profileRoute,
            name: 'profile',
            pageBuilder: (context, state) => FadeTransitionPage<void>(
              key: state.pageKey,
              child: const ProfileScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.scheduleDetailRoute,
            name: 'schedule-detail',
            pageBuilder: (context, state) {
              // Get the schedule ID from query parameters
              final scheduleId = state.uri.queryParameters['id'];
              if (scheduleId == null) {
                // Redirect to home if no ID provided
                return FadeTransitionPage<void>(
                  key: state.pageKey,
                  child: Scaffold(
                    body: Center(
                      child: Text('Schedule not found'),
                    ),
                  ),
                );
              }

              return NoTransitionPage<void>(
                key: state.pageKey,
                child: ScheduleDetailScreen(scheduleId: int.parse(scheduleId)),
              );
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

// Custom page with subtle fade transition for bottom navigation
class FadeTransitionPage<T> extends Page<T> {
  const FadeTransitionPage({
    required this.child,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      pageBuilder: (context, animation, _) => child,
      transitionDuration:
          const Duration(milliseconds: 200), // Short fade duration
      reverseTransitionDuration:
          const Duration(milliseconds: 150), // Slightly faster reverse
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Subtle fade transition with easing
        return FadeTransition(
          opacity: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut, // Smooth easing
            ),
          ),
          child: child,
        );
      },
    );
  }
}

// Custom page with no transition for bottom navigation
class NoTransitionPage<T> extends Page<T> {
  const NoTransitionPage({
    required this.child,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      pageBuilder: (context, animation, _) => child,
      transitionDuration: Duration.zero, // No transition duration
      reverseTransitionDuration: Duration.zero, // No reverse transition
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child; // Return child directly without any transition
      },
    );
  }
}
