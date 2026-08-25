import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../../domain/entities/favorite_farm_entity.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_remote_datasource.dart';

@LazySingleton(as: FavoritesRepository)
class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteDataSource _remoteDataSource;

  const FavoritesRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<FavoriteFarmEntity>>> getFavorites() async {
    try {
      final favorites = await _remoteDataSource.getFavorites();
      return Right(favorites);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> addFavorite(String farmId) async {
    try {
      await _remoteDataSource.addFavorite(farmId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> removeFavorite(String farmId) async {
    try {
      await _remoteDataSource.removeFavorite(farmId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
