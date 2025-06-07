import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env.dev', obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'ENV')
  static final String environment = _Env.environment;

  // @EnviedField(varName: 'API_URL')
  // static final String apiUrl = _Env.apiUrl;

  // @EnviedField(varName: 'API_KEY')
  // static final String apiKey = _Env.apiKey;
}
