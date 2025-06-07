// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ApiResponse<T> {
  int? get statusCode => throw _privateConstructorUsedError;
  bool get isSuccess => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(T? data, int? statusCode, bool isSuccess) success,
    required TResult Function(
            String? errorMessage, int? statusCode, bool isSuccess)
        error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(T? data, int? statusCode, bool isSuccess)? success,
    TResult? Function(String? errorMessage, int? statusCode, bool isSuccess)?
        error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(T? data, int? statusCode, bool isSuccess)? success,
    TResult Function(String? errorMessage, int? statusCode, bool isSuccess)?
        error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Success<T> value) success,
    required TResult Function(Error<T> value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Success<T> value)? success,
    TResult? Function(Error<T> value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Success<T> value)? success,
    TResult Function(Error<T> value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Create a copy of ApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ApiResponseCopyWith<T, ApiResponse<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApiResponseCopyWith<T, $Res> {
  factory $ApiResponseCopyWith(
          ApiResponse<T> value, $Res Function(ApiResponse<T>) then) =
      _$ApiResponseCopyWithImpl<T, $Res, ApiResponse<T>>;
  @useResult
  $Res call({int? statusCode, bool isSuccess});
}

/// @nodoc
class _$ApiResponseCopyWithImpl<T, $Res, $Val extends ApiResponse<T>>
    implements $ApiResponseCopyWith<T, $Res> {
  _$ApiResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? statusCode = freezed,
    Object? isSuccess = null,
  }) {
    return _then(_value.copyWith(
      statusCode: freezed == statusCode
          ? _value.statusCode
          : statusCode // ignore: cast_nullable_to_non_nullable
              as int?,
      isSuccess: null == isSuccess
          ? _value.isSuccess
          : isSuccess // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SuccessImplCopyWith<T, $Res>
    implements $ApiResponseCopyWith<T, $Res> {
  factory _$$SuccessImplCopyWith(
          _$SuccessImpl<T> value, $Res Function(_$SuccessImpl<T>) then) =
      __$$SuccessImplCopyWithImpl<T, $Res>;
  @override
  @useResult
  $Res call({T? data, int? statusCode, bool isSuccess});
}

/// @nodoc
class __$$SuccessImplCopyWithImpl<T, $Res>
    extends _$ApiResponseCopyWithImpl<T, $Res, _$SuccessImpl<T>>
    implements _$$SuccessImplCopyWith<T, $Res> {
  __$$SuccessImplCopyWithImpl(
      _$SuccessImpl<T> _value, $Res Function(_$SuccessImpl<T>) _then)
      : super(_value, _then);

  /// Create a copy of ApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = freezed,
    Object? statusCode = freezed,
    Object? isSuccess = null,
  }) {
    return _then(_$SuccessImpl<T>(
      freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as T?,
      freezed == statusCode
          ? _value.statusCode
          : statusCode // ignore: cast_nullable_to_non_nullable
              as int?,
      null == isSuccess
          ? _value.isSuccess
          : isSuccess // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$SuccessImpl<T> implements Success<T> {
  const _$SuccessImpl(this.data, this.statusCode, this.isSuccess);

  @override
  final T? data;
  @override
  final int? statusCode;
  @override
  final bool isSuccess;

  @override
  String toString() {
    return 'ApiResponse<$T>.success(data: $data, statusCode: $statusCode, isSuccess: $isSuccess)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SuccessImpl<T> &&
            const DeepCollectionEquality().equals(other.data, data) &&
            (identical(other.statusCode, statusCode) ||
                other.statusCode == statusCode) &&
            (identical(other.isSuccess, isSuccess) ||
                other.isSuccess == isSuccess));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(data), statusCode, isSuccess);

  /// Create a copy of ApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SuccessImplCopyWith<T, _$SuccessImpl<T>> get copyWith =>
      __$$SuccessImplCopyWithImpl<T, _$SuccessImpl<T>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(T? data, int? statusCode, bool isSuccess) success,
    required TResult Function(
            String? errorMessage, int? statusCode, bool isSuccess)
        error,
  }) {
    return success(data, statusCode, isSuccess);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(T? data, int? statusCode, bool isSuccess)? success,
    TResult? Function(String? errorMessage, int? statusCode, bool isSuccess)?
        error,
  }) {
    return success?.call(data, statusCode, isSuccess);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(T? data, int? statusCode, bool isSuccess)? success,
    TResult Function(String? errorMessage, int? statusCode, bool isSuccess)?
        error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(data, statusCode, isSuccess);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Success<T> value) success,
    required TResult Function(Error<T> value) error,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Success<T> value)? success,
    TResult? Function(Error<T> value)? error,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Success<T> value)? success,
    TResult Function(Error<T> value)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class Success<T> implements ApiResponse<T> {
  const factory Success(
          final T? data, final int? statusCode, final bool isSuccess) =
      _$SuccessImpl<T>;

  T? get data;
  @override
  int? get statusCode;
  @override
  bool get isSuccess;

  /// Create a copy of ApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SuccessImplCopyWith<T, _$SuccessImpl<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<T, $Res>
    implements $ApiResponseCopyWith<T, $Res> {
  factory _$$ErrorImplCopyWith(
          _$ErrorImpl<T> value, $Res Function(_$ErrorImpl<T>) then) =
      __$$ErrorImplCopyWithImpl<T, $Res>;
  @override
  @useResult
  $Res call({String? errorMessage, int? statusCode, bool isSuccess});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<T, $Res>
    extends _$ApiResponseCopyWithImpl<T, $Res, _$ErrorImpl<T>>
    implements _$$ErrorImplCopyWith<T, $Res> {
  __$$ErrorImplCopyWithImpl(
      _$ErrorImpl<T> _value, $Res Function(_$ErrorImpl<T>) _then)
      : super(_value, _then);

  /// Create a copy of ApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? errorMessage = freezed,
    Object? statusCode = freezed,
    Object? isSuccess = null,
  }) {
    return _then(_$ErrorImpl<T>(
      freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      freezed == statusCode
          ? _value.statusCode
          : statusCode // ignore: cast_nullable_to_non_nullable
              as int?,
      null == isSuccess
          ? _value.isSuccess
          : isSuccess // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$ErrorImpl<T> implements Error<T> {
  const _$ErrorImpl(this.errorMessage, this.statusCode, this.isSuccess);

  @override
  final String? errorMessage;
  @override
  final int? statusCode;
  @override
  final bool isSuccess;

  @override
  String toString() {
    return 'ApiResponse<$T>.error(errorMessage: $errorMessage, statusCode: $statusCode, isSuccess: $isSuccess)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl<T> &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.statusCode, statusCode) ||
                other.statusCode == statusCode) &&
            (identical(other.isSuccess, isSuccess) ||
                other.isSuccess == isSuccess));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, errorMessage, statusCode, isSuccess);

  /// Create a copy of ApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<T, _$ErrorImpl<T>> get copyWith =>
      __$$ErrorImplCopyWithImpl<T, _$ErrorImpl<T>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(T? data, int? statusCode, bool isSuccess) success,
    required TResult Function(
            String? errorMessage, int? statusCode, bool isSuccess)
        error,
  }) {
    return error(errorMessage, statusCode, isSuccess);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(T? data, int? statusCode, bool isSuccess)? success,
    TResult? Function(String? errorMessage, int? statusCode, bool isSuccess)?
        error,
  }) {
    return error?.call(errorMessage, statusCode, isSuccess);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(T? data, int? statusCode, bool isSuccess)? success,
    TResult Function(String? errorMessage, int? statusCode, bool isSuccess)?
        error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(errorMessage, statusCode, isSuccess);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Success<T> value) success,
    required TResult Function(Error<T> value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Success<T> value)? success,
    TResult? Function(Error<T> value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Success<T> value)? success,
    TResult Function(Error<T> value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class Error<T> implements ApiResponse<T> {
  const factory Error(final String? errorMessage, final int? statusCode,
      final bool isSuccess) = _$ErrorImpl<T>;

  String? get errorMessage;
  @override
  int? get statusCode;
  @override
  bool get isSuccess;

  /// Create a copy of ApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<T, _$ErrorImpl<T>> get copyWith =>
      throw _privateConstructorUsedError;
}
