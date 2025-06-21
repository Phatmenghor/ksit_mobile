# Flutter App with GetX, Go Router & Firebase

A complete Flutter application built with modern architecture and best practices. Features include authentication, real-time notifications, QR code scanning, request management, and user profiles.

## 🚀 Features

- **Authentication**: Secure login/logout with token management
- **Push Notifications**: Firebase Cloud Messaging integration
- **QR Code Scanning**: Camera-based scanning with manual input option
- **Request Management**: Create, view, and manage requests with pagination
- **User Profile**: Profile management with statistics
- **Responsive UI**: Modern design with custom components
- **State Management**: GetX for reactive state management
- **Navigation**: Go Router for declarative routing
- **API Integration**: Dio for HTTP requests with interceptors
- **Local Storage**: SharedPreferences for data persistence

## 📱 Screens

1. **Splash Screen**: App initialization and authentication check
2. **Login Screen**: User authentication
3. **Home Screen**: Dashboard with paginated data
4. **Scan Screen**: QR/Barcode scanner with camera controls
5. **Request Screen**: Request management with filtering
6. **Profile Screen**: User profile and app settings

## 🏗️ Project Structure

```
lib/
├── core/
│   ├── bindings/
│   │   └── initial_binding.dart
│   ├── constants/
│   │   ├── app_colors.dart
│   │   └── app_constants.dart
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── firebase_service.dart
│   │   └── storage_service.dart
│   └── utils/
│       └── logger_utils.dart
├── features/
│   ├── auth/
│   │   ├── controllers/
│   │   ├── models/
│   │   └── screens/
│   ├── home/
│   │   ├── controllers/
│   │   ├── models/
│   │   ├── screens/
│   │   └── widgets/
│   ├── scan/
│   │   ├── controllers/
│   │   └── screens/
│   ├── request/
│   │   ├── controllers/
│   │   ├── models/
│   │   ├── screens/
│   │   └── widgets/
│   └── profile/
│       ├── controllers/
│       └── screens/
├── shared/
│   ├── models/
│   ├── screens/
│   └── widgets/
├── routes/
│   └── app_router.dart
└── main.dart
```

## 🛠️ Setup Instructions

### 1. Dependencies Installation

```bash
flutter pub get
```

### 2. Code Generation

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 3. Firebase Setup

1. Create a Firebase project
2. Add your Android/iOS app to Firebase
3. Download and place configuration files:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`

### 4. API Configuration

Update the base URL in `lib/core/constants/app_constants.dart`:

```dart
static const String baseUrl = 'https://your-api-url.com/api/v1';
```

## 📦 Key Dependencies

- **get**: State management and dependency injection
- **go_router**: Declarative routing
- **firebase_core** & **firebase_messaging**: Push notifications
- **dio**: HTTP client
- **shared_preferences**: Local storage
- **infinite_scroll_pagination**: Paginated lists
- **freezed**: Immutable data classes
- **flutter_svg**: SVG support
- **fluttertoast**: Toast notifications
- **logger**: Logging utilities

## 🎨 Custom Components

### Widgets

- `CustomButton`: Reusable button component
- `CustomTextField`: Form input component
- `LoadingWidget`: Loading indicators
- `HomeItemWidget`: Home screen item display
- `RequestItemWidget`: Request item display

### Services

- `ApiService`: HTTP client with interceptors
- `StorageService`: SharedPreferences wrapper
- `FirebaseService`: Push notification handling

### Controllers

- `AuthController`: Authentication logic
- `HomeController`: Home screen data management
- `ScanController`: QR scanner logic
- `RequestController`: Request management
- `ProfileController`: User profile management

## 🔧 Configuration

### Colors

All app colors are centralized in `app_colors.dart` with a single color scheme.

### Constants

App-wide constants are defined in `app_constants.dart` including API endpoints, timeouts, and UI constants.

### Routing

Go Router configuration in `app_router.dart` with authentication guards and bottom navigation shell.

## 🔔 Push Notifications

Firebase Cloud Messaging is configured to:

- Handle foreground, background, and terminated app states
- Show custom notification dialogs
- Process notification data for navigation
- Subscribe to topics for broadcast messages

## 📱 Bottom Navigation

Four main sections:

1. **Home**: Dashboard and data overview
2. **Scan**: QR/Barcode scanning
3. **Request**: Request management
4. **Profile**: User profile and settings

## 🔐 Authentication

- Token-based authentication
- Automatic token refresh handling
- Secure storage of credentials
- Route protection with authentication guards

## 📊 Pagination

Infinite scroll pagination implemented with:

- Page-based API requests
- Error handling and retry logic
- Loading states and empty states
- Pull-to-refresh functionality

## 🎯 Usage Examples

### Making API Calls

```dart
final response = await _apiService.get<Map<String, dynamic>>(
  '/endpoint',
  queryParameters: {'page': 1, 'size': 10},
);
```

### Navigation

```dart
Get.toNamed(AppConstants.homeRoute);
context.go(AppConstants.profileRoute);
```

### State Management

```dart
final RxBool isLoading = false.obs;
// In UI
Obx(() => Text('Loading: ${controller.isLoading.value}'));
```

## 🚀 Deployment

1. Update version in `pubspec.yaml`
2. Build the app:
   ```bash
   flutter build apk --release  # Android
   flutter build ios --release  # iOS
   ```

## 📝 Notes

- The app uses a single color theme (no dark/light mode switching)
- All API responses follow a consistent format with pagination support
- Firebase is used only for push notifications
- Custom widgets are designed for reusability across the app
- The architecture supports easy feature addition and maintenance

## 🔮 Future Enhancements

- Biometric authentication
- Offline support with local database
- Advanced filtering and search
- File upload/download capabilities
- Real-time chat/messaging
- Multi-language support

## 📄 License

This project is a template/boilerplate for Flutter applications. Feel free to use and modify as needed.
