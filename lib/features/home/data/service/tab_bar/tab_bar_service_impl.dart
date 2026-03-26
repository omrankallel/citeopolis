import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../../../core/constants/service.dart';
import '../../../../../../core/http/http_client.dart';
import '../../entities/tab_bar/tab_bar_entity.dart';
 import 'tab_bar_service.dart';

class TabBarServiceImpl implements TabBarService {
  @override
  Future<Either<String, TabBarListEntity>> getTabBarProject(int idProject) async {
    final url = Services.getTabBarProject(idProject);
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
        return const Right([]);
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

}
