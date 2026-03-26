import 'config.dart' show BaseConfig;

class ProdConfig implements BaseConfig {
  @override
  String get apiHost => const String.fromEnvironment('HOST_URL', defaultValue: 'http://102.219.179.120:8010/api/v1/');@override
  String get projectId => const String.fromEnvironment('PROJECT_ID', defaultValue: '0');
}