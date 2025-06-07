import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_response.freezed.dart';

@freezed
class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse.success(T? data, int? statusCode, bool isSuccess) =
      Success<T>;
  const factory ApiResponse.error(
      String? errorMessage, int? statusCode, bool isSuccess) = Error<T>;
}
