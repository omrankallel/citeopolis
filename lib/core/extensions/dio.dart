import 'dart:io';

import 'package:dio/dio.dart';

import '../http/http.dart' show RequestMethod;
import '../utils/utils.dart' show Helpers;

extension DioErrorX on DioException {
  bool get isNoConnectionError => type == DioExceptionType.connectionError && error is SocketException;

  bool get isConnectionTimeout => type == DioExceptionType.connectionTimeout || type == DioExceptionType.receiveTimeout || type == DioExceptionType.sendTimeout;
}

extension RequestMethodX on RequestMethod {
  String get value => Helpers.getEnumValue(this).toUpperCase();
}
