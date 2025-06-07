# Flutter Boilerplate with Stacked Architecture

A comprehensive Flutter project boilerplate built with the Stacked architecture and Stacked CLI, designed to kickstart your app development with best practices and a solid foundation.

This boilerplate provides:

- **Stacked Architecture**: MVVM pattern for clean separation of concerns
- **Code Generation**: Simplified DI, routing, and more with the Stacked CLI
- **Environment Management**: Easy switching between development and production
- **API Integration**: Ready-to-use service layer for network requests
- **Theming & Localization**: Support for dark/light themes and multiple languages
- **UI Components**: Reusable widgets, dialogs, and bottom sheets
- **Local Storage**: Secure data persistence
- **Form Handling**: Validation patterns and helpers
- **Asset Management**: Type-safe access to assets with FlutterGen

## Table of Contents

- [How To Use This Template](#How-to-Use-This-Template)
- [Getting Started](#getting-started)
- [Useful Commands](#useful-commands)
- [Stacked Architecture Usage](#stacked-architecture-usage)
- [Project Structure & Organization](#project-structure--organization)
- [Routing and Navigation](#routing-and-navigation)
- [Theme Customization](#theme-customization)
- [Localization Implementation](#localization-implementation)
- [API Integration](#api-integration)
- [Local Storage Usage](#local-storage-usage)
- [UI Components Library](#ui-components-library)
- [Environment Configuration](#environment-configuration)
- [Logging System](#logging-system)
- [Form Handling and Validation](#form-handling-and-validation)
- [Asset Management](#asset-management)

## How to Use This Template

### Clone This Template

If using this as a template:

- Click the green **“Use this template”** button on the GitHub repo page
- Choose **“Create a new repository”**
- Name your new project repo  
  Then:

```bash
git clone https://github.com/yourusername/your_new_project.git
cd your_new_project
```

## Getting Started

1. Clone this repository
2. Run `flutter pub get` to install dependencies
3. Create `.env.dev` and `.env.prod` files in the root directory (see Environment Configuration section)
4. Run `flutter pub run build_runner build --delete-conflicting-outputs` to generate necessary files (or use `stacked generate` as explained below)
5. Run `flutter run` to start the app

## Useful Commands

### Stacked CLI

This project uses the Stacked CLI to simplify common development tasks. To activate the CLI:

```bash
dart pub global activate stacked_cli
```

### Creating New Components

Instead of manually creating files, use the Stacked CLI:

```bash
# Create a new view
stacked create view view_name

# Create a new service
stacked create service service_name
```

### Generating Code

Instead of using the longer build_runner command:

```bash
# Traditional way
flutter pub run build_runner build --delete-conflicting-outputs

# Stacked CLI way (preferred)
stacked generate
```

### Environment Switching

Before building your app, you can switch environments:

```bash
# Switch to development environment
dart run env_manager.dart dev

# Switch to production environment
dart run env_manager.dart prod
```

### Building Release Version

To create a release build:

```bash
dart run build_release.dart
```

### Generating App Icons

To generate app icons based on configuration in pubspec.yaml:

```bash
dart run flutter_launcher_icons
```

### iOS Localization Note

For translations to work on iOS, add supported locales to ios/Runner/Info.plist:

```xml
<key>CFBundleLocalizations</key>
<array>
  <string>en</string>
  <string>de</string>
  <string>hi</string>
</array>
```

## Stacked Architecture Usage

This project follows the [Stacked](https://pub.dev/packages/stacked) architecture, which is based on MVVM (Model-View-ViewModel) pattern.

### Creating a New View and ViewModel

1. Create a new directory under `lib/ui/views/` for your feature
2. Create view and viewmodel files:

```dart
// new_feature_view.dart
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'new_feature_viewmodel.dart';

class NewFeatureView extends StackedView<NewFeatureViewModel> {
  const NewFeatureView({Key? key}) : super(key: key);

  @override
  Widget builder(context, viewModel, child) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Feature')),
      body: Center(
        child: Text(viewModel.title),
      ),
    );
  }

  @override
  NewFeatureViewModel viewModelBuilder(context) => NewFeatureViewModel();
}
```

```dart
// new_feature_viewmodel.dart
import 'package:flutter_boilerplate/core/viewmodels/common_base_viewmodel.dart';

class NewFeatureViewModel extends CommonBaseViewmodel {
  String title = 'New Feature';

  void initialize() {
    // Initialize your view model
  }
}
```

### Registering Services

To register a new service in the dependency injection container, modify `app.locator.dart`:

```dart
@StackedApp(
  dependencies: [
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: UserService),
    LazySingleton(classType: StorageService),
    LazySingleton(classType: YourNewService), // Add your service here
  ],
  // ...other configurations
)
class App {}
```

Then run `flutter pub run build_runner build --delete-conflicting-outputs` to regenerate the locator.

## Project Structure & Organization

### Data Models

Models are defined in `lib/data/model/` directory and follow a standard pattern using Freezed for immutability and JSON serialization:

```dart
// Example model
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'example_model.freezed.dart';
part 'example_model.g.dart';

@freezed
class ExampleModel with _$ExampleModel {
  const factory ExampleModel({
    required String id,
    required String name,
    @Default('') String description,
  }) = _ExampleModel;

  factory ExampleModel.fromJson(Map<String, dynamic> json) =>
      _$ExampleModelFromJson(json);
}
```

After creating a model, run `flutter pub run build_runner build --delete-conflicting-outputs` to generate the necessary files.

### Service Layer

Services are responsible for business logic and external communication. They are placed in `lib/services/` directory:

```dart
// example_service.dart
import 'package:flutter_boilerplate/core/network/base_service.dart';
import 'package:flutter_boilerplate/core/network/api_config.dart';
import 'package:flutter_boilerplate/data/model/example_model.dart';

class ExampleService extends BaseService {
  ExampleService()
      : super(
          baseUrl: ApiConfig.baseUrlAPI,
          enableCache: true,
          cacheExpiration: const Duration(minutes: 15),
        );

  Future<ApiResponse<ExampleModel?>> getExample(String id) async {
    final response = await get<Map<String, dynamic>>(
      'examples/$id',
      useCache: true,
    );

    return response.when(
      success: (data, statusCode, isSuccess) {
        if (data != null) {
          return ApiResponse.success(
            ExampleModel.fromJson(data),
            statusCode,
            true
          );
        } else {
          return ApiResponse.error(
            'No data found',
            statusCode,
            false
          );
        }
      },
      error: (errorMessage, statusCode, isSuccess) {
        return ApiResponse.error(errorMessage, statusCode, false);
      },
    );
  }
}
```

### ViewModel Structure

ViewModels connect the Services with the Views and handle UI logic:

```dart
// example_viewmodel.dart
import 'package:flutter_boilerplate/core/viewmodels/common_base_viewmodel.dart';
import 'package:flutter_boilerplate/data/model/example_model.dart';
import 'package:flutter_boilerplate/app/app.locator.dart';
import 'package:flutter_boilerplate/services/example_service.dart';

class ExampleViewModel extends CommonBaseViewmodel {
  final _exampleService = locator<ExampleService>();

  ExampleModel? _example;
  ExampleModel? get example => _example;

  Future<void> fetchExample(String id) async {
    setBusy(true);
    final response = await _exampleService.getExample(id);
    response.when(
      success: (data, _, __) {
        _example = data;
        rebuildUi();
      },
      error: (errorMessage, _, __) {
        setError(errorMessage);
      },
    );
    setBusy(false);
  }
}
```

### View Implementation

Views display UI elements and react to user interaction:

```dart
// example_view.dart
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'example_viewmodel.dart';

class ExampleView extends StackedView<ExampleViewModel> {
  final String exampleId;

  const ExampleView({required this.exampleId, Key? key}) : super(key: key);

  @override
  Widget builder(context, viewModel, child) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example')),
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator())
          : viewModel.hasError
              ? Center(child: Text('Error: ${viewModel.error}'))
              : _buildContent(context, viewModel),
    );
  }

  Widget _buildContent(BuildContext context, ExampleViewModel viewModel) {
    final example = viewModel.example;
    if (example == null) {
      return const Center(child: Text('No data available'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            example.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(example.description),
        ],
      ),
    );
  }

  @override
  ExampleViewModel viewModelBuilder(context) => ExampleViewModel();

  @override
  void onViewModelReady(ExampleViewModel viewModel) {
    viewModel.fetchExample(exampleId);
  }
}
```

## Routing and Navigation

### Adding New Routes

Routes are defined in the `app.router.dart` file. To add a new route:

1. Add a route to the `@StackedApp` annotation in `app.dart`:

```dart
@StackedApp(
  routes: [
    MaterialRoute(page: StartupView, initial: true),
    MaterialRoute(page: HomeView),
    MaterialRoute(page: ExamplePageView),
    MaterialRoute(page: YourNewView), // Add your new route here
  ],
  // ...other configurations
)
class App {}
```

2. Run `flutter pub run build_runner build --delete-conflicting-outputs` to regenerate the router.

### Using Navigation

Navigate to another screen using the NavigationService:

```dart
final _navigationService = locator<NavigationService>();

// Navigate to a route
_navigationService.navigateTo(Routes.homeView);

// Navigate to a route with parameters
_navigationService.navigateTo(
  Routes.examplePageView,
  arguments: ExamplePageViewArguments(id: '123'),
);

// Navigate and replace the current route
_navigationService.replaceWith(Routes.homeView);

// Navigate back
_navigationService.back();
```

## Theme Customization

### Modifying Themes

Themes are defined in the `lib/core/theme/` directory:

- `custom_light_theme.dart` for light theme
- `custom_dark_theme.dart` for dark theme
- `custom_color_scheme.dart` for color schemes

To modify the theme, edit these files:

```dart
// Example theme customization in custom_light_theme.dart
class CustomLightTheme extends CustomTheme {
  @override
  ThemeData get themeData {
    final theme = ThemeData.light();

    return theme.copyWith(
      colorScheme: CustomColorScheme.lightColorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: CustomColorScheme.lightColorScheme.primary,
        foregroundColor: CustomColorScheme.lightColorScheme.onPrimary,
        elevation: 0,
      ),
      // Add more theme customizations here
    );
  }
}
```

### Switching Themes

You can switch between light and dark themes:

```dart
// In your ViewModel
void toggleTheme(BuildContext context) {
  final currentTheme = Theme.of(context).brightness;
  final newTheme = currentTheme == Brightness.light
      ? ThemeMode.dark
      : ThemeMode.light;

  // Implement a mechanism to save and apply the theme
  // For example, using SharedPreferences or GetStorage
}
```

## Localization Implementation

The boilerplate uses `easy_localization` for handling translations. Translation files are stored in JSON format in the `assets/translations/` directory.

### Adding Translation Files

Create JSON files for each supported language in the `assets/translations/` directory:

```
assets/
  translations/
    en-US.json
    de-DE.json
    hi-IN.json
```

Example translation file (en-US.json):

```json
{
  "app_name": "Flutter Boilerplate",
  "welcome": "Welcome to Flutter Boilerplate",
  "hello": "Hello, {name}!",
  "buttons": {
    "login": "Login",
    "signup": "Sign Up",
    "logout": "Logout"
  },
  "errors": {
    "invalid_email": "Please enter a valid email address",
    "required_field": "This field is required"
  }
}
```

### Using Translations in Code

```dart
// Import the easy_localization package
import 'package:easy_localization/easy_localization.dart';

// In your widget
Widget build(BuildContext context) {
  return Column(
    children: [
      // Simple translation
      Text('welcome'.tr()),

      // Translation with parameters
      Text('hello'.tr(args: ['User'])),

      // Nested translations
      ElevatedButton(
        onPressed: () {},
        child: Text('buttons.login'.tr()),
      ),

      // Using translations in form validation
      TextFormField(
        decoration: InputDecoration(
          labelText: 'Email',
          errorText: _hasError ? 'errors.invalid_email'.tr() : null,
        ),
      ),
    ],
  );
}
```

### Changing Language at Runtime

```dart
// In your ViewModel
void changeLanguage(BuildContext context) {
  // Get current locale
  final currentLocale = context.locale.toString();

  // Determine next locale
  Locale newLocale;
  if (currentLocale == 'en_US') {
    newLocale = const Locale('de', 'DE');
  } else if (currentLocale == 'de_DE') {
    newLocale = const Locale('hi', 'IN');
  } else {
    newLocale = const Locale('en', 'US');
  }

  // Save preference (optional)
  _storageService.write('language', newLocale.toString());

  // Update language
  context.setLocale(newLocale);
}

// In your View
ElevatedButton(
  onPressed: () => viewModel.changeLanguage(context),
  child: Text('Change Language'),
)
```

### iOS Support

For translations to work on iOS, add supported locales to ios/Runner/Info.plist:

```xml
<key>CFBundleLocalizations</key>
<array>
  <string>en</string>
  <string>de</string>
  <string>hi</string>
</array>
```

## API Integration

The boilerplate includes a robust API integration system built on Dio with error handling, caching, and more.

### Base Service Class

The `BaseService` class in `lib/core/network/base_service.dart` provides the foundation for all API services:

```dart
import 'package:flutter_boilerplate/core/network/base_service.dart';
import 'package:flutter_boilerplate/core/network/api_config.dart';
import 'package:flutter_boilerplate/core/network/models/api_response.dart';
import 'package:flutter_boilerplate/data/model/user_model.dart';

class AuthService extends BaseService {
  AuthService()
      : super(
          baseUrl: ApiConfig.baseUrlAPI,
          enableCache: false, // No caching for auth
        );

  // Login example
  Future<ApiResponse<UserModel>> login(String email, String password) async {
    final response = await post<Map<String, dynamic>>(
      'auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    // The API response is handled using a sealed class pattern
    return response.when(
      success: (data, statusCode, isSuccess) {
        if (data != null) {
          // Parse the user data
          final user = UserModel.fromJson(data);

          // If the API returns a token, store it
          if (data.containsKey('token')) {
            final token = data['token'] as String;
            // Update the auth token for future requests
            updateAuthToken(token);
          }

          return ApiResponse.success(user, statusCode, true);
        } else {
          return ApiResponse.error(
            'No user data received',
            statusCode,
            false,
          );
        }
      },
      error: (errorMessage, statusCode, isSuccess) {
        return ApiResponse.error(errorMessage, statusCode, false);
      },
    );
  }

  // Fetch data with caching
  Future<ApiResponse<List<Product>>> getProducts() async {
    final response = await get<List<dynamic>>(
      'products',
      useCache: true, // Use cache for this request
      cacheExpiration: const Duration(minutes: 15), // Override default expiration
      queryParameters: {'limit': 10, 'sort': 'newest'},
    );

    return response.when(
      success: (data, statusCode, isSuccess) {
        if (data != null) {
          final products = data
              .map((item) => Product.fromJson(item as Map<String, dynamic>))
              .toList();
          return ApiResponse.success(products, statusCode, true);
        } else {
          return ApiResponse.error('No products found', statusCode, false);
        }
      },
      error: (errorMessage, statusCode, isSuccess) {
        return ApiResponse.error(errorMessage, statusCode, false);
      },
    );
  }
}
```

### Using Services in ViewModels

```dart
class ProductViewModel extends CommonBaseViewmodel {
  final _productService = locator<ProductService>();

  List<Product> _products = [];
  List<Product> get products => _products;

  Future<void> loadProducts() async {
    setBusy(true);
    final response = await _productService.getProducts();

    response.when(
      success: (data, _, __) {
        _products = data;
        rebuildUi();
      },
      error: (errorMessage, statusCode, __) {
        setError(errorMessage);

        // Show error to user
        if (statusCode == 401) {
          // Handle unauthorized - maybe logout user
          _handleUnauthorized();
        } else {
          // Show general error
          dialogService.showDialog(
            title: 'Error',
            description: errorMessage,
          );
        }
      },
    );

    setBusy(false);
  }

  // Example of creating a new resource
  Future<void> createProduct(Product product) async {
    setBusy(true);
    final response = await _productService.createProduct(product);

    response.when(
      success: (newProduct, _, __) {
        _products.add(newProduct);
        rebuildUi();

        // Show success
        dialogService.showDialog(
          title: 'Success',
          description: 'Product created successfully',
        );
      },
      error: (errorMessage, _, __) {
        setError(errorMessage);
        // Show error
      },
    );

    setBusy(false);
  }
}
```

## Local Storage Usage

The boilerplate includes a `StorageService` for local storage using GetStorage. This service is automatically registered in the locator and can be used throughout the app.

### Using the Storage Service

```dart
// In your ViewModel
import 'package:flutter_boilerplate/app/app.locator.dart';
import 'package:flutter_boilerplate/services/storage_service.dart';

class YourViewModel extends CommonBaseViewmodel {
  final _storageService = locator<StorageService>();

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  // Load user preferences
  void initialize() {
    // Read stored preference with a default value
    _isDarkMode = _storageService.read<bool>('dark_mode') ?? false;
  }

  // Save user preferences
  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await _storageService.write('dark_mode', value);
    rebuildUi();
  }

  // Example of storing complex data
  Future<void> saveUserProfile(Map<String, dynamic> userData) async {
    await _storageService.write('user_profile', userData);
  }

  // Example of retrieving complex data
  Map<String, dynamic>? getUserProfile() {
    return _storageService.read<Map<String, dynamic>>('user_profile');
  }

  // Remove specific data
  Future<void> logout() async {
    await _storageService.remove('user_profile');
    await _storageService.remove('auth_token');
  }

  // Clear all data
  Future<void> resetApp() async {
    await _storageService.erase();
  }
}
```

## Logging System

The boilerplate includes a comprehensive logging system configured in `app.logger.dart` that you can access through the `CommonBaseViewmodel` or directly.

### Using the Logger through CommonBaseViewmodel

The base ViewModel provides convenient access to the logger:

```dart
class YourViewModel extends CommonBaseViewmodel {
  void doSomething() {
    // Different log levels
    logger.i('Information: User logged in');
    logger.d('Debug: Processing data ${data.toString()}');
    logger.w('Warning: API call took longer than expected');
    logger.e('Error occurred', error: exception, stackTrace: stackTrace);
    logger.v('Verbose: Detailed operation information');
    logger.wtf('What a terrible failure!'); // Critical errors

    // Log with custom tags
    logger.i('Starting process', customTag: 'PROCESS');

    // The logger automatically includes the class name for easier debugging
  }
}
```

### Using the Logger Directly

You can also use the logger directly in services or other classes:

```dart
import 'package:flutter_boilerplate/app/app.logger.dart';

class YourService {
  final logger = getLogger('YourService');

  void performOperation() {
    logger.i('Operation started');
    try {
      // ... your code
      logger.d('Operation details: $details');
    } catch (e, stackTrace) {
      logger.e('Operation failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
```

The logger is configured to:

- Show colorful logs in development
- Filter logs by level
- Include source information (class/method)
- Format stack traces for readability

## Common Base ViewModel

The `CommonBaseViewmodel` provides shared functionality for all your ViewModels, making it easier to implement common patterns.

### Key Features of CommonBaseViewmodel

```dart
class YourViewModel extends CommonBaseViewmodel {
  // Access to services
  void useServices() {
    // The base ViewModel provides access to common services
    navigationService.back(); // Navigation service
    dialogService.showDialog(title: 'Title', description: 'Message'); // Dialog service
    bottomSheetService.showBottomSheet(title: 'Title'); // Bottom sheet service

    // Environment information
    final env = currentEnvironment; // Get current environment (dev/prod)
    final isDevMode = isDevelopment; // Check if in development mode
  }

  // Busy state management
  Future<void> loadData() async {
    setBusy(true); // Show loading state
    try {
      // Perform async operation
      final result = await apiService.fetchData();
      // Process result
    } catch (e) {
      setError(e.toString()); // Set error state with message
    } finally {
      setBusy(false); // Hide loading state
    }
  }

  // Error handling
  void handleError(String message) {
    setError(message);
    // Error state can be checked with hasError
    // Error message can be accessed with error property
  }

  // Reactive properties
  void setupReactiveProperties() {
    // Register properties for reactivity
    listenToReactiveValues([_count, _user, _items]);

    // When these values change and notifyListeners() is called,
    // the UI will automatically rebuild
  }

  // UI rebuilding
  void updateUI() {
    // After changing reactive properties
    rebuildUi(); // This triggers UI rebuild
  }
}
```

### Using the ViewModel in Views

```dart
class MyView extends StackedView<MyViewModel> {
  @override
  Widget builder(context, viewModel, child) {
    return Scaffold(
      appBar: AppBar(title: const Text('My View')),
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator()) // Show loading
          : viewModel.hasError
              ? Center(child: Text('Error: ${viewModel.error}')) // Show error
              : _buildContent(context, viewModel), // Show content
    );
  }

  // ... other StackedView implementations
}
```

## UI Components Library

The boilerplate includes reusable UI components in the `lib/ui/components/` directory.

### Widgets

The `lib/ui/components/widgets/` directory contains several reusable widgets:

#### AppButton

A customizable button component with different styles, sizes, and states:

```dart
import 'package:flutter_boilerplate/ui/components/widgets/base/app_button.dart';

// Primary/Elevated button (default)
AppButton(
  label: 'Submit',
  onPressed: () => viewModel.submitForm(),
  isBusy: viewModel.isBusy,
  fullWidth: true, // Takes full width (default)
  type: AppButtonType.elevated,
  size: AppButtonSize.medium,
);

// Outlined button
AppButton(
  label: 'Cancel',
  onPressed: () => viewModel.cancel(),
  type: AppButtonType.outlined,
);

// Text button
AppButton(
  label: 'Skip',
  onPressed: () => viewModel.skip(),
  type: AppButtonType.text,
  fullWidth: false, // Not full width
);

// Button with icon
AppButton(
  label: 'Add Item',
  onPressed: () => viewModel.addItem(),
  icon: const Icon(Icons.add),
  size: AppButtonSize.small,
);

// Disabled button
AppButton(
  label: 'Next',
  onPressed: () => viewModel.goToNext(),
  isEnabled: viewModel.canGoNext,
);
```

#### AppTextField

A customizable text field component with validation, icons, and other features:

```dart
import 'package:flutter_boilerplate/ui/components/widgets/base/app_text_field.dart';

// Basic text field
AppTextField(
  controller: viewModel.nameController,
  label: 'Full Name',
  hintText: 'Enter your full name',
);

// Email field with validation
AppTextField(
  controller: viewModel.emailController,
  label: 'Email Address',
  hintText: 'example@domain.com',
  keyboardType: TextInputType.emailAddress,
  prefixIcon: Icons.email,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!value.contains('@')) {
      return 'Enter a valid email address';
    }
    return null;
  },
);

// Password field
AppTextField(
  controller: viewModel.passwordController,
  label: 'Password',
  isPassword: true, // Shows the visibility toggle icon
  keyboardType: TextInputType.visiblePassword,
);

// Text field with custom suffix icon and action
AppTextField(
  controller: viewModel.searchController,
  label: 'Search',
  suffixIcon: Icons.search,
  onSuffixTap: () => viewModel.search(),
  onSubmitted: (value) => viewModel.search(),
);

// Multiline text field
AppTextField(
  controller: viewModel.descriptionController,
  label: 'Description',
  maxLines: 5,
  minLines: 3,
);

// Filled text field
AppTextField(
  controller: viewModel.addressController,
  label: 'Address',
  isFilled: true,
);

// Read-only text field
AppTextField(
  controller: viewModel.dateController,
  label: 'Select Date',
  readOnly: true,
  suffixIcon: Icons.calendar_today,
  onSuffixTap: () => viewModel.showDatePicker(),
);
```

#### AppScaffold

A scaffold wrapper with additional features:

```dart
import 'package:flutter_boilerplate/ui/components/widgets/base/app_scaffold.dart';
import 'package:flutter_boilerplate/ui/components/widgets/base/app_app_bar.dart';

AppScaffold(
  appBar: AppAppBar(
    title: 'Home Screen',
    actions: [
      IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () => viewModel.openSettings(),
      ),
    ],
  ),
  body: SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Your screen content
        ],
      ),
    ),
  ),
  bottomNavigationBar: BottomNavigationBar(
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ],
    currentIndex: viewModel.selectedIndex,
    onTap: viewModel.setIndex,
  ),
  floatingActionButton: FloatingActionButton(
    onPressed: () => viewModel.addNew(),
    child: const Icon(Icons.add),
  ),
  safeArea: true, // Handles safe area automatically
  resizeToAvoidBottomInset: true, // Handles keyboard appearance
);
```

#### CustomNetworkImage

A wrapper for cached network images with better error handling and loading states:

```dart
import 'package:flutter_boilerplate/ui/components/widgets/custom_image/custom_network_image.dart';

// Basic usage
CustomNetworkImage(
  imageUrl: viewModel.user.avatarUrl,
  // Default loading spinner and empty state
);

// With custom loading and error widgets
CustomNetworkImage(
  imageUrl: product.imageUrl,
  loadingWidget: const Center(
    child: CircularProgressIndicator(strokeWidth: 2),
  ),
  emptyWidget: const Icon(
    Icons.image_not_supported,
    size: 50,
    color: Colors.grey,
  ),
  boxFit: BoxFit.contain,
);

// With specified size and memory cache settings
CustomNetworkImage(
  imageUrl: banner.imageUrl,
  size: const Size(double.infinity, 200),
  memCache: const CustomMemCache(height: 400, width: 800),
);
```

### Dialogs

Using the custom dialogs from `lib/ui/components/dialogs/`:

```dart
// In your ViewModel
void showConfirmationDialog() {
  dialogService.showCustomDialog(
    variant: DialogType.confirmation,
    title: 'Confirm Action',
    description: 'Are you sure you want to proceed with this action?',
    mainButtonTitle: 'Yes',
    secondaryButtonTitle: 'No',
  ).then((response) {
    if (response?.confirmed ?? false) {
      // User confirmed the action
      performAction();
    }
  });
}

void showErrorDialog(String errorMessage) {
  dialogService.showCustomDialog(
    variant: DialogType.error,
    title: 'Error Occurred',
    description: errorMessage,
    mainButtonTitle: 'OK',
  );
}

void showInfoDialog() {
  dialogService.showCustomDialog(
    variant: DialogType.infoAlert,
    title: 'Information',
    description: 'This is an informational message.',
    mainButtonTitle: 'Got it',
  );
}
```

### Bottom Sheets

Using the custom bottom sheets from `lib/ui/components/bottom_sheets/`:

```dart
// In your ViewModel
void showOptionsBottomSheet() {
  bottomSheetService.showCustomSheet(
    variant: BottomSheetType.options,
    title: 'Available Options',
    description: 'Choose an option from the list below:',
    data: ['Option 1', 'Option 2', 'Option 3'],
  ).then((response) {
    if (response?.confirmed ?? false) {
      final selectedOption = response?.data;
      // Handle the selected option
      handleSelectedOption(selectedOption);
    }
  });
}

void showNoticeBottomSheet() {
  bottomSheetService.showCustomSheet(
    variant: BottomSheetType.notice,
    title: 'Notice',
    description: 'This is an important notice for the user.',
  );
}
```

## Asset Management

The boilerplate uses FlutterGen for type-safe asset access.

### Using Generated Assets

```dart
// Import the generated assets
import 'package:flutter_boilerplate/gen/asset/assets.gen.dart';

// In your widget
Widget build(BuildContext context) {
  return Column(
    children: [
      // Using images
      Image.asset(
        Assets.images.logo.path,
        width: 100,
        height: 100,
      ),

      // Using SVGs
      Assets.svgs.background.svg(
        width: double.infinity,
        height: 200,
      ),

      // Using Lottie animations
      Assets.lottie.loading.lottie(
        width: 100,
        height: 100,
        repeat: true,
      ),

      // Using other assets like fonts
      Text(
        'Styled Text',
        style: TextStyle(
          fontFamily: Assets.fonts.roboto.family,
          fontSize: 16,
        ),
      ),
    ],
  );
}
```

### Asset Organization

The assets are organized as follows:

```
assets/
  ├── images/      # PNG and JPG images
  │     ├── logo.png
  │     └── background.jpg
  ├── svgs/        # SVG files
  │     ├── icon.svg
  │     └── illustration.svg
  ├── lottie/      # Lottie animation files
  │     ├── loading.json
  │     └── success.json
  ├── fonts/       # Font files
  │     └── custom_font.ttf
  └── translations/ # Localization files
        ├── en-US.json
        ├── de-DE.json
        └── hi-IN.json
```

To add new assets:

1. Place the files in the appropriate directory
2. Ensure they're included in pubspec.yaml
3. Run `stacked generate` to update the generated assets

## Environment Configuration

### Setting Up Environment Variables

Environment variables are managed using the `envied` package. Create `.env.dev` and `.env.prod` files in the root directory:

```
# .env.dev
API_URL=https://api.dev.example.com
API_KEY=dev_api_key

# .env.prod
API_URL=https://api.example.com
API_KEY=prod_api_key
```

Then define an `Env` class:

```dart
// lib/core/env/env.dart
import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env.dev')
abstract class Env {
  @EnviedField(varName: 'API_URL')
  static const String apiUrl = _Env.apiUrl;

  @EnviedField(varName: 'API_KEY')
  static const String apiKey = _Env.apiKey;

  @EnviedField(defaultValue: 'development')
  static const String environment = _Env.environment;
}
```

Run `stacked generate` to generate the env.g.dart file.

### Switching Environments

The boilerplate includes an environment manager script for easily switching between environments:

```bash
# Switch to development environment
dart run env_manager.dart dev

# Switch to production environment
dart run env_manager.dart prod
```

This is the recommended way to switch environments before building your app.

Alternatively, the environment is configured in the `pubspec.yaml` file:

```yaml
targets:
  $default:
    builders:
      envied_generator:
        options:
          path: ".env.dev" # Default for regular builds
```

You can also use command-line arguments during build:

```bash
# Build with production environment
flutter build apk --dart-define=ENV=prod
```

### Building Release Versions

To create a release build with all optimizations:

```bash
dart run build_release.dart
```

This script handles environment configuration and building for your target platforms.

## Form Handling and Validation

The boilerplate provides an easy way to handle forms with validation in Flutter. Here are some examples:

### Basic Form with Validation

```dart
// In your View
class LoginView extends StackedView<LoginViewModel> {
  @override
  Widget builder(BuildContext context, LoginViewModel viewModel, Widget? child) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: viewModel.formKey, // Global key from ViewModel
          child: Column(
            children: [
              // Email field
              TextFormField(
                controller: viewModel.emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: viewModel.validateEmail,
              ),
              const SizedBox(height: 16),

              // Password field
              TextFormField(
                controller: viewModel.passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      viewModel.passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off
                    ),
                    onPressed: viewModel.togglePasswordVisibility,
                  ),
                ),
                obscureText: !viewModel.passwordVisible,
                validator: viewModel.validatePassword,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: viewModel.isBusy
                      ? null
                      : viewModel.login,
                  child: viewModel.isBusy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  LoginViewModel viewModelBuilder(BuildContext context) => LoginViewModel();
}
```

```dart
// In your ViewModel
class LoginViewModel extends CommonBaseViewmodel {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _passwordVisible = false;
  bool get passwordVisible => _passwordVisible;

  // Toggle password visibility
  void togglePasswordVisibility() {
    _passwordVisible = !_passwordVisible;
    rebuildUi();
  }

  // Email validation
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  // Password validation
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  // Login function
  Future<void> login() async {
    // Validate form
    if (formKey.currentState?.validate() != true) {
      return;
    }

    // Show loading state
    setBusy(true);

    try {
      // Get values from controllers
      final email = emailController.text;
      final password = passwordController.text;

      // Call authentication service
      final result = await _authService.login(email, password);

      result.when(
        success: (user, _, __) {
          // Navigate to home screen
          _navigationService.replaceWith(Routes.homeView);
        },
        error: (errorMessage, _, __) {
          // Show error dialog
          _dialogService.showDialog(
            title: 'Login Failed',
            description: errorMessage,
          );
        },
      );
    } catch (e) {
      logger.e('Login error', error: e);
      // Show generic error dialog
      _dialogService.showDialog(
        title: 'Error',
        description: 'An unexpected error occurred. Please try again.',
      );
    } finally {
      setBusy(false);
    }
  }

  @override
  void dispose() {
    // Clean up controllers when ViewModel is disposed
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
```

### Custom Form Fields

You can create reusable form fields for common use cases:

```dart
// lib/ui/components/widgets/base/custom_text_field.dart
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final bool readOnly;

  const CustomTextField({
    required this.controller,
    required this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      readOnly: readOnly,
    );
  }
}
```

```dart
// Using the custom text field
CustomTextField(
  controller: viewModel.nameController,
  label: 'Full Name',
  prefixIcon: Icons.person,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    return null;
  },
),
```

### Common Validation Patterns

You can create a utility class with common validation patterns:

```dart
// lib/core/utils/validators.dart
class Validators {
  static String? required(String? value, [String field = 'Field']) {
    if (value == null || value.isEmpty) {
      return '$field is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }

    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    if (value.length < 10) {
      return 'Please enter a valid phone number';
    }

    return null;
  }
}
```

```dart
// Using the validators
TextFormField(
  controller: viewModel.emailController,
  decoration: const InputDecoration(labelText: 'Email'),
  validator: Validators.email,
),

TextFormField(
  controller: viewModel.passwordController,
  decoration: const InputDecoration(labelText: 'Password'),
  obscureText: true,
  validator: (value) => Validators.password(value, minLength: 8),
),

TextFormField(
  controller: viewModel.confirmPasswordController,
  decoration: const InputDecoration(labelText: 'Confirm Password'),
  obscureText: true,
  validator: (value) => Validators.confirmPassword(
    value,
    viewModel.passwordController.text,
  ),
),
```
