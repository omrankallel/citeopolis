
import 'package:dartz/dartz.dart';

abstract class TileDetailService {
  Future<Either<String, Map<String, dynamic>>> getTileDetail(int tileId);
}