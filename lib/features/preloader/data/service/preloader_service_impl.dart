import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../../core/constants/service.dart';
import '../../../../../core/http/http_client.dart';
import '../entities/config_app_entity.dart';
import 'preloader_service.dart';

class PreloaderServiceImpl implements PreloaderService {
  @override
  Future<Either<String, ConfigAppEntity>> getConfigProject(int idProject) async {
    final url = Services.getConfigProject(idProject);
    try {
      final response = await ApiRequest().request(RequestMethod.get, url);

      if (response is DioException) {
        final errorResponse = response.response;
        if (errorResponse != null) {
          return Left(errorResponse.statusCode.toString());
        } else {
          return const Left('-1');
        }
      } else {
        return Right(response['data']);
      }
    } catch (e) {
      return Left(e.toString());
    }
  }
}
