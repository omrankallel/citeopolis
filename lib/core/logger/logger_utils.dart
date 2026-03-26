import 'package:logger/logger.dart';

import '../enums/enums.dart' show LoggerEnum;

mixin Loggers {
  static final Logger _logger = Logger();

  static void write(String text, {LoggerEnum loggerType = LoggerEnum.fatal, bool isError = false}) {
    switch (loggerType) {
      case LoggerEnum.trace:
        _logger.t(text, error: isError);
        break;
      case LoggerEnum.debug:
        _logger.d(text, error: isError);
        break;
      case LoggerEnum.info:
        _logger.i(text, error: isError);
        break;
      case LoggerEnum.warning:
        _logger.w(text, error: isError);
        break;
      case LoggerEnum.error:
        _logger.e(text, error: isError);
        break;
      case LoggerEnum.fatal:
        _logger.f(text, error: isError);
        break;
    }
  }
}
