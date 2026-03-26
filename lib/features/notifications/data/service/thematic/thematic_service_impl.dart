import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../../../core/constants/service.dart';
import '../../../../../../core/http/http_client.dart';
import '../../entities/thematic/thematic_entity.dart';
import 'thematic_service.dart';

class ThematicServiceImpl implements ThematicService {
  @override
  Future<Either<String, ThematicListEntity>> getThematic(int idProject) async {
    final url = Services.getThematicProject(idProject);
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
        if (response.toString().contains('data')) {
          return Right(response['data']);
        }
        return Right(response);
      }
    } catch (e) {
      return Left(e.toString());
    }
  }
}
