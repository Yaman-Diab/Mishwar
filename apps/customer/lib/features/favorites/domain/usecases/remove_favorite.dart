import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../repositories/favorites_repository.dart';

@injectable
class RemoveFavorite implements UseCase<void, RemoveFavoriteParams> {
  final FavoritesRepository _repository;

  const RemoveFavorite(this._repository);

  @override
  Future<Either<Failure, void>> call(RemoveFavoriteParams params) {
    return _repository.removeFavorite(params.farmId);
  }
}

class RemoveFavoriteParams extends Equatable {
  final String farmId;

  const RemoveFavoriteParams({required this.farmId});

  @override
  List<Object?> get props => [farmId];
}
