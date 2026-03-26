import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../../core/constants/service.dart';
import '../../../../../core/http/http_client.dart';
import '../entities/term_entity.dart';
import 'term_service.dart';

class TermServiceImpl implements TermService {
  @override
  Future<Either<String, TermListEntity>> getTermProject(int idProject) async {
    final url = Services.getTerm;
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
