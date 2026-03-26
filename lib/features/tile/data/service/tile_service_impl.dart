import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../../core/constants/service.dart';
import '../../../../../core/http/http_client.dart';
import '../entities/tile_entity.dart';
import 'tile_service.dart';

class TileServiceImpl implements TileService {
  @override
  Future<Either<String, TileListEntity>> getTileProject(int idProject) async {
    final url = Services.getTileProject(idProject);
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
