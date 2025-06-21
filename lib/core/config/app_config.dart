enum Environment {
  development,
  staging,
  production,
}

class AppConfig {
  static Environment _environment = Environment.development;

  static Environment get environment => _environment;

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  // API Configuration
  static String get baseUrl {
    switch (_environment) {
      case Environment.development:
        return 'https://dev-api.example.com/api/v1';
      case Environment.staging:
        return 'https://staging-api.example.com/api/v1';
      case Environment.production:
        return 'https://api.example.com/api/v1';
    }
  }

  static String get socketUrl {
    switch (_environment) {
      case Environment.development:
        return 'wss://dev-socket.example.com';
      case Environment.staging:
        return 'wss://staging-socket.example.com';
      case Environment.production:
        return 'wss://socket.example.com';
    }
  }

  // Firebase Configuration
  static String get firebaseProjectId {
    switch (_environment) {
      case Environment.development:
        return 'your-project-dev';
      case Environment.staging:
        return 'your-project-staging';
      case Environment.production:
        return 'your-project-prod';
    }
  }

  // Feature Flags
  static bool get enableLogging {
    switch (_environment) {
      case Environment.development:
      case Environment.staging:
        return true;
      case Environment.production:
        return false;
    }
  }

  static bool get enableCrashReporting {
    switch (_environment) {
      case Environment.development:
        return false;
      case Environment.staging:
      case Environment.production:
        return true;
    }
  }

  static bool get enableAnalytics {
    switch (_environment) {
      case Environment.development:
        return false;
      case Environment.staging:
      case Environment.production:
        return true;
    }
  }

  // Timeouts
  static int get connectTimeout {
    switch (_environment) {
      case Environment.development:
        return 60000; // 60 seconds for dev
      case Environment.staging:
      case Environment.production:
        return 30000; // 30 seconds for prod
    }
  }

  static int get receiveTimeout {
    switch (_environment) {
      case Environment.development:
        return 60000;
      case Environment.staging:
      case Environment.production:
        return 30000;
    }
  }

  // Cache Configuration
  static Duration get cacheExpiration {
    switch (_environment) {
      case Environment.development:
        return const Duration(minutes: 5);
      case Environment.staging:
        return const Duration(minutes: 15);
      case Environment.production:
        return const Duration(hours: 1);
    }
  }

  // Pagination
  static int get defaultPageSize {
    return 10;
  }

  static int get maxPageSize {
    return 50;
  }

  // Security
  static bool get enableSSLPinning {
    switch (_environment) {
      case Environment.development:
        return false;
      case Environment.staging:
      case Environment.production:
        return true;
    }
  }

  // Debug Information
  static Map<String, dynamic> get debugInfo {
    return {
      'environment': _environment.name,
      'baseUrl': baseUrl,
      'enableLogging': enableLogging,
      'enableCrashReporting': enableCrashReporting,
      'enableAnalytics': enableAnalytics,
      'connectTimeout': connectTimeout,
      'receiveTimeout': receiveTimeout,
      'cacheExpiration': cacheExpiration.inMinutes,
      'enableSSLPinning': enableSSLPinning,
    };
  }

  // Initialize configuration
  static void initialize({Environment? environment}) {
    if (environment != null) {
      setEnvironment(environment);
    }

    // You can add more initialization logic here
    // such as setting up crash reporting, analytics, etc.
  }

  // Check if current environment is development
  static bool get isDevelopment => _environment == Environment.development;

  // Check if current environment is staging
  static bool get isStaging => _environment == Environment.staging;

  // Check if current environment is production
  static bool get isProduction => _environment == Environment.production;
}
