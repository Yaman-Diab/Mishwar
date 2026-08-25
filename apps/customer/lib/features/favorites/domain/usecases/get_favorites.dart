import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../entities/favorite_farm_entity.dart';
import '../repositories/favorites_repository.dart';

@injectable
class GetFavorites implements UseCase<List<FavoriteFarmEntity>, NoParams> {
  final FavoritesRepository _repository;

  const GetFavorites(this._repository);

  @override
  Future<Either<Failure, List<FavoriteFarmEntity>>> call(NoParams params) {
    return _repository.getFavorites();
  }
}
