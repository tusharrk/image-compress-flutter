import 'package:flutter/material.dart';
import 'package:flutter_boilerplate/core/common_imports/common_imports.dart';
import 'package:flutter_boilerplate/core/common_imports/service_imports.dart';
import 'package:flutter_boilerplate/core/common_imports/ui_imports.dart';
import 'package:flutter_boilerplate/core/network/api_config.dart';
import 'package:flutter_boilerplate/core/network/base_service.dart';
import 'package:flutter_boilerplate/core/network/models/api_response.dart';
import 'package:flutter_boilerplate/data/model/Person.dart';

class UserService extends BaseService {
// User data
  Person? _currentUser;
  bool _isLoggedIn = false;

  // Getters
  Person? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;

  final storageService = locator<StorageService>();

  static const String _registerEndpoint = 'SignUp/SignUp';

  UserService()
      : super(
          baseUrl: ApiConfig.baseUrlAPI,
          enableCache: false,
          cacheExpiration: const Duration(minutes: 15),
        ) {
    // Register reactive properties
    listenToReactiveValues([_currentUser, _isLoggedIn]);

    // Try to initialize from stored token
    initializeUser();
  }

  // Register new user
  Future<ApiResponse<Person?>> register(Person user) async {
    final response = await post<Map<String, dynamic>>(
      _registerEndpoint,
      useCache: false,
      data: user.toJson(),
    );

    return response.when(success: (data, statusCode, isSuccess) {
      if (data != null) {
        _currentUser = Person.fromJson(data);
        _isLoggedIn = true;
        return ApiResponse.success(_currentUser, statusCode, true);
      } else {
        return ApiResponse.error(
            AppStrings.somethingWentWrong, statusCode, false);
      }
    }, error: (errorMessage, statusCode, isSuccess) {
      return ApiResponse.error(errorMessage, statusCode, false);
    });
  }

  Future<Person?> getUserProfile() async {
    final response = await get<Map<String, dynamic>>(
      _registerEndpoint,
      useCache: false, // Use cache unless explicitly refreshing
    );

    return response.when(success: (data, statusCode, isSuccess) {
      if (data != null) {
        _currentUser = Person.fromJson(data);
        _isLoggedIn = true;
        return _currentUser;
      } else {
        return null;
      }
    }, error: (errorMessage, statusCode, isSuccess) {
      debugPrint("=================================");
      debugPrint("getUserProfile response---$errorMessage");
      debugPrint("getUserProfile response---${response.isSuccess}");
      debugPrint("getUserProfile response---${response.statusCode}");
      debugPrint("=================================");
      return null;
    });
  }

  // Initialize user from stored token
  Future<bool> initializeUser() async {
    final token = storageService.read("user_auth_token");
    if (token == null || token.isEmpty) {
      return false;
    }

    // Set token for DioClient
    updateAuthToken(token);

    // Try to get user profile
    // final user = await getUserProfile();
    //final user = Person();
    _isLoggedIn = true;
    notifyListeners();
    return true;
  }
}
