class AppConstants {
  // App Info
  static const String appName = 'Flutter App';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String fcmTokenKey = 'fcm_token';
  static const String isFirstTimeKey = 'is_first_time';

  // Routes
  static const String splashRoute = '/splash';
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';
  static const String scanRoute = '/scan';
  static const String requestRoute = '/request';
  static const String profileRoute = '/profile';

  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;

  // Firebase
  static const String fcmTopic = 'all_users';

  // API Endpoints (relative paths)
  static const String loginEndpoint = '/auth/login';
  static const String logoutEndpoint = '/auth/logout';
  static const String profileEndpoint = '/auth/profile';
  static const String homeDataEndpoint = '/home/data';
  static const String requestsEndpoint = '/requests';
  static const String notificationsEndpoint = '/notifications';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;

  // UI
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 8.0;

  // Animation Duration
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 3);
}
