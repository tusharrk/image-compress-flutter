import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_boilerplate/core/common_imports/common_imports.dart';
import 'package:flutter_boilerplate/core/common_imports/service_imports.dart';
import 'package:flutter_boilerplate/core/network/models/api_response.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioClient {
  final String baseUrl;
  late Dio _dio;

  // Simple cache for GET requests
  final Map<String, dynamic> _cache = {};
  final Duration _cacheExpiration;
  final Map<String, DateTime> _cacheTimestamps = {};

  // Global cache toggle
  bool _isCacheEnabled;

  //storage service
  final storageService = locator<StorageService>();

  final int _maxRetryCount;

  DioClient(
    this.baseUrl,
    Dio dio, {
    List<Interceptor>? interceptors,
    bool enableCache = true,
    Duration? cacheExpiration,
    int maxRetryCount = 2, // Default to 2 retries
  })  : _isCacheEnabled = enableCache,
        _cacheExpiration = cacheExpiration ?? const Duration(minutes: 1),
        _maxRetryCount = maxRetryCount {
    _dio = dio;
    _initDio(interceptors);
  }

  // Getter and setter for cache enabled state
  bool get isCacheEnabled => _isCacheEnabled;

  set isCacheEnabled(bool value) {
    if (_isCacheEnabled != value) {
      _isCacheEnabled = value;

      // Clear cache when disabling
      if (!_isCacheEnabled) {
        clearCache();
      }
    }
  }

  void _initDio(List<Interceptor>? interceptors) {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      contentType: 'application/json; charset=UTF-8',
      responseType: ResponseType.json,
      validateStatus: (status) {
        return status! < 500;
      },
    );

    // Add auth token interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = storageService.read("user_auth_token");
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );

    // Add retry interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, handler) async {
          // Get retry count from request or default to 0
          final retryCount =
              error.requestOptions.extra['retryCount'] as int? ?? 0;

          if (_shouldRetry(error) && retryCount < _maxRetryCount) {
            try {
              // Retry the request with incremented retry count
              return handler
                  .resolve(await _retry(error.requestOptions, retryCount + 1));
            } catch (e) {
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ),
    );

    // Add user-provided interceptors
    if (interceptors?.isNotEmpty ?? false) {
      _dio.interceptors.addAll(interceptors!);
    }

    // Add logger in debug mode
    if (!kReleaseMode) {
      _dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        compact: true,
      ));
    }
  }

  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        (error.response?.statusCode == 503); // Service unavailable
  }

  Future<Response<dynamic>> _retry(
      RequestOptions requestOptions, int retryCount) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
      extra: {
        ...requestOptions.extra,
        'retryCount': retryCount,
      },
    );

    // Calculate delay with exponential backoff (e.g., 1s, 2s, 4s, etc.)
    final delay = Duration(milliseconds: 1000 * (1 << (retryCount - 1)));

    // Log and wait
    if (!kReleaseMode) {
      debugPrint(
          'Retrying request to ${requestOptions.path} in ${delay.inMilliseconds}ms (Attempt $retryCount of $_maxRetryCount)');
    }

    // Add delay before retry
    await Future.delayed(delay);

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  bool _isCacheValid(String cacheKey) {
    final timestamp = _cacheTimestamps[cacheKey];
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) < _cacheExpiration;
  }

  Future<ApiResponse<T>> get<T>(
    String uri, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    bool? useCache,
  }) async {
    try {
      // Determine if we should use cache for this request
      // Request-specific setting overrides global setting if provided
      final shouldUseCache = useCache ?? _isCacheEnabled;

      // Generate cache key
      final cacheKey =
          '$uri${queryParameters != null ? '?${json.encode(queryParameters)}' : ''}';

      // Return cached response if available and valid and caching is enabled
      if (shouldUseCache &&
          _cache.containsKey(cacheKey) &&
          _isCacheValid(cacheKey)) {
        return ApiResponse<T>.success(_cache[cacheKey] as T, 200, true);
      }

      final response = await _dio.get(
        uri,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );

      // Cache the response if caching is enabled
      if (shouldUseCache && response.statusCode == 200) {
        _cache[cacheKey] = response.data;
        _cacheTimestamps[cacheKey] = DateTime.now();
      }

      return _handleResponse<T>(response);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } on SocketException catch (e) {
      return ApiResponse.error('Network error: ${e.message}', 500, false);
    } on FormatException catch (e) {
      return ApiResponse.error('Format error: ${e.message}', 500, false);
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e', 500, false);
    }
  }

  Future<ApiResponse<T>> post<T>(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    bool? useCache,
  }) async {
    try {
      // Determine if we should use cache for this request
      // Request-specific setting overrides global setting if provided
      final shouldUseCache = useCache ?? _isCacheEnabled;
      // Generate cache key
      final cacheKey = '$uri${data != null ? '?${json.encode(data)}' : ''}';

      // Return cached response if available and valid and caching is enabled
      if (shouldUseCache &&
          _cache.containsKey(cacheKey) &&
          _isCacheValid(cacheKey)) {
        return ApiResponse<T>.success(_cache[cacheKey] as T, 200, true);
      }
      final response = await _dio.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      // Cache the response if caching is enabled
      if (shouldUseCache && response.statusCode == 200) {
        _cache[cacheKey] = response.data;
        _cacheTimestamps[cacheKey] = DateTime.now();
      }

      return _handleResponse<T>(response);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } on FormatException catch (e) {
      return ApiResponse.error('Format error: ${e.message}', 500, false);
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e', 500, false);
    }
  }

  Future<ApiResponse<T>> patch<T>(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.patch(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } on FormatException catch (e) {
      return ApiResponse.error('Format error: ${e.message}', 500, false);
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e', 500, false);
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } on FormatException catch (e) {
      return ApiResponse.error('Format error: ${e.message}', 500, false);
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e', 500, false);
    }
  }

  ApiResponse<T> _handleResponse<T>(Response response) {
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      // return ApiResponse<T>.success(
      //   response.data as T,
      //   statusCode: response.statusCode,
      // );
      return ApiResponse.success(response.data as T, response.statusCode, true);
    } else {
      String errorMessage = 'Request failed';

      if (response.data is Map && response.data['message'] != null) {
        errorMessage = response.data['message'];
      } else if (response.statusMessage != null) {
        errorMessage = response.statusMessage!;
      }

      return ApiResponse.error(errorMessage, response.statusCode, false);
    }
  }

  ApiResponse<T> _handleDioError<T>(DioException error) {
    String errorMessage = 'Connection error';
    int? statusCode = error.response?.statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage = 'Connection timeout';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = 'Send timeout';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Receive timeout';
        break;
      case DioExceptionType.badCertificate:
        errorMessage = 'Bad certificate';
        break;
      case DioExceptionType.badResponse:
        if (error.response?.data is Map &&
            error.response?.data['message'] != null) {
          errorMessage = error.response?.data['message'];
        } else if (error.response?.statusMessage != null) {
          errorMessage = error.response!.statusMessage!;
        } else {
          errorMessage = 'Bad response';
        }
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request cancelled';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'Connection error';
        break;
      case DioExceptionType.unknown:
        errorMessage = 'Unknown error';
        break;
    }

    return ApiResponse<T>.error(errorMessage, statusCode, false);
  }

  // Utility method to invalidate specific cache items
  void invalidateCache(String uri, {Map<String, dynamic>? queryParameters}) {
    final cacheKey =
        '$uri${queryParameters != null ? '?${json.encode(queryParameters)}' : ''}';
    _cache.remove(cacheKey);
    _cacheTimestamps.remove(cacheKey);
  }

  // Update authorization token dynamically if needed
  void updateAuthToken(String token) {
    // StorageBox().getStorageBox().write("user_auth_token", token);
    storageService.write("user_auth_token", token);
  }

  // Set cache expiration period
  void setCacheExpiration(Duration duration) {
    // Only applies to new cache entries
    // Existing entries will keep their original expiration
  }
}
