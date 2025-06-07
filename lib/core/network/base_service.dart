import 'package:dio/dio.dart';
import 'package:flutter_boilerplate/core/network/deo_client.dart';
import 'package:flutter_boilerplate/core/network/models/api_response.dart';
import 'package:stacked/stacked.dart';

abstract class BaseService with ListenableServiceMixin {
  // Base URL for APIs
  final String baseUrl;

  // DioClient instance
  late final DioClient _dioClient;

  // Getter for the DioClient
  DioClient get dioClient => _dioClient;

  // Cache control
  bool get isCacheEnabled => _dioClient.isCacheEnabled;
  set isCacheEnabled(bool value) => _dioClient.isCacheEnabled = value;

  BaseService({
    required this.baseUrl,
    bool enableCache = true,
    Duration? cacheExpiration,
    List<Interceptor>? interceptors,
  }) {
    _dioClient = DioClient(
      baseUrl,
      Dio(),
      enableCache: enableCache,
      cacheExpiration: cacheExpiration ?? const Duration(minutes: 1),
      interceptors: interceptors,
    );
  }

  // Base methods for API operations

  // GET request with type safety
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    bool? useCache,
    CancelToken? cancelToken,
  }) async {
    return await _dioClient.get<T>(
      endpoint,
      queryParameters: queryParams,
      useCache: useCache,
      cancelToken: cancelToken,
    );
  }

  // POST request with type safety
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    bool? useCache,
    CancelToken? cancelToken,
  }) async {
    return await _dioClient.post<T>(
      endpoint,
      data: data,
      queryParameters: queryParams,
      useCache: useCache,
      cancelToken: cancelToken,
    );
  }

  // PATCH request with type safety
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    CancelToken? cancelToken,
  }) async {
    return await _dioClient.patch<T>(
      endpoint,
      data: data,
      queryParameters: queryParams,
      cancelToken: cancelToken,
    );
  }

  // DELETE request with type safety
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    CancelToken? cancelToken,
  }) async {
    return await _dioClient.delete<T>(
      endpoint,
      data: data,
      queryParameters: queryParams,
      cancelToken: cancelToken,
    );
  }

  // Helper methods for cache management
  void clearCache() {
    _dioClient.clearCache();
  }

  void invalidateCache(String endpoint, {Map<String, dynamic>? queryParams}) {
    _dioClient.invalidateCache(endpoint, queryParameters: queryParams);
  }

  // Helper method for updating auth token
  void updateAuthToken(String token) {
    _dioClient.updateAuthToken(token);
  }

  // Helper methods to parse common response patterns

  // Parse standard response with data field
  T? parseDataField<T>(ApiResponse<Map<String, dynamic>> response) {
    response.when(
      success: (data, statusCode, isSuccess) {
        if (data != null && data.containsKey('data')) {
          return data['data'] as T?;
        }
        return null;
      },
      error: (errorMessage, statusCode, isSuccess) {
        // Handle error
        return null;
      },
    );
    return null;
  }

  // Parse standard paginated response
  Map<String, dynamic>? parsePaginatedResponse(
      ApiResponse<Map<String, dynamic>> response) {
    response.when(
      success: (data, statusCode, isSuccess) {
        if (data != null) {
          return {
            'data': data['data'] ?? [],
            'pagination': data['pagination'] ??
                {
                  'current_page': 1,
                  'total_pages': 1,
                  'total_items': 0,
                  'per_page': 10,
                },
          };
        }
        return null;
      },
      error: (errorMessage, statusCode, isSuccess) {
        // Handle error
        return null;
      },
    );
    return null;
  }

  // Get error message from response
  String getErrorMessage(ApiResponse response) {
    return response.when(
      success: (data, statusCode, isSuccess) {
        // Handle success
        return '';
      },
      error: (errorMessage, statusCode, isSuccess) {
        // Handle error
        return errorMessage ?? 'Unknown error occurred';
      },
    );
  }
}
