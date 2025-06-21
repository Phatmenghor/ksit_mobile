import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ksit_mobile/bindings/initial_bindings.dart';

import 'core/constants/app_colors.dart';
import 'core/services/firebase_service.dart';
import 'core/utils/logger_utils.dart';
import 'routes/app_router.dart';
import 'firebase_options.dart'; // This is the missing import!

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase with platform-specific options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    LoggerUtils.info('Firebase initialized successfully');

    // Initialize services
    await InitialBinding().dependencies();
    LoggerUtils.info('Initial bindings completed');

    // Initialize Firebase messaging
    await Get.find<FirebaseService>().initializeMessaging();
    LoggerUtils.info('Firebase messaging initialized');

    LoggerUtils.info('App started successfully');
  } catch (e) {
    LoggerUtils.error('Failed to initialize app: $e');
    // You might want to show an error screen or handle this differently
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'KSIT Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
      ),
      routerConfig: AppRouter.router,
    );
  }
}
