import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../../../core/constants/service.dart';
import '../../../../../../core/http/http_client.dart';
import '../../entities/content_home/build_page_entity.dart';
import 'content_home_service.dart';

class ContentHomeServiceImpl implements ContentHomeService {
  @override
  Future<Either<String, BuildPageEntity>> getPageHome(int idProject) async {
    final url = Services.buildPage(idProject);
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
        if (response['success']) {
          return Right(response['data']);
        }
        return Right(response);
      }
    } catch (e) {
      return Left(e.toString());
    }
  }
}
