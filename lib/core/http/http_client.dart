import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/material.dart';

import '../config/config.dart' show ProdConfig;
import '../extensions/extensions.dart' show RequestMethodX;
import '../memory/shared_preferences_service.dart';
import 'http.dart' show Caller;

class ApiRequest {
  final Dio dio;
  final Caller caller;

  factory ApiRequest() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ProdConfig().apiHost,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) async {
          final String? token = await SharedPreferencesService().get('auth');
          if (token != null && token != '') {
            request.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(request);
        },
      ),
    );

    CacheStore? cacheStore;
    CacheOptions? cacheOptions;
    cacheStore = MemCacheStore(maxSize: 10485760, maxEntrySize: 1048576);
    cacheOptions = CacheOptions(
      store: cacheStore,
      hitCacheOnErrorExcept: [],
    );
    dio.interceptors.add(
      DioCacheInterceptor(options: cacheOptions),
    );

    final Caller caller = Caller(
      cacheStore: cacheStore,
      cacheOptions: cacheOptions,
      dio: dio,
    );
    return ApiRequest._(dio, caller);
  }

  const ApiRequest._(this.dio, this.caller);

  Future request<T>(
    RequestMethod method,
    String url, {
    data,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    bool getStatus = false,
    responseType = ResponseType.json,
  }) async {
    try {
      final res = await dio.request(
        url,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          responseType: responseType,
          method: method.value,
          headers: headers,
        ),
      );
      debugPrint('Request [${method.value}] /$url return: ${res.statusCode}');
      if (getStatus == false) {
        return res.data;
      } else {
        return res;
      }
    } catch (e) {
      return caller.requestCall(url);
    }
  }
}

enum RequestMethod {
  get,
  head,
  post,
  put,
  delete,
  connect,
  options,
  trace,
  patch,
}
