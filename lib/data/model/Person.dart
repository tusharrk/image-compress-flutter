import 'package:freezed_annotation/freezed_annotation.dart';

part 'Person.freezed.dart';
part 'Person.g.dart';

@freezed
class Person with _$Person {
  const factory Person({
    final String? mobileNo,
    final String? iPin,
    final String? deviceID,
    final String? firebaseId,
    final String? token,
    final String? otp,
    final bool? isExist,
    final bool? status,
    final int? userId,
  }) = _Person;

  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);
}
