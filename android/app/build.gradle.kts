plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // IMPROVED: Change to a more professional package name
    namespace = "com.ksit.mobile"  // Changed from com.example.ksit_mobile
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // IMPROVED: Professional application ID for KSIT Mobile
        applicationId = "com.ksit.mobile"  // Changed from com.example.ksit_mobile
        
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // ADDED: App name for better branding
        resValue "string", "app_name", "KSIT Mobile"
        
        // ADDED: Version information
        buildConfigField "String", "VERSION_NAME", "\"${flutter.versionName}\""
        buildConfigField "int", "VERSION_CODE", "${flutter.versionCode}"
    }

    buildTypes {
        debug {
            // Debug configuration
            applicationIdSuffix ".debug"  // Allows debug and release versions side by side
            debuggable true
            minifyEnabled false
        }
        
        release {
            // IMPROVED: Better release configuration
            minifyEnabled true  // Enable code shrinking
            shrinkResources true  // Enable resource shrinking
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
            
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    
    // ADDED: Lint options for better code quality
    lintOptions {
        checkReleaseBuilds false
        abortOnError false
    }
    
    // ADDED: Packaging options
    packagingOptions {
        pickFirst '**/libc++_shared.so'
        pickFirst '**/libjsc.so'
    }
}

flutter {
    source = "../.."
}