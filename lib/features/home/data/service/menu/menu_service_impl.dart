import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../../core/constants/service.dart';
import '../../../../../core/http/http_client.dart';
import '../../entities/menu/menu_entity.dart';
import 'menu_service.dart';

class MenuServiceImpl implements MenuService {
  @override
  Future<Either<String, MenuListEntity>> getMenuProject(int idProject) async {
    final url = Services.getMenuProject(idProject);
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
