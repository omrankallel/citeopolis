import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../../core/constants/service.dart';
import '../../../../../core/http/http_client.dart';
import 'tile_detail_service.dart';

class TileDetailServiceImpl implements TileDetailService {
  @override
  Future<Either<String, Map<String, dynamic>>> getTileDetail(int tileId) async {
    final url = Services.getDetailTileProject(tileId);
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