import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../../../core/constants/service.dart';
import '../../../../../../core/http/http_client.dart';
import '../../entities/notification/notification_entity.dart';
import 'notification_service.dart';

class NotificationServiceImpl implements NotificationService {
  @override
  Future<Either<String, NotificationListEntity>> getNotification(int idProject) async {
    final url = Services.getNotificationProject(idProject);
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
          if (response['data'] == 'not notifs') {
            return const Right([]);
          }
          return Right(response['data']);
        }
        return Right(response['data']);
      }
    } catch (e) {
      return Left(e.toString());
    }
  }
}
