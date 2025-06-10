import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../constants/api_constants.dart';
import 'api_result.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late final Dio _dio;

  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
      sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add API key and session interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add API key
          options.queryParameters[ApiConstants.apiKeyParam] =
              dotenv.env['TMDB_API_KEY'] ?? '';

          // Add default language
          options.queryParameters[ApiConstants.languageParam] =
              ApiConstants.defaultLanguage;

          handler.next(options);
        },
        onError: (error, handler) {
          // TODO: Replace with a proper logger
          // print('API Error: ${error.message}');
          handler.next(error);
        },
      ),
    );

    // Add logging interceptor in debug mode
    // TODO: Consider using a logger that can be disabled in release mode
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      // logPrint: (object) => print(object),
    ));
  }

  /// Generic GET request
  Future<ApiResult<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final data = fromJson(response.data);
        return ApiSuccess(data);
      } else {
        return ApiError(
          message: 'Request failed with status: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiError(
        message: 'Unexpected error: $e',
        error: e,
      );
    }
  }

  /// Generic POST request
  Future<ApiResult<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = fromJson(response.data);
        return ApiSuccess(responseData);
      } else {
        return ApiError(
          message: 'Request failed with status: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiError(
        message: 'Unexpected error: $e',
        error: e,
      );
    }
  }

  /// Generic DELETE request
  Future<ApiResult<T>> delete<T>(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final responseData = fromJson(response.data);
        return ApiSuccess(responseData);
      } else {
        return ApiError(
          message: 'Request failed with status: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiError(
        message: 'Unexpected error: $e',
        error: e,
      );
    }
  }

  /// Handle Dio errors
  ApiError<T> _handleDioError<T>(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return const ApiError(message: 'Connection timeout');
      case DioExceptionType.sendTimeout:
        return const ApiError(message: 'Send timeout');
      case DioExceptionType.receiveTimeout:
        return const ApiError(message: 'Receive timeout');
      case DioExceptionType.badResponse:
        return ApiError(
          message: error.response?.data['status_message'] ?? 'Bad response',
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.cancel:
        return const ApiError(message: 'Request cancelled');
      case DioExceptionType.connectionError:
        return const ApiError(message: 'No internet connection');
      default:
        return ApiError(
          message: error.message ?? 'Unknown error occurred',
          error: error,
        );
    }
  }
}
