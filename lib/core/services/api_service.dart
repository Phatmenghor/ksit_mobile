import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:ksit_mobile/core/constants/app_routes.dart';
import 'package:ksit_mobile/core/constants/app_storages.dart';
import '../config/app_config.dart';
import '../utils/logger_utils.dart';
import 'storage_service.dart';

class ApiService extends GetxService {
  late Dio _dio;
  final StorageService _storageService = Get.find<StorageService>();

  @override
  void onInit() {
    super.onInit();
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl, // Get from AppConfig instead of AppConstants
      connectTimeout: Duration(milliseconds: AppConfig.connectTimeout),
      receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Request Interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token if available
          final token = _storageService.getString(AppStorages.tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          LoggerUtils.info('API Request: ${options.method} ${options.path}');
          LoggerUtils.debug('Request Headers: ${options.headers}');
          LoggerUtils.debug('Request Data: ${options.data}');

          handler.next(options);
        },
        onResponse: (response, handler) {
          LoggerUtils.info(
              'API Response: ${response.statusCode} ${response.requestOptions.path}');
          LoggerUtils.debug('Response Data: ${response.data}');
          handler.next(response);
        },
        onError: (error, handler) {
          LoggerUtils.error('API Error: ${error.message}', error);
          _handleError(error);
          handler.next(error);
        },
      ),
    );
  }

  void _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        LoggerUtils.error('Connection timeout');
        break;
      case DioExceptionType.sendTimeout:
        LoggerUtils.error('Send timeout');
        break;
      case DioExceptionType.receiveTimeout:
        LoggerUtils.error('Receive timeout');
        break;
      case DioExceptionType.badResponse:
        LoggerUtils.error('Bad response: ${error.response?.statusCode}');
        if (error.response?.statusCode == 401) {
          _handleUnauthorized();
        }
        break;
      case DioExceptionType.cancel:
        LoggerUtils.error('Request cancelled');
        break;
      case DioExceptionType.unknown:
        LoggerUtils.error('Unknown error: ${error.message}');
        break;
      default:
        LoggerUtils.error('Unexpected error: ${error.message}');
    }
  }

  void _handleUnauthorized() {
    // Clear token and redirect to login
    _storageService.remove(AppStorages.tokenKey);
    _storageService.remove(AppStorages.userKey);
    Get.offAllNamed(AppRoutes.loginRoute);
  }

  // GET Request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      LoggerUtils.error('GET Request failed: $path', e);
      rethrow;
    }
  }

  // POST Request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      LoggerUtils.error('POST Request failed: $path', e);
      rethrow;
    }
  }

  // PUT Request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      LoggerUtils.error('PUT Request failed: $path', e);
      rethrow;
    }
  }

  // DELETE Request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      LoggerUtils.error('DELETE Request failed: $path', e);
      rethrow;
    }
  }

  // PATCH Request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      LoggerUtils.error('PATCH Request failed: $path', e);
      rethrow;
    }
  }

  // Upload File
  Future<Response<T>> uploadFile<T>(
    String path,
    String filePath, {
    String? fileName,
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        ...?data,
      });

      return await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
    } catch (e) {
      LoggerUtils.error('File upload failed: $path', e);
      rethrow;
    }
  }

  // Download File
  Future<Response> downloadFile(
    String path,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.download(
        path,
        savePath,
        queryParameters: queryParameters,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
    } catch (e) {
      LoggerUtils.error('File download failed: $path', e);
      rethrow;
    }
  }

  // Helper method to get full endpoint URL
  String getEndpointUrl(String endpoint) {
    return AppConfig.baseUrl + endpoint;
  }

  // Helper method to get current environment info
  Map<String, dynamic> get environmentInfo => AppConfig.debugInfo;
}
