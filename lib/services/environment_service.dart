import 'package:stacked/stacked.dart';

import '../core/env/env.dart';

enum Environment {
  development,
  production,
}

class EnvironmentService with ListenableServiceMixin {
  EnvironmentService() {
    listenToReactiveValues([_currentEnvironment]);
  }

  Environment _currentEnvironment = Env.environment == 'production'
      ? Environment.production
      : Environment.development;

  Environment get currentEnvironment => _currentEnvironment;

  bool get isDevelopment => _currentEnvironment == Environment.development;
  bool get isProduction => _currentEnvironment == Environment.production;

  // String get apiUrl => Env.apiUrl;
  // String get apiKey => Env.apiKey;

  // This would handle switching environments at runtime if needed
  // Note: With envied, full switching would require regenerating code
  void setEnvironment(Environment environment) {
    _currentEnvironment = environment;
    notifyListeners();
  }
}
