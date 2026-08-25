import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:mashwar_core/mashwar_core.dart';

import '../repositories/favorites_repository.dart';

@injectable
class AddFavorite implements UseCase<void, AddFavoriteParams> {
  final FavoritesRepository _repository;

  const AddFavorite(this._repository);

  @override
  Future<Either<Failure, void>> call(AddFavoriteParams params) {
    return _repository.addFavorite(params.farmId);
  }
}

class AddFavoriteParams extends Equatable {
  final String farmId;

  const AddFavoriteParams({required this.farmId});

  @override
  List<Object?> get props => [farmId];
}
