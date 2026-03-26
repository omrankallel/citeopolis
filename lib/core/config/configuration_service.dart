import 'package:flutter/material.dart';

import 'config.dart' show BaseConfig, DevConfig, ProdConfig;

class Environment {
  factory Environment() => _singleton;

  Environment._internal();

  static final Environment _singleton = Environment._internal();

  static const String dev = 'DEV';
  static const String prod = 'PROD';

  BaseConfig? config;

  void initConfig(String environment) {
    debugPrint('╔══════════════════════════════════════════════════════════════╗');
    debugPrint('                    Build Flavor: $environment                  ');
    debugPrint('╚══════════════════════════════════════════════════════════════╝');
    config = _getConfig(environment);
  }

  BaseConfig _getConfig(String environment) {
    switch (environment) {
      case Environment.prod:
        return ProdConfig();
      default:
        return DevConfig();
    }
  }
}