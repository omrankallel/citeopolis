import 'package:dartz/dartz.dart';

abstract class TileDetailUseCase {
  Future<Either<String, dynamic>> getTileDetail(String tileId, String tileType);
  Future<Either<String, dynamic>> getTileDetailFromServer(String tileId, String tileType);
  Future<Either<String, dynamic>> getTileDetailFromLocal(String tileId, String tileType);
}